"""
register_page.py – Registration screen page object
====================================================
Matches the RegisterScreen widget in devduel_mobile.
"""
import time
from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage


class RegisterPage(BasePage):
    """Page object for /register route."""

    TITLE          = "Create Account"
    SUBTITLE       = "Join the elite arena of competitive coders."
    FULL_NAME_HINT = "John Doe"
    EMAIL_HINT     = "dev@duel.io"
    COLLEGE_HINT   = "Start typing your institute..."
    PASSWORD_HINT  = "••••••••"
    REGISTER_BTN   = "REGISTER"
    LOGIN_LINK     = "Login"

    # ── Presence check ────────────────────────────────────────────────────────

    def is_on_register_page(self, timeout: int = 15) -> bool:
        return self.is_text_visible(self.TITLE, timeout)

    # ── Field helpers ─────────────────────────────────────────────────────────

    def enter_full_name(self, name: str):
        f = self.driver.find_element(AppiumBy.XPATH, "//*[@hint='John Doe']")
        f.click()
        f.clear(); f.send_keys(name)
        try:
            self.driver.hide_keyboard()
        except Exception:
            pass
        time.sleep(0.5)

    def enter_email(self, email: str):
        f = self.driver.find_element(AppiumBy.XPATH, "//*[@hint='dev@duel.io']")
        f.click()
        f.clear(); f.send_keys(email)
        try:
            self.driver.hide_keyboard()
        except Exception:
            pass
        time.sleep(0.5)

    def enter_college(self, college: str):
        f = self.driver.find_element(AppiumBy.XPATH, "//*[@hint='Start typing your institute...']")
        f.click()
        f.clear(); f.send_keys(college)
        try:
            self.driver.hide_keyboard()
        except Exception:
            pass
        time.sleep(0.5)

    def enter_password(self, password: str):
        fields = self.driver.find_elements(AppiumBy.XPATH, "//*[@hint='••••••••']")
        f = fields[0]
        f.click()
        f.clear(); f.send_keys(password)
        try:
            self.driver.hide_keyboard()
        except Exception:
            pass
        time.sleep(0.5)

    def enter_confirm_password(self, password: str):
        fields = self.driver.find_elements(AppiumBy.XPATH, "//*[@hint='••••••••']")
        f = fields[-1]
        f.click()
        f.clear(); f.send_keys(password)
        try:
            self.driver.hide_keyboard()
        except Exception:
            pass
        time.sleep(0.5)

    def tap_register(self):
        self.tap_by_text(self.REGISTER_BTN)

    def tap_login_link(self):
        self.tap_by_text(self.LOGIN_LINK)

    # ── Compound action ───────────────────────────────────────────────────────

    def register(self, name: str, email: str, college: str, password: str):
        self.enter_full_name(name)
        self.enter_email(email)
        self.enter_college(college)
        self.enter_password(password)
        self.enter_confirm_password(password)
        self.tap_register()

    # ── Validation ────────────────────────────────────────────────────────────

    def is_mismatch_error_visible(self, timeout: int = 8) -> bool:
        return self.is_text_contains_visible("do not match", timeout)

    def is_short_password_error_visible(self, timeout: int = 8) -> bool:
        return self.is_text_contains_visible("at least 6", timeout)

    def is_empty_fields_error_visible(self, timeout: int = 8) -> bool:
        return self.is_text_contains_visible("fill in all fields", timeout)

    def is_success_snackbar_visible(self, timeout: int = 15) -> bool:
        return self.is_text_contains_visible("Account created", timeout)
