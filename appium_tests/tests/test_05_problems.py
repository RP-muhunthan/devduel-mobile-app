"""
test_05_problems.py – Problems screen E2E tests
"""

import os
import time
import datetime
import pytest

from pages import LoginPage, HomePage, ProblemsPage, BattlePage
from utils import ExcelReporter, ResultRecord

MODULE         = "05 – Problems Screen"
VALID_EMAIL    = os.getenv("TEST_EMAIL",    "testuser@devduel.com")
VALID_PASSWORD = os.getenv("TEST_PASSWORD", "Test@1234")
APP_PACKAGE    = os.getenv("APP_PACKAGE",   "com.example.devduel_mobile")
KNOWN_PROBLEM  = "Two Sum"


@pytest.fixture(scope="module", autouse=True)
def login_and_nav_problems(driver):
    """Log in once and navigate to Problems tab for this module."""
    driver.reset_app()
    time.sleep(3)
    login = LoginPage(driver)
    if login.is_on_login_page(timeout=5):
        login.login(VALID_EMAIL, VALID_PASSWORD)
    home = HomePage(driver)
    home.is_on_home(timeout=30)
    home.tap_nav_problems()
    time.sleep(2)
    yield
    try:
        home.tap_nav_home()
        time.sleep(1)
    except Exception:
        pass


@pytest.mark.category("Functional Testing")
class TestProblemsScreen:

    def test_problems_tab_opens_arena(self, driver):
        """TC-PROB-01 – Problems tab renders the Challenge arena directly."""
        prob = ProblemsPage(driver)
        assert prob.is_on_problems(timeout=15), "CHALLENGE header not found"

    def test_problem_statement_visible(self, driver):
        """TC-PROB-02 – The daily challenge problem is visible."""
        prob = ProblemsPage(driver)
        assert prob.is_problem_title_visible(timeout=10), "Problem name not found"

    def test_switch_to_test_cases_tab(self, driver):
        """TC-PROB-03 – Can switch to TEST CASES tab."""
        prob = ProblemsPage(driver)
        prob.tap_test_cases_tab()
        assert prob.is_text_visible("No test cases yet.", timeout=5) or prob.is_text_visible("TEST CASES", timeout=5)

    def test_run_code_executes(self, driver):
        """TC-PROB-04 – Tapping RUN CODE executes and shows success toast."""
        prob = ProblemsPage(driver)
        prob.tap_run_code()
        # The snackbar takes about 2 seconds to appear
        assert prob.is_test_passed_toast_visible(timeout=15), "Success snackbar did not appear after running code"

    def test_submit_shows_victory(self, driver):
        """TC-PROB-05 – Tapping SUBMIT shows VICTORY dialog."""
        prob = ProblemsPage(driver)
        prob.tap_submit()
        assert prob.is_victory_dialog_visible(timeout=15), "Victory dialog did not appear"

    def test_victory_dialog_returns_to_lobby(self, driver):
        """TC-PROB-06 – Returning to lobby from Victory dialog."""
        prob = ProblemsPage(driver)
        prob.tap_return_to_lobby()
        # Should return to Home tab
        home = HomePage(driver)
        assert home.is_on_home(timeout=10), "Did not return to Home lobby"
