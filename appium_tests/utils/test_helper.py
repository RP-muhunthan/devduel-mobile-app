"""
test_helper.py – Shared test utilities (timing, result recording, screenshot on fail)
"""

import os
import time
import functools
from utils.excel_reporter import ResultRecord


def record_test(module: str):
    """
    Decorator that:
      1. Times the test.
      2. Takes a screenshot on failure.
      3. Records a ResultRecord to the session-level excel_reporter.

    Usage::

        @record_test("Authentication")
        def test_login_valid(driver, excel_reporter):
            ...
    """
    def decorator(test_fn):
        @functools.wraps(test_fn)
        def wrapper(*args, **kwargs):
            reporter = kwargs.get("excel_reporter") or (args[1] if len(args) > 1 else None)
            drv      = kwargs.get("driver")         or (args[0] if args else None)

            start     = time.time()
            status    = "PASS"
            error_msg = ""
            ss_path   = ""
            try:
                test_fn(*args, **kwargs)
            except Exception as exc:
                status    = "FAIL"
                error_msg = str(exc)
                if drv:
                    try:
                        ts      = time.strftime("%Y%m%d_%H%M%S")
                        ss_dir  = os.path.join(
                            os.path.dirname(os.path.dirname(__file__)), "reports", "screenshots"
                        )
                        os.makedirs(ss_dir, exist_ok=True)
                        ss_path = os.path.join(ss_dir, f"{test_fn.__name__}_{ts}.png")
                        drv.save_screenshot(ss_path)
                    except Exception:
                        pass
                raise
            finally:
                duration = time.time() - start
                if reporter:
                    reporter.add_result(ResultRecord(
                        test_id        = test_fn.__name__,
                        name           = test_fn.__doc__ or test_fn.__name__,
                        module         = module,
                        status         = status,
                        duration_sec   = duration,
                        error_msg      = error_msg,
                        screenshot_path= ss_path,
                    ))
        return wrapper
    return decorator
