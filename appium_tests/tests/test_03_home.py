"""
test_03_home.py – Home Dashboard E2E tests
===========================================
Uses the session-scoped `driver` fixture directly (no local wrapper).
"""

import os
import time
import datetime
import pytest

from pages import LoginPage, HomePage
from utils import ExcelReporter, ResultRecord

MODULE         = "03 – Home Dashboard"
VALID_EMAIL    = os.getenv("TEST_EMAIL",    "testuser@devduel.com")
VALID_PASSWORD = os.getenv("TEST_PASSWORD", "Test@1234")
APP_PACKAGE    = os.getenv("APP_PACKAGE",   "com.example.devduel_mobile")


@pytest.fixture(scope="module", autouse=True)
def login_once(driver):
    """Log in once at module start; all Home tests share the session."""
    driver.reset_app()
    time.sleep(3)
    login = LoginPage(driver)
    if login.is_on_login_page(timeout=5):
        login.login(VALID_EMAIL, VALID_PASSWORD)
    home = HomePage(driver)
    home.is_on_home(timeout=30)
    yield


@pytest.mark.category("Functional Testing")
class TestHomeDashboard:

    def test_home_loads_with_greeting(self, driver):
        """TC-HOME-01 – Home screen shows personalised greeting."""
        home = HomePage(driver)
        assert home.is_greeting_visible(timeout=20), \
            "Greeting not found on Home"

    def test_xp_card_visible(self, driver):
        """TC-HOME-02 – XP / Level card is rendered."""
        home = HomePage(driver)
        assert home.is_xp_visible(), "XP card not visible"

    def test_streak_card_visible(self, driver):
        """TC-HOME-03 – Streak card is rendered."""
        home = HomePage(driver)
        assert home.is_streak_visible(), "Streak card not visible"

    def test_daily_challenge_card_visible(self, driver):
        """TC-HOME-04 – Daily Challenge card is shown."""
        home = HomePage(driver)
        assert home.is_daily_challenge_visible(), "Daily Challenge not visible"

    def test_find_battle_card_visible(self, driver):
        """TC-HOME-05 – Home screen is still active (FIND BATTLE visible)."""
        home = HomePage(driver)
        assert home.is_on_home(timeout=10), "Home screen not active"

    def test_recent_activity_visible(self, driver):
        """TC-HOME-06 – Recent Activity section is rendered."""
        home = HomePage(driver)
        home.scroll_down()
        time.sleep(1)
        assert home.is_recent_activity_visible(), "RECENT ACTIVITY not visible"

    def test_bottom_nav_all_tabs_visible(self, driver):
        """TC-HOME-07 – All 5 bottom navigation tabs are rendered."""
        home = HomePage(driver)
        home.scroll_up()
        time.sleep(1)
        for tab in ["HOME", "BATTLE", "PROBLEMS", "LEADERBOARD", "PROFILE"]:
            assert home.is_text_visible(tab, timeout=10), f"Tab '{tab}' not found"

    def test_solve_now_navigates_to_problems(self, driver):
        """TC-HOME-08 – Tapping SOLVE NOW opens Problems tab."""
        home = HomePage(driver)
        home.scroll_up()
        time.sleep(0.5)
        home.tap_solve_now()
        time.sleep(1)
        from pages import ProblemsPage
        problems = ProblemsPage(driver)
        assert problems.is_on_problems(timeout=15), "Problems tab did not open"
        home.tap_nav_home()
        time.sleep(1)
