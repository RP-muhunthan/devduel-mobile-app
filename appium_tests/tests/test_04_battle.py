"""
test_04_battle.py – Battle / Arena E2E tests
"""

import os
import time
import datetime
import pytest

from pages import LoginPage, HomePage, BattlePage
from utils import ExcelReporter, ResultRecord

MODULE         = "04 – Battle Arena"
VALID_EMAIL    = os.getenv("TEST_EMAIL",    "testuser@devduel.com")
VALID_PASSWORD = os.getenv("TEST_PASSWORD", "Test@1234")
APP_PACKAGE    = os.getenv("APP_PACKAGE",   "com.example.devduel_mobile")


@pytest.fixture(scope="module", autouse=True)
def login_and_nav_battle(driver):
    """Log in once and navigate to Battle tab for this module."""
    driver.reset_app()
    time.sleep(3)
    login = LoginPage(driver)
    if login.is_on_login_page(timeout=5):
        login.login(VALID_EMAIL, VALID_PASSWORD)
    home = HomePage(driver)
    home.is_on_home(timeout=30)
    home.tap_nav_battle()
    time.sleep(2)
    yield
    # Return to home after module
    try:
        home.tap_nav_home()
        time.sleep(1)
    except Exception:
        pass


@pytest.mark.category("End-to-End (E2E) Testing")
class TestBattleSelection:

    @pytest.fixture(autouse=True)
    def ensure_on_battle(self, driver):
        """Ensure we're on Battle selection screen before each test."""
        battle = BattlePage(driver)
        if battle.is_in_arena(timeout=3):
            battle.tap_back_from_arena()
            time.sleep(2)
        if not battle.is_on_battle_selection(timeout=5):
            HomePage(driver).tap_nav_battle()
            time.sleep(2)
        yield

    def test_battle_tab_opens_selection_ui(self, driver):
        """TC-BATTLE-01 – Battle tab shows the battle selection UI."""
        assert BattlePage(driver).is_on_battle_selection(timeout=15), \
            "Battle selection UI not visible"

    def test_difficulty_chips_visible(self, driver):
        """TC-BATTLE-02 – All four difficulty chips are rendered."""
        battle = BattlePage(driver)
        for chip in ["Easy", "Medium", "Hard", "Random"]:
            assert battle.is_text_visible(chip, timeout=10), f"Chip '{chip}' not found"

    def test_topic_chips_visible(self, driver):
        """TC-BATTLE-03 – All six topic chips are rendered."""
        battle = BattlePage(driver)
        for topic in ["All", "Arrays", "Trees", "DP", "Graphs", "Strings"]:
            assert battle.is_text_visible(topic, timeout=10), f"Topic '{topic}' not found"

    def test_select_easy_difficulty(self, driver):
        """TC-BATTLE-04 – Tapping 'Easy' chip works without crash."""
        BattlePage(driver).select_difficulty("Easy")
        assert BattlePage(driver).is_on_battle_selection(timeout=5)

    def test_select_hard_difficulty(self, driver):
        """TC-BATTLE-05 – Tapping 'Hard' chip works without crash."""
        BattlePage(driver).select_difficulty("Hard")
        assert BattlePage(driver).is_on_battle_selection(timeout=5)

    def test_find_battle_shows_searching_ui(self, driver):
        """TC-BATTLE-06 – Tapping FIND BATTLE shows the Searching overlay."""
        battle = BattlePage(driver)
        battle.select_difficulty("Medium")
        battle.tap_find_battle()
        assert battle.is_searching(timeout=15), "Searching UI did not appear"
        # Cancel so the next test starts clean
        battle.tap_cancel_search()
        time.sleep(2)

    def test_cancel_search_returns_to_selection(self, driver):
        """TC-BATTLE-07 – Tapping CANCEL SEARCH returns to Selection UI."""
        battle = BattlePage(driver)
        battle.tap_find_battle()
        battle.is_searching(timeout=10)
        battle.tap_cancel_search()
        assert battle.is_on_battle_selection(timeout=15), "Selection UI did not reappear"


@pytest.mark.category("End-to-End (E2E) Testing")
class TestBattleArena:

    @pytest.fixture(autouse=True)
    def enter_arena(self, driver):
        """Enter the arena via the debug button; exit cleanly after each test."""
        battle = BattlePage(driver)
        if battle.is_in_arena(timeout=3):
            battle.tap_back_from_arena()
            time.sleep(2)
        if not battle.is_on_battle_selection(timeout=5):
            HomePage(driver).tap_nav_battle()
            time.sleep(2)
        battle.tap_find_battle()
        battle.is_searching(timeout=10)
        battle.force_enter_arena()
        battle.is_in_arena(timeout=30)
        time.sleep(2)   # let UI settle
        yield
        try:
            if BattlePage(driver).is_in_arena(timeout=3):
                BattlePage(driver).tap_back_from_arena()
                time.sleep(2)
        except Exception:
            pass

    def test_arena_shows_challenge_label(self, driver):
        """TC-BATTLE-08 – Arena top bar shows 'CHALLENGE' label."""
        assert BattlePage(driver).is_in_arena(timeout=10)

    def test_arena_shows_problem_statement(self, driver):
        """TC-BATTLE-09 – Problem Statement section visible in arena."""
        assert BattlePage(driver).is_problem_statement_visible(timeout=15)

    def test_arena_code_tab_default(self, driver):
        """TC-BATTLE-10 – CODE tab is the default active tab."""
        assert BattlePage(driver).is_text_visible("CODE", timeout=10)

    def test_arena_switch_to_test_cases_tab(self, driver):
        """TC-BATTLE-11 – Switching to TEST CASES tab works."""
        BattlePage(driver).tap_test_cases_tab()
        time.sleep(1)
        assert BattlePage(driver).is_text_visible("TEST CASES", timeout=10)

    def test_arena_run_code_button_works(self, driver):
        """TC-BATTLE-12 – Tapping RUN CODE executes and shows test results."""
        battle = BattlePage(driver)
        battle.tap_code_tab()
        time.sleep(1)
        battle.tap_run_code()
        time.sleep(3)  # let UI settle after action
        passed = battle.is_test_passed(timeout=20)
        failed = battle.is_test_failed(timeout=5) if not passed else False
        assert passed or failed, "No test result appeared after RUN CODE"

    def test_arena_submit_button_visible(self, driver):
        """TC-BATTLE-13 – SUBMIT button is visible in the arena."""
        assert BattlePage(driver).is_text_visible("SUBMIT", timeout=10)

    def test_arena_console_button_visible(self, driver):
        """TC-BATTLE-14 – CONSOLE button is visible in the arena."""
        assert BattlePage(driver).is_text_visible("CONSOLE", timeout=10)

    def test_arena_back_exits_to_selection(self, driver):
        """TC-BATTLE-15 – Pressing back exits the arena to selection UI."""
        battle = BattlePage(driver)
        battle.tap_back_from_arena()
        time.sleep(3)  # wait for UI to settle after back nav
        assert battle.is_on_battle_selection(timeout=15)
