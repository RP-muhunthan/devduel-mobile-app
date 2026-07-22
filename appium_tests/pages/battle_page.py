"""
battle_page.py – Battle screen page object
===========================================
Matches the BattleScreen widget (difficulty selection, searching, arena).
"""
import time
from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage


class BattlePage(BasePage):
    """Page object for the Battle tab (tab index 1)."""

    # ── Selection UI text ─────────────────────────────────────────────────────
    TITLE           = "Choose Battle Mode"          # top bar label
    FIND_BATTLE_BTN = "START"
    EASY_CHIP       = "Easy"
    MEDIUM_CHIP     = "Medium"
    HARD_CHIP       = "Hard"
    RANDOM_CHIP     = "Random"

    # Topics
    TOPIC_ALL       = "All"
    TOPIC_ARRAYS    = "Arrays"
    TOPIC_TREES     = "Trees"
    TOPIC_DP        = "DP"
    TOPIC_GRAPHS    = "Graphs"
    TOPIC_STRINGS   = "Strings"

    # ── Searching UI ──────────────────────────────────────────────────────────
    SEARCHING_TEXT  = "SEARCHING FOR OPPONENT"
    CANCEL_SEARCH   = "CANCEL SEARCH"
    FORCE_ARENA_BTN = "DEBUG: FORCE ENTER ARENA"

    # ── Arena UI ──────────────────────────────────────────────────────────────
    CHALLENGE_LABEL = "CHALLENGE"
    RUN_CODE_BTN    = "RUN CODE"
    SUBMIT_BTN      = "SUBMIT"
    CONSOLE_BTN     = "CONSOLE"
    CODE_TAB        = "CODE"
    TEST_CASES_TAB  = "TEST CASES"

    # ── Presence checks ───────────────────────────────────────────────────────

    def is_on_battle_selection(self, timeout: int = 15) -> bool:
        return self.is_text_visible(self.FIND_BATTLE_BTN, timeout)

    def is_searching(self, timeout: int = 15) -> bool:
        return self.is_text_visible(self.SEARCHING_TEXT, timeout)

    def is_in_arena(self, timeout: int = 30) -> bool:
        return self.is_text_visible(self.CHALLENGE_LABEL, timeout)

    # ── Difficulty selection ──────────────────────────────────────────────────

    def select_difficulty(self, difficulty: str):
        """difficulty: 'Easy' | 'Medium' | 'Hard' | 'Random'"""
        self.tap_by_text(difficulty)

    def select_topic(self, topic: str):
        """topic: 'All' | 'Arrays' | 'Trees' | 'DP' | 'Graphs' | 'Strings'"""
        self.tap_by_text(topic)

    # ── Battle flow ───────────────────────────────────────────────────────────

    def tap_find_battle(self):
        self.tap_by_text(self.FIND_BATTLE_BTN)

    def tap_cancel_search(self):
        self.tap_by_text(self.CANCEL_SEARCH)

    def force_enter_arena(self):
        """Use the debug button to skip matchmaking."""
        self.tap_by_text(self.FORCE_ARENA_BTN)

    # ── Arena actions ─────────────────────────────────────────────────────────

    def tap_run_code(self):
        self.tap_by_text(self.RUN_CODE_BTN)

    def tap_submit(self):
        self.tap_by_text(self.SUBMIT_BTN)

    def tap_console(self):
        self.tap_by_text(self.CONSOLE_BTN)

    def tap_code_tab(self):
        self.tap_by_text(self.CODE_TAB)

    def tap_test_cases_tab(self):
        self.tap_by_text(self.TEST_CASES_TAB)

    def tap_back_from_arena(self):
        """Arrow back icon in arena top bar."""
        self.tap_back()

    def enter_code(self, code: str):
        """Type code into the editor TextField."""
        editor = self.driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
        if editor:
            editor[0].clear()
            editor[0].send_keys(code)
            time.sleep(0.5)

    # ── Result checks ─────────────────────────────────────────────────────────

    def is_test_passed(self, timeout: int = 20) -> bool:
        return self.is_text_visible("TEST CASES PASSED", timeout)

    def is_test_failed(self, timeout: int = 10) -> bool:
        return self.is_text_visible("TEST CASES FAILED", timeout)

    def is_victory_dialog_visible(self, timeout: int = 15) -> bool:
        return self.is_text_visible("VICTORY!", timeout)

    def tap_return_to_base(self):
        self.tap_by_text("RETURN TO BASE")

    def is_problem_statement_visible(self, timeout: int = 15) -> bool:
        return self.is_text_visible("Problem Statement", timeout)
