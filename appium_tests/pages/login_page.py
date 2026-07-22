"""
login_page.py – Login screen page object
=========================================
Matches the LoginScreen widget in devduel_mobile.
"""
import time
from appium.webdriver.common.appiumby import AppiumBy
from selenium.common.exceptions import TimeoutException
from .base_page import BasePage


class LoginPage(BasePage):
    """Page object for /login route."""

    # ── Text identifiers (Flutter renders text nodes) ─────────────────────────
    TITLE          = "Welcome Back"
    SUBTITLE       = "Sign in to resume your terminal duel."
    EMAIL_HINT     = "dev@duel.sh"
    PASSWORD_HINT  = "••••••••"
    LOGIN_BTN      = "LOGIN"
    REGISTER_LINK  = "Register"
    GOOGLE_BTN     = "Continue with Google"
    FORGOT_PWD     = "Forgot Password?"

    # ── Presence check ────────────────────────────────────────────────────────

    def is_on_login_page(self, timeout: int = 15) -> bool:
        return self.is_text_visible(self.TITLE, timeout)

    # ── Field interactions ────────────────────────────────────────────────────

    def enter_email(self, email: str):
        f = self.driver.find_element(AppiumBy.XPATH, "//*[@hint='dev@duel.sh']")
        f.click()
        f.clear(); f.send_keys(email)
        try:
            self.driver.hide_keyboard()
        except Exception:
            pass
        time.sleep(0.5)

    def enter_password(self, password: str):
        f = self.driver.find_element(AppiumBy.XPATH, "//*[@hint='••••••••']")
        f.click()
        f.clear(); f.send_keys(password)
        try:
            self.driver.hide_keyboard()
        except Exception:
            pass
        time.sleep(0.5)

    def tap_login(self):
        self.tap_by_text(self.LOGIN_BTN)

    def tap_register_link(self):
        self.tap_by_text(self.REGISTER_LINK)

    def tap_google_login(self):
        try:
            self.scroll_to_text(self.GOOGLE_BTN)
        except Exception:
            pass
        self.tap_by_text(self.GOOGLE_BTN)

    def tap_forgot_password(self):
        self.tap_by_text(self.FORGOT_PWD)

    # ── Compound actions ──────────────────────────────────────────────────────

    def login(self, email: str, password: str):
        """Fill credentials and submit the login form."""
        self.enter_email(email)
        self.enter_password(password)
        self.tap_login()

    # ── Validation helpers ────────────────────────────────────────────────────

    def get_snackbar_text(self, timeout: int = 8) -> str:
        """Wait for a SnackBar and return its text."""
        try:
            snack = self.find_by_xpath(
                '//android.widget.FrameLayout[@content-desc="Snackbar"]//*[contains(@class,"Text")]',
                timeout,
            )
            return snack.text
        except TimeoutException:
            # Fallback: any new text that wasn't there before
            return ""

    def is_login_error_visible(self, timeout: int = 8) -> bool:
        """Check that some error SnackBar appeared."""
        return self.is_text_contains_visible("Please", timeout) or \
               self.is_text_contains_visible("error", timeout) or \
               self.is_text_contains_visible("Error", timeout) or \
               self.is_text_contains_visible("failed", timeout) or \
               self.is_text_contains_visible("Incorrect", timeout)

    def is_email_empty_error(self, timeout: int = 5) -> bool:
        return self.is_text_contains_visible("fill in all fields", timeout)
