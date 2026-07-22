# DevDuel Mobile – Appium E2E Test Suite

End-to-end automated tests for the **DevDuel Android mobile app**, built with
**Python + Appium 2.x + pytest**.  
Tests cover every screen and generate a rich **Excel analysis report** plus an
HTML pytest report automatically after every run.

---

## 📁 Folder Structure

```
appium_tests/
├── conftest.py                  # Session fixtures (driver, excel_reporter)
├── pytest.ini                   # Pytest configuration
├── requirements.txt             # Python dependencies
├── .env.example                 # Configuration template → copy to .env
├── run_tests.bat                # One-click Windows runner
├── run_tests.sh                 # One-click Linux/macOS runner
│
├── pages/                       # Page Object Model (POM)
│   ├── __init__.py
│   ├── base_page.py             # Shared helpers (find, tap, scroll, wait)
│   ├── splash_page.py
│   ├── login_page.py
│   ├── register_page.py
│   ├── home_page.py
│   ├── battle_page.py
│   ├── problems_page.py
│   └── leaderboard_page.py      # Also contains ProfilePage
│
├── tests/                       # Test modules (ordered by flow)
│   ├── test_01_splash.py        # 3  tests – Splash screen
│   ├── test_02_auth.py          # 11 tests – Login & Registration
│   ├── test_03_home.py          # 8  tests – Home Dashboard
│   ├── test_04_battle.py        # 15 tests – Battle Selection + Arena
│   ├── test_05_problems.py      # 10 tests – Problems list & search
│   ├── test_06_leaderboard_profile.py  # 8 tests – Leaderboard & Profile
│   └── test_07_navigation.py    # 8  tests – Bottom-nav flow
│
├── utils/
│   ├── __init__.py
│   ├── excel_reporter.py        # Excel workbook generator (openpyxl)
│   └── test_helper.py           # record_test() decorator
│
└── reports/                     # Auto-created on first run
    ├── devduel_e2e_report_<ts>.xlsx
    ├── pytest_report_<ts>.html
    └── screenshots/             # Failure screenshots
```

---

## 🚀 Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Python | 3.9+ | |
| Node.js | 18+ | Required by Appium |
| Appium | 2.x | `npm install -g appium` |
| UiAutomator2 driver | latest | `appium driver install uiautomator2` |
| Android SDK / Emulator | API 30+ | Or a real Android device |
| ADB | latest | Comes with Android SDK |

---

## ⚙️ Setup

### 1. Clone / open the project
```
cd stitch_devduel_real_time_coding_battles/appium_tests
```

### 2. Install Python dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure environment
```bash
# Windows
copy .env.example .env

# Linux / macOS
cp .env.example .env
```

Edit `.env` with your values:
```ini
DEVICE_NAME      = emulator-5554        # adb devices → copy your device name
PLATFORM_VERSION = 14.0
APP_PACKAGE      = com.example.devduel_mobile
APP_ACTIVITY     = .MainActivity
APP_PATH         =                      # leave empty if app already installed

APPIUM_HOST = 127.0.0.1
APPIUM_PORT = 4723

TEST_EMAIL    = testuser@devduel.com    # must exist in your backend
TEST_PASSWORD = Test@1234
```

### 4. Start Appium server (separate terminal)
```bash
appium --port 4723
```

### 5. Start the Android Emulator / connect device
```bash
# List devices
adb devices

# Start emulator (if not already running)
emulator -avd Pixel_7_API_34
```

### 6. Start the FastAPI backend (separate terminal)
```bash
cd devduel_api
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

---

## ▶️ Running Tests

### Full suite (Windows – one-click)
```
run_tests.bat
```

### Full suite (CLI)
```bash
python -m pytest tests/ -v
```

### Run a specific module
```bash
python -m pytest tests/test_02_auth.py -v
```

### Run by marker
```bash
python -m pytest -m auth -v
python -m pytest -m battle -v
python -m pytest -m "smoke" -v
```

### Run with custom HTML report path
```bash
python -m pytest tests/ -v --html=reports/my_report.html --self-contained-html
```

---

## 📊 Reports

After every run, two reports are generated inside `reports/`:

### 1. Excel Report (`devduel_e2e_report_<timestamp>.xlsx`)
| Sheet | Contents |
|-------|----------|
| 📊 Summary | KPI cards (Total / Passed / Failed / Skip / Pass%), Pie chart |
| 📋 Test Details | Per-test row: ID, name, module, status, duration, error, screenshot path |
| 📈 Analysis | Module-wise pass/fail counts + Bar chart |

### 2. HTML Report (`pytest_report_<timestamp>.html`)
Standard pytest-html report with test name, duration, and captured output.

### 3. Screenshots (`reports/screenshots/`)
Automatically captured on **every failing test**.

---

## 🧪 Test Case Summary

| Module | Test Count | Key Scenarios |
|--------|-----------|---------------|
| 01 – Splash | 3 | Launch, branding, auto-navigate |
| 02 – Auth | 11 | Valid login, empty fields, wrong pwd, register, mismatch, Google |
| 03 – Home | 8 | Greeting, XP, Streak, Daily Challenge, Battle card, nav tabs |
| 04 – Battle | 15 | Difficulty chips, topics, FIND BATTLE, searching, arena, code editor |
| 05 – Problems | 10 | List, filters, search, clear, tap problem |
| 06 – LB & Profile | 8 | Ranks, XP, scroll, profile stats, logout |
| 07 – Navigation | 8 | All 5 tabs, back button, FIND BATTLE & SOLVE NOW shortcuts |
| **Total** | **63** | |

---

## 🔧 Architecture

```
Test File
   │
   ├── conftest.py  (driver + excel_reporter fixtures)
   │
   ├── Page Objects (pages/)
   │       BasePage → common Appium helpers
   │       SpecificPage → screen-specific locators & actions
   │
   └── Utils
           ExcelReporter  → collects TestResult objects → writes xlsx
           record_test()  → decorator: time + screenshot + add_result
```

---

## 🐛 Troubleshooting

| Problem | Fix |
|---------|-----|
| `Connection refused` | Start Appium: `appium --port 4723` |
| `No such element` | Increase `EXPLICIT_WAIT` in `.env` or add `time.sleep()` |
| `App not installed` | Set `APP_PATH` in `.env` to the APK file path |
| `Wrong device` | Run `adb devices` and update `DEVICE_NAME` in `.env` |
| `Auth failures` | Start the FastAPI backend and verify `TEST_EMAIL` exists |
