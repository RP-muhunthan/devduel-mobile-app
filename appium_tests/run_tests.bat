@echo off
REM ============================================================
REM  DevDuel Mobile – Appium E2E Test Runner (Windows)
REM  Run from the project root or from appium_tests\ directory
REM ============================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo.
echo ============================================================
echo   DevDuel Mobile — Appium E2E Test Suite
echo ============================================================
echo.

REM ── 1. Check Python ──────────────────────────────────────────
where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Please install Python 3.9+
    pause
    exit /b 1
)
echo [OK] Python found

REM ── 2. Check Appium ──────────────────────────────────────────
where appium >nul 2>&1
if errorlevel 1 (
    echo [WARN] Appium not found in PATH. Make sure appium server is running manually.
) else (
    echo [OK] Appium found
)

REM ── 3. Install dependencies ───────────────────────────────────
echo.
echo [*] Installing Python dependencies...
pip install -r requirements.txt -q
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)
echo [OK] Dependencies installed

REM ── 4. Create reports directory ──────────────────────────────
if not exist "reports" mkdir reports
if not exist "reports\screenshots" mkdir reports\screenshots
echo [OK] Reports directory ready

REM ── 5. Create .env if missing ────────────────────────────────
if not exist ".env" (
    echo [WARN] .env not found. Copying from .env.example...
    copy ".env.example" ".env" >nul
    echo [WARN] Please update .env with your device and credentials before running!
    pause
)

echo.
echo ============================================================
echo   Starting Test Run...
echo ============================================================
echo.

REM ── 6. Run tests ─────────────────────────────────────────────
set "TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"

python -m pytest tests\ ^
    --tb=short ^
    -v ^
    --html="reports\pytest_report_%TIMESTAMP%.html" ^
    --self-contained-html ^
    2>&1

set "EXIT_CODE=%errorlevel%"

echo.
echo ============================================================
echo   Test Run Complete
echo   Exit Code: %EXIT_CODE%
echo   Reports saved in: %SCRIPT_DIR%reports\
echo ============================================================
echo.

if %EXIT_CODE% == 0 (
    echo [SUCCESS] All tests passed!
) else (
    echo [WARNING] Some tests failed. Check the reports directory.
)

pause
exit /b %EXIT_CODE%
