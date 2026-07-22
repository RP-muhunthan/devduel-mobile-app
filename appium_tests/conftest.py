"""
conftest.py – Shared Appium fixtures for DevDuel E2E tests
==========================================================
Starts / tears down the Appium driver once per session and once per module.
Also sets up the Excel report writer that each test populates.
"""

import os
import time
import datetime
import pytest

from appium import webdriver
from appium.options.android.uiautomator2.base import UiAutomator2Options
from dotenv import load_dotenv

from utils.excel_reporter import ExcelReporter, ResultRecord

# ── Load environment variables ────────────────────────────────────────────────
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), ".env"))


def _get_options() -> UiAutomator2Options:
    """Build Appium desired-capabilities from the .env file."""
    options = UiAutomator2Options()
    options.device_name       = os.getenv("DEVICE_NAME",       "emulator-5554")
    options.udid              = os.getenv("DEVICE_NAME",       "emulator-5554")
    options.platform_version  = os.getenv("PLATFORM_VERSION",  "14.0")
    options.app_package       = os.getenv("APP_PACKAGE",       "com.example.devduel_mobile")
    options.app_activity      = os.getenv("APP_ACTIVITY",      ".MainActivity")

    app_path = os.getenv("APP_PATH", "").strip()
    if app_path:
        options.app = app_path

    options.no_reset         = True   # keep app state between tests
    options.full_reset       = False
    options.auto_grant_permissions = True
    return options


# ── Session-level driver ──────────────────────────────────────────────────────
@pytest.fixture(scope="session")
def driver():
    """Single WebDriver session shared across the whole test run."""
    host = os.getenv("APPIUM_HOST", "127.0.0.1")
    port = os.getenv("APPIUM_PORT", "4723")
    url  = f"http://{host}:{port}"

    drv = webdriver.Remote(url, options=_get_options())
    drv.implicitly_wait(int(os.getenv("IMPLICIT_WAIT", "10")))

    # Clear app data ONCE at the very beginning of the test suite run to ensure a clean slate
    app_package = os.getenv("APP_PACKAGE", "com.example.devduel_mobile")
    try:
        drv.execute_script('mobile: clearApp', {'appId': app_package})
    except Exception:
        pass

    # Attach a custom helper to restart the app without killing the UiAutomator2 session
    def reset_app():
        try:
            # Gracefully terminate the app (keeps UiAutomator2 server alive)
            drv.terminate_app(app_package)
            time.sleep(1)
        except Exception:
            pass  # App may already be stopped – that's fine
        # Re-launch the app
        drv.activate_app(app_package)
        time.sleep(2)

    drv.reset_app = reset_app
    yield drv
    drv.quit()


# ── Module-level driver (fresh app state per test file) ──────────────────────
@pytest.fixture(scope="module")
def module_driver(driver):
    """Resets the app to a clean state at the start of every test module."""
    driver.reset_app()
    yield driver


# ── Excel reporter (session-level singleton) ──────────────────────────────────
@pytest.fixture(scope="session")
def excel_reporter():
    """Creates one ExcelReporter and finalises the workbook at session end."""
    reporter = ExcelReporter()
    yield reporter
    reporter.save()


# ── Per-test result hook ──────────────────────────────────────────────────────
@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    """
    Capture pass/fail for each test phase so fixtures can read it via
    ``request.node.rep_call``.
    """
    outcome = yield
    rep = outcome.get_result()
    setattr(item, f"rep_{rep.when}", rep)


# ── Global test recorder fixture ──────────────────────────────────────────────
@pytest.fixture(autouse=True)
def _global_record(request, excel_reporter):
    """Automatically logs the result of every test in the suite to ExcelReporter."""
    start = time.time()
    yield
    status = "PASS"
    error = ""
    ss = ""

    # Check if 'driver' fixture is requested and loaded
    driver = None
    if "driver" in request.fixturenames:
        try:
            driver = request.getfixturevalue("driver")
        except Exception:
            pass

    # Read test outcomes (setup and call phases)
    rep_setup = getattr(request.node, "rep_setup", None)
    rep_call = getattr(request.node, "rep_call", None)
    rep_teardown = getattr(request.node, "rep_teardown", None)

    if (rep_setup and rep_setup.failed) or (rep_call and rep_call.failed) or (rep_teardown and rep_teardown.failed):
        status = "FAIL"
        if rep_setup and rep_setup.failed:
            error = str(rep_setup.longrepr)[:300] if rep_setup.longrepr else "Setup failed"
        elif rep_call and rep_call.failed:
            error = str(rep_call.longrepr)[:300] if rep_call.longrepr else "Execution failed"
        else:
            error = str(rep_teardown.longrepr)[:300] if rep_teardown.longrepr else "Teardown failed"

        # Capture screenshot for mobile failures
        if driver:
            try:
                ss_dir = os.path.join(
                    os.path.dirname(__file__), "reports", "screenshots"
                )
                os.makedirs(ss_dir, exist_ok=True)
                ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                ss = os.path.join(ss_dir, f"{request.node.name}_{ts}.png")
                driver.save_screenshot(ss)
            except Exception:
                pass
    elif rep_call and rep_call.skipped:
        status = "SKIP"

    # Category classification from marks or default
    category = "Functional Testing"
    for marker in request.node.iter_markers(name="category"):
        if marker.args:
            category = marker.args[0]
            break

    module = getattr(request.module, "MODULE", "00 – General")

    excel_reporter.add_result(ResultRecord(
        test_id=request.node.name,
        name=request.node.name.replace("_", " ").title(),
        module=module,
        status=status,
        duration_sec=time.time() - start,
        error_msg=error,
        screenshot_path=ss,
        category=category,
    ))
