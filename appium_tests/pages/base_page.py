"""
base_page.py – Base Page Object for all DevDuel screens
========================================================
Provides common Appium helper methods (find, tap, type, scroll, wait, screenshot).
"""

import os
import time
import datetime

from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import (
    TimeoutException,
    NoSuchElementException,
    ElementNotInteractableException,
)


EXPLICIT_WAIT = int(os.getenv("EXPLICIT_WAIT", "20"))
SCREENSHOTS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "reports", "screenshots")
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)


class BasePage:
    """Abstract base class every page object inherits from."""

    def __init__(self, driver):
        self.driver = driver

    # ── Wait helpers ──────────────────────────────────────────────────────────

    def _wait(self, timeout: int = EXPLICIT_WAIT) -> WebDriverWait:
        return WebDriverWait(self.driver, timeout)

    def wait_for_element(self, by, value, timeout: int = EXPLICIT_WAIT):
        return self._wait(timeout).until(
            EC.presence_of_element_located((by, value))
        )

    def wait_for_visible(self, by, value, timeout: int = EXPLICIT_WAIT):
        return self._wait(timeout).until(
            EC.visibility_of_element_located((by, value))
        )

    def wait_for_clickable(self, by, value, timeout: int = EXPLICIT_WAIT):
        return self._wait(timeout).until(
            EC.element_to_be_clickable((by, value))
        )

    # ── Flutter / Accessibility locators ─────────────────────────────────────

    def find_by_text(self, text: str, timeout: int = EXPLICIT_WAIT):
        """Locate element by exact visible text or content-desc."""
        xpath = f"//*[@text='{text}' or @content-desc='{text}']"
        return self.wait_for_element(AppiumBy.XPATH, xpath, timeout)

    def find_by_text_contains(self, partial: str, timeout: int = EXPLICIT_WAIT):
        """Locate element by partial visible text or content-desc."""
        xpath = f"//*[contains(@text, '{partial}') or contains(@content-desc, '{partial}')]"
        return self.wait_for_element(AppiumBy.XPATH, xpath, timeout)

    def find_by_desc(self, desc: str, timeout: int = EXPLICIT_WAIT):
        """Locate by content-desc (accessibility label)."""
        return self.wait_for_element(
            AppiumBy.ANDROID_UIAUTOMATOR,
            f'new UiSelector().description("{desc}")',
            timeout,
        )

    def find_by_class(self, cls: str, index: int = 0):
        return self.driver.find_elements(AppiumBy.CLASS_NAME, cls)[index]

    def find_by_xpath(self, xpath: str, timeout: int = EXPLICIT_WAIT):
        return self.wait_for_element(AppiumBy.XPATH, xpath, timeout)

    # ── Interaction helpers ───────────────────────────────────────────────────

    def tap(self, element):
        element.click()
        time.sleep(0.4)

    def type_text(self, element, text: str, clear: bool = True):
        if clear:
            element.clear()
        element.send_keys(text)
        time.sleep(0.3)

    def tap_by_text(self, text: str):
        self.tap(self.find_by_text(text))

    def tap_by_text_contains(self, partial: str):
        self.tap(self.find_by_text_contains(partial))

    def is_text_visible(self, text: str, timeout: int = 5) -> bool:
        try:
            self.find_by_text(text, timeout)
            return True
        except (TimeoutException, NoSuchElementException):
            return False

    def is_text_contains_visible(self, partial: str, timeout: int = 5) -> bool:
        try:
            self.find_by_text_contains(partial, timeout)
            return True
        except (TimeoutException, NoSuchElementException):
            return False

    # ── Scroll helpers ────────────────────────────────────────────────────────

    def scroll_down(self):
        size = self.driver.get_window_size()
        w, h = size["width"], size["height"]
        self.driver.swipe(w // 2, int(h * 0.75), w // 2, int(h * 0.25), 600)
        time.sleep(0.5)

    def scroll_up(self):
        size = self.driver.get_window_size()
        w, h = size["width"], size["height"]
        self.driver.swipe(w // 2, int(h * 0.25), w // 2, int(h * 0.75), 600)
        time.sleep(0.5)

    def scroll_to_text(self, text: str):
        try:
            self.driver.find_element(
                AppiumBy.ANDROID_UIAUTOMATOR,
                f'new UiScrollable(new UiSelector().scrollable(true))'
                f'.scrollIntoView(new UiSelector().description("{text}"))',
            )
        except Exception:
            self.driver.find_element(
                AppiumBy.ANDROID_UIAUTOMATOR,
                f'new UiScrollable(new UiSelector().scrollable(true))'
                f'.scrollIntoView(new UiSelector().text("{text}"))',
            )

    # ── Screenshot helper ─────────────────────────────────────────────────────

    def screenshot(self, name: str = "screenshot") -> str:
        ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        path = os.path.join(SCREENSHOTS_DIR, f"{name}_{ts}.png")
        self.driver.save_screenshot(path)
        return path

    # ── Navigation helpers ────────────────────────────────────────────────────

    def tap_back(self):
        self.driver.back()
        time.sleep(0.5)

    def press_home(self):
        self.driver.press_keycode(3)  # HOME key

    # ── Bottom nav helper ─────────────────────────────────────────────────────

    def tap_nav_tab(self, label: str):
        """Tap a bottom-nav tab by its uppercased label text."""
        self.tap_by_text(label.upper())
