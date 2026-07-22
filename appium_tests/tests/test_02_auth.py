"""
test_02_auth.py – Authentication E2E tests (Login & Register)
==============================================================
Covers:
  TC-AUTH-01  Valid login with correct credentials
  TC-AUTH-02  Login with empty email
  TC-AUTH-03  Login with empty password
  TC-AUTH-04  Login with wrong password
  TC-AUTH-05  Navigate Login → Register
  TC-AUTH-06  Register with mismatched passwords
  TC-AUTH-07  Register with short password
  TC-AUTH-08  Register with empty fields
  TC-AUTH-09  Valid registration (unique timestamp email)
  TC-AUTH-10  Google login button navigates to Home
  TC-AUTH-11  Back navigation from Register → Login
"""

import os
import time
import datetime
import pytest

from pages import LoginPage, RegisterPage, HomePage
from utils import ExcelReporter, ResultRecord

MODULE = "02 – Authentication"

# ── Test credentials from .env ────────────────────────────────────────────────
VALID_EMAIL    = os.getenv("TEST_EMAIL",    "testuser@devduel.com")
VALID_PASSWORD = os.getenv("TEST_PASSWORD", "Test@1234")


@pytest.mark.category("Regression Testing")
class TestLogin:
    """Login screen tests."""

    @pytest.fixture(autouse=True)
    def reset_to_login(self, driver):
        """Reset app and go to login before each test."""
        driver.reset_app()
        login = LoginPage(driver)
        if not login.is_on_login_page(timeout=5):
            # We are probably on Home. Try to logout!
            from pages import HomePage, ProfilePage
            try:
                HomePage(driver).tap_nav_profile()
                ProfilePage(driver).tap_logout()
            except Exception:
                pass
        login.is_on_login_page(timeout=20)

    # ── TC-AUTH-01: Valid login ───────────────────────────────────────────────
    def test_valid_login(self, driver):
        """TC-AUTH-01 – Login with valid credentials navigates to Home."""
        login = LoginPage(driver)
        login.login(VALID_EMAIL, VALID_PASSWORD)
        home = HomePage(driver)
        assert home.is_on_home(timeout=30), \
            "Home screen did not appear after valid login"
        home.tap_nav_profile()
        from pages import ProfilePage
        ProfilePage(driver).tap_logout()

    # ── TC-AUTH-02: Empty email ───────────────────────────────────────────────
    def test_login_empty_email(self, driver):
        """TC-AUTH-02 – Login with empty email shows validation error."""
        login = LoginPage(driver)
        login.enter_password(VALID_PASSWORD)
        login.tap_login()
        assert login.is_email_empty_error(timeout=8), \
            "Expected 'fill in all fields' error for empty email"

    # ── TC-AUTH-03: Empty password ────────────────────────────────────────────
    def test_login_empty_password(self, driver):
        """TC-AUTH-03 – Login with empty password shows validation error."""
        login = LoginPage(driver)
        login.enter_email(VALID_EMAIL)
        login.tap_login()
        assert login.is_email_empty_error(timeout=8), \
            "Expected 'fill in all fields' error for empty password"

    # ── TC-AUTH-04: Wrong password ────────────────────────────────────────────
    def test_login_wrong_password(self, driver):
        """TC-AUTH-04 – Login with wrong password shows error SnackBar."""
        login = LoginPage(driver)
        login.login(VALID_EMAIL, "WrongPass999!")
        assert login.is_login_error_visible(timeout=15), \
            "Expected error SnackBar for incorrect password"

    # ── TC-AUTH-05: Navigate to Register ─────────────────────────────────────
    def test_navigate_to_register(self, driver):
        """TC-AUTH-05 – Tapping 'Register' link opens Register screen."""
        login = LoginPage(driver)
        login.tap_register_link()
        register = RegisterPage(driver)
        assert register.is_on_register_page(timeout=15), \
            "Register screen did not open after tapping Register link"

    # ── TC-AUTH-10: Google login bypass ──────────────────────────────────────
    def test_google_login_navigates_to_home(self, driver):
        """TC-AUTH-10 – 'Continue with Google' button goes directly to Home."""
        login = LoginPage(driver)
        login.tap_google_login()
        home = HomePage(driver)
        assert home.is_on_home(timeout=25), \
            "Home screen did not appear after Google login tap"


@pytest.mark.category("Regression Testing")
class TestRegister:
    """Register screen tests."""

    @pytest.fixture(autouse=True)
    def navigate_to_register(self, driver):
        """Navigate to the Register screen before each test."""
        driver.reset_app()
        login = LoginPage(driver)
        if not login.is_on_login_page(timeout=5):
            from pages import HomePage, ProfilePage
            try:
                HomePage(driver).tap_nav_profile()
                ProfilePage(driver).tap_logout()
            except Exception:
                pass
        login.is_on_login_page(timeout=20)
        login.tap_register_link()
        register = RegisterPage(driver)
        register.is_on_register_page(timeout=15)

    # ── TC-AUTH-06: Mismatched passwords ─────────────────────────────────────
    def test_register_mismatched_passwords(self, driver):
        """TC-AUTH-06 – Register with mismatched passwords shows error."""
        reg = RegisterPage(driver)
        reg.enter_full_name("Test User")
        reg.enter_email("test@devduel.io")
        reg.enter_college("Test College")
        reg.enter_password("Pass@1234")
        reg.enter_confirm_password("Different@1234")
        reg.tap_register()
        assert reg.is_mismatch_error_visible(timeout=8), \
            "Expected password mismatch error"

    # ── TC-AUTH-07: Short password ────────────────────────────────────────────
    def test_register_short_password(self, driver):
        """TC-AUTH-07 – Register with < 6 char password shows error."""
        reg = RegisterPage(driver)
        reg.enter_full_name("Test User")
        reg.enter_email("test@devduel.io")
        reg.enter_college("Test College")
        reg.enter_password("123")
        reg.enter_confirm_password("123")
        reg.tap_register()
        assert reg.is_short_password_error_visible(timeout=8), \
            "Expected 'at least 6 characters' error"

    # ── TC-AUTH-08: Empty fields ──────────────────────────────────────────────
    def test_register_empty_fields(self, driver):
        """TC-AUTH-08 – Register with all empty fields shows validation error."""
        reg = RegisterPage(driver)
        reg.tap_register()
        assert reg.is_empty_fields_error_visible(timeout=8), \
            "Expected 'fill in all fields' error"

    # ── TC-AUTH-09: Valid registration ───────────────────────────────────────
    def test_register_valid_user(self, driver):
        """TC-AUTH-09 – Register with unique credentials navigates to Home."""
        ts    = datetime.datetime.now().strftime("%H%M%S")
        email = f"autotest_{ts}@devduel.io"
        reg   = RegisterPage(driver)
        reg.register(
            name    = f"Auto Tester {ts}",
            email   = email,
            college = "Automation University",
            password= "AutoTest@123",
        )
        home = HomePage(driver)
        assert home.is_on_home(timeout=30), \
            f"Home screen did not appear after registering {email}"
        home.tap_nav_profile()
        from pages import ProfilePage
        ProfilePage(driver).tap_logout()

    # ── TC-AUTH-11: Back from Register ───────────────────────────────────────
    def test_back_from_register_to_login(self, driver):
        """TC-AUTH-11 – Back arrow from Register returns to Login screen."""
        reg = RegisterPage(driver)
        reg.tap_back()
        login = LoginPage(driver)
        assert login.is_on_login_page(timeout=15), \
            "Login screen did not appear after pressing back on Register"
