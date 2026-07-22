"""
home_page.py – Home / Dashboard screen page object
====================================================
Matches the HomeScreen + MainScaffold widgets.
"""
from .base_page import BasePage


class HomePage(BasePage):
    """Page object for /home → HomeScreen tab."""

    # ── Known static text labels ──────────────────────────────────────────────
    DAILY_CHALLENGE   = "Matrix Diagonal Sum"
    SOLVE_NOW_BTN     = "SOLVE NOW"
    FIND_BATTLE_BTN   = "FIND BATTLE"
    RECENT_ACTIVITY   = "RECENT ACTIVITY"
    VIEW_ALL_BTN      = "VIEW ALL"
    REPAIR_DB_TOOLTIP = "Repair Database"

    # Bottom nav labels
    NAV_HOME        = "HOME"
    NAV_BATTLE      = "BATTLE"
    NAV_PROBLEMS    = "PROBLEMS"
    NAV_LEADERBOARD = "LEADERBOARD"
    NAV_PROFILE     = "PROFILE"

    # ── Presence check ────────────────────────────────────────────────────────

    def is_on_home(self, timeout: int = 25) -> bool:
        """Home screen shows the Quick Battle card with FIND BATTLE."""
        return self.is_text_visible(self.FIND_BATTLE_BTN, timeout)

    def is_greeting_visible(self, timeout: int = 15) -> bool:
        return self.is_text_contains_visible("Good morning", timeout) or \
               self.is_text_contains_visible("Good evening", timeout) or \
               self.is_text_contains_visible("Good afternoon", timeout)

    # ── Cards & Actions ───────────────────────────────────────────────────────

    def tap_solve_now(self):
        self.tap_by_text(self.SOLVE_NOW_BTN)

    def tap_find_battle(self):
        self.tap_by_text(self.FIND_BATTLE_BTN)

    def tap_logout(self):
        """Logout icon is in the top bar."""
        # The logout IconButton has no text; use the description set by Flutter.
        # Fallback: long-press the icon area or look for logout text if it exists.
        try:
            self.find_by_desc("Logout").click()
        except Exception:
            # Try content-desc fallback
            self.find_by_xpath(
                '//android.widget.ImageButton[@content-desc="Logout"]'
            ).click()

    def tap_repair_db(self):
        self.find_by_desc(self.REPAIR_DB_TOOLTIP).click()

    def tap_nav_home(self):
        self.tap_by_text(self.NAV_HOME)

    def tap_nav_battle(self):
        self.tap_by_text(self.NAV_BATTLE)

    def tap_nav_problems(self):
        self.tap_by_text(self.NAV_PROBLEMS)

    def tap_nav_leaderboard(self):
        self.tap_by_text(self.NAV_LEADERBOARD)

    def tap_nav_profile(self):
        self.tap_by_text(self.NAV_PROFILE)

    # ── Stats ─────────────────────────────────────────────────────────────────

    def is_xp_visible(self) -> bool:
        return self.is_text_contains_visible("XP", timeout=10)

    def is_streak_visible(self) -> bool:
        return self.is_text_contains_visible("Streak", timeout=10)

    def is_daily_challenge_visible(self) -> bool:
        return self.is_text_visible(self.DAILY_CHALLENGE, timeout=10)

    def is_recent_activity_visible(self) -> bool:
        return self.is_text_visible(self.RECENT_ACTIVITY, timeout=10)
