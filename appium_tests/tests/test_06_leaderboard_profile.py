"""
test_06_leaderboard_profile.py – Leaderboard & Profile E2E tests
"""

import os
import time
import datetime
import pytest

from pages import LoginPage, HomePage, LeaderboardPage, ProfilePage
from utils import ExcelReporter, ResultRecord

MODULE         = "06 – Leaderboard & Profile"
VALID_EMAIL    = os.getenv("TEST_EMAIL",    "testuser@devduel.com")
VALID_PASSWORD = os.getenv("TEST_PASSWORD", "Test@1234")
APP_PACKAGE    = os.getenv("APP_PACKAGE",   "com.example.devduel_mobile")


@pytest.fixture(scope="module", autouse=True)
def login_once(driver):
    """Log in once for the whole module."""
    driver.reset_app()
    time.sleep(3)
    login = LoginPage(driver)
    if login.is_on_login_page(timeout=5):
        login.login(VALID_EMAIL, VALID_PASSWORD)
    HomePage(driver).is_on_home(timeout=30)
    yield


@pytest.mark.category("Functional Testing")
class TestLeaderboard:

    @pytest.fixture(autouse=True)
    def open_leaderboard(self, driver):
        HomePage(driver).tap_nav_leaderboard()
        time.sleep(2)

    def test_leaderboard_tab_opens(self, driver):
        """TC-LB-01 – Leaderboard tab renders 'LEADERBOARD' header."""
        assert LeaderboardPage(driver).is_on_leaderboard(timeout=15)

    def test_leaderboard_shows_ranks(self, driver):
        """TC-LB-02 – At least one rank number (#) is displayed."""
        assert LeaderboardPage(driver).is_rank_visible(timeout=10)

    def test_leaderboard_xp_column_visible(self, driver):
        """TC-LB-03 – XP values are displayed on the Leaderboard."""
        assert LeaderboardPage(driver).is_xp_column_visible(timeout=10)

    def test_leaderboard_scroll(self, driver):
        """TC-LB-04 – Scrolling the leaderboard does not crash the app."""
        lb = LeaderboardPage(driver)
        lb.scroll_leaderboard()
        time.sleep(1)
        assert lb.is_on_leaderboard(timeout=5)


@pytest.mark.category("Functional Testing")
class TestProfile:

    @pytest.fixture(autouse=True)
    def open_profile(self, driver):
        HomePage(driver).tap_nav_profile()
        time.sleep(2)

    def test_profile_tab_opens(self, driver):
        """TC-PROF-01 – Profile tab renders 'PROFILE' header."""
        assert ProfilePage(driver).is_on_profile(timeout=15)

    def test_profile_username_visible(self, driver):
        """TC-PROF-02 – Username / email handle visible on profile."""
        assert ProfilePage(driver).is_username_visible(timeout=10)

    def test_profile_stats_visible(self, driver):
        """TC-PROF-03 – XP / stats section is visible on profile."""
        assert ProfilePage(driver).is_stats_visible(timeout=10)

    def test_profile_logout_redirects_to_login(self, driver):
        """TC-PROF-04 – Tapping Logout navigates back to the Login screen."""
        ProfilePage(driver).tap_logout()
        assert LoginPage(driver).is_on_login_page(timeout=20), \
            "Login screen did not appear after logout"
