#!/usr/bin/env bash
# ============================================================
#  DevDuel Mobile – Appium E2E Test Runner (Linux / macOS)
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo "============================================================"
echo "  DevDuel Mobile — Appium E2E Test Suite"
echo "============================================================"
echo ""

# ── 1. Install Python deps ────────────────────────────────────
echo "[*] Installing Python dependencies..."
pip install -r requirements.txt -q
echo "[OK] Dependencies installed"

# ── 2. Prepare directories ────────────────────────────────────
mkdir -p reports/screenshots
echo "[OK] Reports directory ready"

# ── 3. Create .env if missing ─────────────────────────────────
if [ ! -f ".env" ]; then
    echo "[WARN] .env not found. Copying from .env.example..."
    cp .env.example .env
    echo "[WARN] Update .env before running tests!"
    exit 1
fi

# ── 4. Run tests ──────────────────────────────────────────────
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
echo ""
echo "============================================================"
echo "  Starting Test Run — $TIMESTAMP"
echo "============================================================"
echo ""

python -m pytest tests/ \
    --tb=short \
    -v \
    --html="reports/pytest_report_${TIMESTAMP}.html" \
    --self-contained-html

EXIT_CODE=$?

echo ""
echo "============================================================"
echo "  Reports → $SCRIPT_DIR/reports/"
echo "============================================================"
echo ""

exit $EXIT_CODE
