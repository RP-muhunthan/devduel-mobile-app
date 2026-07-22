"""
splash_page.py – Splash / Onboarding screen page object
"""
import time
from .base_page import BasePage


class SplashPage(BasePage):
    """Handles the initial splash screen that auto-navigates to /login."""

    # ── Locators ──────────────────────────────────────────────────────────────
    DEVDUEL_LOGO_TEXT = "DEVDUEL"

    def wait_for_splash(self, timeout: int = 15):
        """Wait until the DEVDUEL logo is visible on the splash screen."""
        return self.is_text_visible(self.DEVDUEL_LOGO_TEXT, timeout)

    def wait_for_login_screen(self, timeout: int = 20):
        """Wait until the app transitions from Splash → Login."""
        return self.is_text_visible("Welcome Back", timeout)

    def is_on_splash(self) -> bool:
        return self.is_text_visible(self.DEVDUEL_LOGO_TEXT, timeout=5)
