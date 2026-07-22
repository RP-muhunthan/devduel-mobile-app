"""
test_07_navigation.py – Bottom Navigation & Cross-Screen Flow E2E tests
"""

import os
import time
import datetime
import pytest

from pages import LoginPage, HomePage, BattlePage, ProblemsPage, LeaderboardPage, ProfilePage
from utils import ExcelReporter, ResultRecord

MODULE         = "07 – Navigation Flow"
VALID_EMAIL    = os.getenv("TEST_EMAIL",    "testuser@devduel.com")
VALID_PASSWORD = os.getenv("TEST_PASSWORD", "Test@1234")
APP_PACKAGE    = os.getenv("APP_PACKAGE",   "com.example.devduel_mobile")


@pytest.fixture(scope="module", autouse=True)
def login_once(driver):
    """Log in once for the whole navigation module."""
    driver.reset_app()
    time.sleep(3)
    login = LoginPage(driver)
    if login.is_on_login_page(timeout=5):
        login.login(VALID_EMAIL, VALID_PASSWORD)
    HomePage(driver).is_on_home(timeout=30)
    yield


@pytest.mark.category("Functional Testing")
class TestBottomNavigation:

    @pytest.fixture(autouse=True)
    def ensure_home(self, driver):
        """Return to Home before each nav test."""
        HomePage(driver).tap_nav_home()
        time.sleep(1)

    def test_nav_to_battle_tab(self, driver):
        """TC-NAV-01 – Bottom nav → Battle opens Battle tab."""
        HomePage(driver).tap_nav_battle()
        time.sleep(1.5)
        assert BattlePage(driver).is_on_battle_selection(timeout=15)

    def test_nav_to_problems_tab(self, driver):
        """TC-NAV-02 – Bottom nav → Problems opens Problems tab."""
        HomePage(driver).tap_nav_problems()
        time.sleep(1.5)
        assert ProblemsPage(driver).is_on_problems(timeout=15)

    def test_nav_to_leaderboard_tab(self, driver):
        """TC-NAV-03 – Bottom nav → Leaderboard opens Leaderboard tab."""
        HomePage(driver).tap_nav_leaderboard()
        time.sleep(1.5)
        assert LeaderboardPage(driver).is_on_leaderboard(timeout=15)

    def test_nav_to_profile_tab(self, driver):
        """TC-NAV-04 – Bottom nav → Profile opens Profile tab."""
        HomePage(driver).tap_nav_profile()
        time.sleep(1.5)
        assert ProfilePage(driver).is_on_profile(timeout=15)

    def test_profile_to_home_via_nav(self, driver):
        """TC-NAV-05 – Tapping HOME from Profile returns to Home."""
        home = HomePage(driver)
        home.tap_nav_profile()
        time.sleep(1)
        home.tap_nav_home()
        time.sleep(1)
        assert home.is_on_home(timeout=15)

    def test_back_at_home_no_crash(self, driver):
        """TC-NAV-06 – Android back button at Home does not crash the app."""
        driver.back()
        time.sleep(1)
        home = HomePage(driver)
        alive = home.is_on_home(timeout=5) or home.is_text_visible("DEVDUEL", timeout=5)
        assert alive, "App appears to have crashed after back on Home"

    def test_home_find_battle_opens_battle_tab(self, driver):
        """TC-NAV-07 – FIND BATTLE card on Home opens Battle tab."""
        home = HomePage(driver)
        home.scroll_down()
        time.sleep(0.5)
        home.tap_find_battle()
        time.sleep(2)
        assert BattlePage(driver).is_on_battle_selection(timeout=15)

    def test_home_solve_now_opens_problems_tab(self, driver):
        """TC-NAV-08 – SOLVE NOW button on Home opens Problems tab."""
        home = HomePage(driver)
        home.tap_nav_home()
        time.sleep(1)
        home.scroll_up()
        time.sleep(0.5)
        home.tap_solve_now()
        time.sleep(2)
        assert ProblemsPage(driver).is_on_problems(timeout=15)
