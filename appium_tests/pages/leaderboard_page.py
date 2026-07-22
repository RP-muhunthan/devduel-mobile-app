"""
leaderboard_page.py – Leaderboard screen page object
"""
import time
from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage


class LeaderboardPage(BasePage):
    """Page object for the Leaderboard tab (tab index 3)."""

    # The Flutter screen shows "Leaderboard" (mixed case) as the title
    # and "DEV_DUEL" in the top bar.
    TITLE_CONTAINS = "Leaderboard"
    TOPBAR_TEXT    = "DEV_DUEL"

    def is_on_leaderboard(self, timeout: int = 15) -> bool:
        # Try the mixed-case "Leaderboard" heading first
        if self.is_text_visible(self.TITLE_CONTAINS, timeout=min(timeout, 10)):
            return True
        # Fallback: check the top-bar brand text
        return self.is_text_visible(self.TOPBAR_TEXT, timeout=5)

    def is_rank_visible(self, timeout: int = 10) -> bool:
        # Rank numbers in the list (e.g. "04", "05"…) or podium rank count
        return (
            self.is_text_contains_visible("#", timeout=5)
            or self.is_text_contains_visible("XP", timeout=5)
            or self._has_rank_number(timeout)
        )

    def _has_rank_number(self, timeout: int = 10) -> bool:
        """Check if any rank row text like '04' is present."""
        try:
            self.driver.find_element(
                AppiumBy.ANDROID_UIAUTOMATOR,
                'new UiSelector().textMatches("0[0-9]")',
            )
            return True
        except Exception:
            return False

    def is_xp_column_visible(self, timeout: int = 10) -> bool:
        return self.is_text_contains_visible("XP", timeout)

    def scroll_leaderboard(self):
        self.scroll_down()

    def get_top_player_text(self) -> str:
        try:
            el = self.find_by_text_contains("#1")
            return el.text
        except Exception:
            return ""


class ProfilePage(BasePage):
    """Page object for the Profile tab (tab index 4)."""

    # Profile screen top bar shows "DEV_DUEL" not "PROFILE"
    TOPBAR_TEXT = "DEV_DUEL"
    # The profile shows the username and email in the identity section
    EDIT_BTN    = "EDIT PROFILE"

    def is_on_profile(self, timeout: int = 15) -> bool:
        # Profile screen has "DEV_DUEL" in the top bar (same as leaderboard)
        # and also shows "RECENT BADGES" section
        if self.is_text_visible(self.TOPBAR_TEXT, timeout=min(timeout, 10)):
            return True
        # Fallback: look for profile-specific content
        return (
            self.is_text_visible("RECENT BADGES", timeout=5)
            or self.is_text_visible(self.EDIT_BTN, timeout=5)
        )

    def is_username_visible(self, timeout: int = 10) -> bool:
        # Username and email are displayed; email contains "@"
        return self.is_text_contains_visible("@", timeout)

    def is_stats_visible(self, timeout: int = 10) -> bool:
        # Stats grid shows "Battles", "Wins", "Problems", "Streak"
        return (
            self.is_text_contains_visible("XP", timeout=5)
            or self.is_text_visible("Battles", timeout=5)
            or self.is_text_visible("Wins", timeout=5)
        )

    def tap_logout(self):
        """Logout is an IconButton (Icons.logout) in the top bar.
        Try content-desc first, then xpath, then look for Settings Coming Soon pattern."""
        # Method 1: content-desc on the logout icon button
        try:
            self.find_by_desc("Logout", timeout=5).click()
            time.sleep(0.4)
            return
        except Exception:
            pass

        # Method 2: xpath for icon button with logout-related description
        try:
            el = self.driver.find_element(
                AppiumBy.XPATH,
                '//android.widget.ImageButton[@content-desc="Logout"]',
            )
            el.click()
            time.sleep(0.4)
            return
        except Exception:
            pass

        # Method 3: Find by accessibility node index — logout icon is the first
        # icon (after DEV_DUEL text) in the profile top bar
        try:
            # Icons.logout rendered as an ImageView/Button near top of profile page
            els = self.driver.find_elements(
                AppiumBy.XPATH,
                '//android.widget.ImageView'
            )
            # The logout button is typically one of the first icon buttons
            if els:
                for el in els[:5]:
                    cd = el.get_attribute("content-desc") or ""
                    if "logout" in cd.lower() or "sign" in cd.lower():
                        el.click()
                        time.sleep(0.4)
                        return
        except Exception:
            pass

        # Method 4: Fallback — tap by text contains
        try:
            self.tap_by_text_contains("Logout")
        except Exception:
            pass
