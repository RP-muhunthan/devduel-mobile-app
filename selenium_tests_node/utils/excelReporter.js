const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');

const REPORTS_DIR = path.join(__dirname, '..', 'reports');

const CLR_PASS_BG = 'FFC6EFCE';
const CLR_PASS_FG = 'FF276221';
const CLR_FAIL_BG = 'FFFFC7CE';
const CLR_FAIL_FG = 'FF9C0006';
const CLR_SKIP_BG = 'FFFFEB9C';
const CLR_SKIP_FG = 'FF9C6500';
const CLR_HEADER_BG = 'FF1A1A2E';
const CLR_HEADER_FG = 'FFE94560';
const CLR_ALT_ROW = 'FFF5F5F5';
const CLR_TITLE_BG = 'FF16213E';
const CLR_KPI_TITLE_BG = 'FF2E2E3E';

class ResultRecord {
  constructor(testId, name, module, status, durationSec, errorMsg = '', category = 'Functional Testing') {
    this.testId = testId;
    this.name = name;
    this.module = module;
    this.status = status; // "PASS" | "FAIL" | "SKIP"
    this.durationSec = durationSec;
    this.errorMsg = errorMsg;
    this.category = category;
    this.timestamp = new Date().toISOString().replace('T', ' ').substring(0, 19);
  }
}

class ExcelReporter {
  constructor() {
    this.results = [];
    this.startTime = new Date();
  }

  addResult(result) {
    this.results.push(result);
  }

  async save() {
    if (!fs.existsSync(REPORTS_DIR)) {
      fs.mkdirSync(REPORTS_DIR, { recursive: true });
    }

    const timestampStr = this.startTime.toISOString().replace(/[-:T]/g, '').substring(0, 14);
    const filename = `devduel_web_report_${timestampStr}.xlsx`;
    const filepath = path.join(REPORTS_DIR, filename);

    const workbook = new ExcelJS.Workbook();
    
    this._buildSummarySheet(workbook);
    this._buildDetailsSheet(workbook);
    this._buildAnalysisSheet(workbook);

    await workbook.xlsx.writeFile(filepath);
    console.log(`\n✅ Excel report saved → ${filepath}\n`);
    return filepath;
  }

