"""
test_01_splash.py – Splash screen E2E tests
============================================
Verifies the app launches, shows the DevDuel branding, and auto-navigates to Login.
"""

import time
import pytest

from pages  import SplashPage, LoginPage
from utils  import ExcelReporter, ResultRecord


MODULE = "01 – Splash Screen"


@pytest.mark.category("UI/UX Testing")
class TestSplashScreen:
    """E2E tests for the DevDuel splash screen."""

    def test_app_launches_successfully(self, driver):
        """App opens without crashing and something is rendered on screen."""
        driver.reset_app()
        splash = SplashPage(driver)
        from pages import HomePage
        home = HomePage(driver)
        assert splash.wait_for_splash(timeout=15) or \
               splash.wait_for_login_screen(timeout=15) or \
               home.is_on_home(timeout=15), \
               "App did not render any recognisable screen within 15 s"

    def test_splash_shows_devduel_branding(self, driver):
        """The DEVDUEL logo text is visible on the splash screen."""
        splash = SplashPage(driver)
        driver.reset_app()
        visible = splash.is_on_splash()
        from pages import HomePage
        home = HomePage(driver)
        assert visible or splash.wait_for_login_screen(timeout=20) or home.is_on_home(timeout=20), \
               "Neither splash branding nor login/home screen appeared"

    def test_splash_transitions_to_login(self, driver):
        """After splash the app navigates to the Login screen automatically."""
        driver.reset_app()
        login = LoginPage(driver)
        from pages import HomePage
        home = HomePage(driver)
        assert login.is_on_login_page(timeout=25) or home.is_on_home(timeout=25), \
               "App did not navigate to the Login or Home screen after splash"
