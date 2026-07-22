"""
problems_page.py – Problems screen page object
===============================================
Matches the ProblemsScreen widget.
"""
import time
from .base_page import BasePage


class ProblemsPage(BasePage):
    """Page object for the Problems tab (tab index 2), which is now a Daily Challenge Arena."""

    CHALLENGE_TITLE = "CHALLENGE"
    PROBLEM_NAME    = "Median of Two Sorted Arrays"
    RUN_CODE_BTN    = "RUN CODE"
    SUBMIT_BTN      = "SUBMIT"
    CODE_TAB        = "CODE"
    TEST_CASES_TAB  = "TEST CASES"

    def is_on_problems(self, timeout: int = 15) -> bool:
        return self.is_text_visible(self.PROBLEM_NAME, timeout)

    def is_problem_title_visible(self, timeout: int = 10) -> bool:
        return self.is_text_visible(self.PROBLEM_NAME, timeout)

    def tap_run_code(self):
        self.tap_by_text(self.RUN_CODE_BTN)

    def tap_submit(self):
        self.tap_by_text(self.SUBMIT_BTN)

    def tap_test_cases_tab(self):
        self.tap_by_text(self.TEST_CASES_TAB)

    def is_test_passed_toast_visible(self, timeout: int = 10) -> bool:
        # Check for the snackbar text
        return self.is_text_visible("Code executed successfully", timeout)

    def is_victory_dialog_visible(self, timeout: int = 15) -> bool:
        return self.is_text_visible("VICTORY!", timeout)

    def tap_return_to_lobby(self):
        self.tap_by_text("RETURN TO LOBBY")