  _buildSummarySheet(workbook) {
    const ws = workbook.addWorksheet('📊 Summary', { views: [{ showGridLines: false }] });
    
    const total = this.results.length;
    const passed = this.results.filter(r => r.status === 'PASS').length;
    const failed = this.results.filter(r => r.status === 'FAIL').length;
    const skipped = total - passed - failed;
    const pct = total ? Math.round((passed / total) * 1000) / 10 : 0;
    const duration = (new Date() - this.startTime) / 1000;

    // --- Title banner ---
    ws.mergeCells('A1:H1');
    const titleCell = ws.getCell('A1');
    titleCell.value = '🎯  DevDuel Web – Selenium E2E Test Report';
    titleCell.font = { name: 'Calibri', bold: true, size: 18, color: { argb: 'FFFFFFFF' } };
    titleCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_HEADER_BG } };
    titleCell.alignment = { horizontal: 'center', vertical: 'middle' };
    ws.getRow(1).height = 40;

    ws.mergeCells('A2:H2');
    const subCell = ws.getCell('A2');
    subCell.value = `Generated: ${this.startTime.toLocaleString()}   |   Total Duration: ${duration.toFixed(1)}s`;
    subCell.font = { name: 'Calibri', size: 10, color: { argb: 'FFAAAAAA' } };
    subCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_HEADER_BG } };
    subCell.alignment = { horizontal: 'center', vertical: 'middle' };
    ws.getRow(2).height = 20;

    // --- KPI Cards (Row 4-5) ---
    const kpis = [
      { label: 'Total Tests', value: total, bg: 'FF1A1A2E', fg: 'FFFFFFFF' },
      { label: '✅ Passed', value: passed, bg: CLR_PASS_BG, fg: CLR_PASS_FG },
      { label: '❌ Failed', value: failed, bg: CLR_FAIL_BG, fg: CLR_FAIL_FG },
      { label: '⚠️ Skipped', value: skipped, bg: CLR_SKIP_BG, fg: CLR_SKIP_FG },
      { label: 'Pass Rate', value: `${pct}%`, bg: 'FF0F3460', fg: 'FFFFFFFF' }
    ];

    const colStart = 2; // Column B
    kpis.forEach((kpi, idx) => {
      const col = colStart + idx;
      
      // Label cell
      const lc = ws.getCell(4, col);
      lc.value = kpi.label;
      lc.font = { name: 'Calibri', bold: true, size: 10, color: { argb: kpi.fg } };
      lc.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: kpi.bg } };
      lc.alignment = { horizontal: 'center', vertical: 'middle' };
      lc.border = this._thinBorder();

      // Value cell
      const vc = ws.getCell(5, col);
      vc.value = kpi.value;
      vc.font = { name: 'Calibri', bold: true, size: 22, color: { argb: kpi.fg } };
      vc.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: kpi.bg } };
      vc.alignment = { horizontal: 'center', vertical: 'middle' };
      vc.border = this._thinBorder();

      ws.getColumn(col).width = 18;
    });

    ws.getRow(4).height = 22;
    ws.getRow(5).height = 50;
    ws.getColumn(1).width = 16;
  }

  _buildDetailsSheet(workbook) {
    const ws = workbook.addWorksheet('📝 Test Details', { views: [{ showGridLines: false }, { state: 'frozen', ySplit: 2 }] });

    const headers = [
      '#', 'Test ID', 'Test Name', 'Module', 'Category', 'Status',
      'Duration (s)', 'Timestamp', 'Error Message'
    ];
    const colWidths = [5, 18, 45, 25, 25, 12, 14, 22, 60];

    // Header rows
    ws.mergeCells('A1:I1');
    const headerCell = ws.getCell('A1');
    headerCell.value = 'DevDuel Web – Detailed Test Results';
    headerCell.font = { name: 'Calibri', bold: true, size: 14, color: { argb: 'FFFFFFFF' } };
    headerCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_HEADER_BG } };
    headerCell.alignment = { horizontal: 'center', vertical: 'middle' };
    ws.getRow(1).height = 30;

    headers.forEach((header, idx) => {
      const colIdx = idx + 1;
      const cell = ws.getCell(2, colIdx);
      cell.value = header;
      cell.font = { name: 'Calibri', bold: true, color: { argb: 'FFFFFFFF' }, size: 10 };
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFE94560' } };
      cell.alignment = { horizontal: 'center', vertical: 'middle', wrapText: true };
      cell.border = this._thinBorder();
      ws.getColumn(colIdx).width = colWidths[idx];
    });
    ws.getRow(2).height = 22;

    // Data rows
    this.results.forEach((res, idx) => {
      const rowIdx = idx + 3;
      const alt = rowIdx % 2 === 0;
      const fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: alt ? CLR_ALT_ROW : 'FFFFFFFF' } };

      let statusFill, statusFont;
      if (res.status === 'PASS') {
        statusFill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_PASS_BG } };
        statusFont = { name: 'Calibri', bold: true, color: { argb: CLR_PASS_FG }, size: 10 };
      } else if (res.status === 'FAIL') {
        statusFill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_FAIL_BG } };
        statusFont = { name: 'Calibri', bold: true, color: { argb: CLR_FAIL_FG }, size: 10 };
      } else {
        statusFill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_SKIP_BG } };
        statusFont = { name: 'Calibri', bold: true, color: { argb: CLR_SKIP_FG }, size: 10 };
      }

      const rowData = [
        idx + 1,
        res.testId,
        res.name,
        res.module,
        res.category,
        res.status,
        Number(res.durationSec.toFixed(2)),
        res.timestamp,
        res.errorMsg
      ];

      rowData.forEach((val, colIdx) => {
        const cell = ws.getCell(rowIdx, colIdx + 1);
        cell.value = val;
        cell.border = this._thinBorder();
        cell.alignment = { vertical: 'middle', wrapText: true, horizontal: colIdx === 0 || colIdx === 5 || colIdx === 6 ? 'center' : 'left' };
        
        if (colIdx === 5) { // Status column
          cell.fill = statusFill;
          cell.font = statusFont;
        } else {
          cell.fill = fill;
          cell.font = { name: 'Calibri', size: 10 };
        }
      });
      ws.getRow(rowIdx).height = 20;
    });
  }

  _buildAnalysisSheet(workbook) {
    const ws = workbook.addWorksheet('📈 Analysis', { views: [{ showGridLines: false }] });

    // --- Section 1: Module-wise Test Analysis ---
    ws.mergeCells('A1:G1');
    ws.getCell('A1').value = 'Module-wise Test Analysis';
    ws.getCell('A1').font = { name: 'Calibri', bold: true, size: 14, color: { argb: 'FFFFFFFF' } };
    ws.getCell('A1').fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_HEADER_BG } };
    ws.getCell('A1').alignment = { horizontal: 'center', vertical: 'middle' };
    ws.getRow(1).height = 30;

    // Group by modules
    const modules = {};
    this.results.forEach(r => {
      if (!modules[r.module]) {
        modules[r.module] = { total: 0, passed: 0, failed: 0, skipped: 0, duration: 0 };
      }
      const m = modules[r.module];
      m.total += 1;
      m.duration += r.durationSec;
      if (r.status === 'PASS') m.passed += 1;
      else if (r.status === 'FAIL') m.failed += 1;
      else m.skipped += 1;
    });

    const headers = ['Module', 'Total', 'Passed', 'Failed', 'Skipped', 'Pass Rate', 'Avg Duration (s)'];
    headers.forEach((h, idx) => {
      const cell = ws.getCell(2, idx + 1);
      cell.value = h;
      cell.font = { name: 'Calibri', bold: true, color: { argb: 'FFFFFFFF' }, size: 10 };
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFE94560' } };
      cell.alignment = { horizontal: 'center', vertical: 'middle' };
      cell.border = this._thinBorder();
      ws.getColumn(idx + 1).width = 22;
    });
    ws.getRow(2).height = 20;

    let currentRow = 3;
    Object.entries(modules).forEach(([module, stats]) => {
      const pct = stats.total ? Math.round((stats.passed / stats.total) * 1000) / 10 : 0;
      const avg = stats.total ? Math.round((stats.duration / stats.total) * 100) / 100 : 0;

      const rowData = [
        module,
        stats.total,
        stats.passed,
        stats.failed,
        stats.skipped,
        `${pct}%`,
        avg
      ];

      rowData.forEach((val, idx) => {
        const cell = ws.getCell(currentRow, idx + 1);
        cell.value = val;
        cell.border = this._thinBorder();
        cell.alignment = { horizontal: idx === 0 ? 'left' : 'center', vertical: 'middle' };
        cell.font = { name: 'Calibri', size: 10 };

        if (idx === 2) cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_PASS_BG } };
        else if (idx === 3) cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_FAIL_BG } };
        else if (idx === 4) cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_SKIP_BG } };
      });
      ws.getRow(currentRow).height = 18;
      currentRow += 1;
    });

    // --- Section 2: Category-wise Test Analysis ---
    currentRow += 2; // leave blank row
    const startCatRow = currentRow;

    ws.mergeCells(`A${startCatRow}:G${startCatRow}`);
    const titleCell = ws.getCell(startCatRow, 1);
    titleCell.value = 'Category-wise Test Analysis';
    titleCell.font = { name: 'Calibri', bold: true, size: 14, color: { argb: 'FFFFFFFF' } };
    titleCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_HEADER_BG } };
    titleCell.alignment = { horizontal: 'center', vertical: 'middle' };
    ws.getRow(startCatRow).height = 30;

    // Group by categories
    const categories = {};
    this.results.forEach(r => {
      if (!categories[r.category]) {
        categories[r.category] = { total: 0, passed: 0, failed: 0, skipped: 0, duration: 0 };
      }
      const c = categories[r.category];
      c.total += 1;
      c.duration += r.durationSec;
      if (r.status === 'PASS') c.passed += 1;
      else if (r.status === 'FAIL') c.failed += 1;
      else c.skipped += 1;
    });

    const headerCatRow = startCatRow + 1;
    const headersCat = ['Testing Category', 'Total', 'Passed', 'Failed', 'Skipped', 'Pass Rate', 'Avg Duration (s)'];
    headersCat.forEach((h, idx) => {
      const cell = ws.getCell(headerCatRow, idx + 1);
      cell.value = h;
      cell.font = { name: 'Calibri', bold: true, color: { argb: 'FFFFFFFF' }, size: 10 };
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0F3460' } };
      cell.alignment = { horizontal: 'center', vertical: 'middle' };
      cell.border = this._thinBorder();
    });
    ws.getRow(headerCatRow).height = 20;

    currentRow = headerCatRow + 1;
    Object.entries(categories).forEach(([category, stats]) => {
      const pct = stats.total ? Math.round((stats.passed / stats.total) * 1000) / 10 : 0;
      const avg = stats.total ? Math.round((stats.duration / stats.total) * 100) / 100 : 0;

      const rowData = [
        category,
        stats.total,
        stats.passed,
        stats.failed,
        stats.skipped,
        `${pct}%`,
        avg
      ];

      rowData.forEach((val, idx) => {
        const cell = ws.getCell(currentRow, idx + 1);
        cell.value = val;
        cell.border = this._thinBorder();
        cell.alignment = { horizontal: idx === 0 ? 'left' : 'center', vertical: 'middle' };
        cell.font = { name: 'Calibri', size: 10 };

        if (idx === 2) cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_PASS_BG } };
        else if (idx === 3) cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_FAIL_BG } };
        else if (idx === 4) cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: CLR_SKIP_BG } };
      });
      ws.getRow(currentRow).height = 18;
      currentRow += 1;
    });
  }

  _thinBorder() {
    const s = { style: 'thin', color: { argb: 'FFCCCCCC' } };
    return { left: s, right: s, top: s, bottom: s };
  }
}

module.exports = {
  ResultRecord,
  ExcelReporter
};
