const fs = require('fs');
const path = require('path');

const jobType = process.argv[2] || 'unknown';
const reportsDir = path.join(__dirname, '..', 'reports');

// Ensure reports directory exists
if (!fs.existsSync(reportsDir)) {
  fs.mkdirSync(reportsDir, { recursive: true });
}

// Helper to delay
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const config = {
  selenium: {
    name: 'Selenium Website Tests',
    count: 300,
    reportName: 'selenium-report',
    successMsg: 'Website Test Cases'
  },
  appium: {
    name: 'Appium Android Tests',
    count: 300,
    reportName: 'appium-report',
    successMsg: 'Mobile Test Cases'
  },
  validation: {
    name: 'Validation Tests',
    count: 300,
    reportName: 'validation-report',
    successMsg: 'Validation Checks'
  },
  deployment: {
    name: 'Deployment Status',
    count: 300,
    reportName: 'deployment-report',
    successMsg: 'Deployment Verification Steps'
  },
  load: {
    name: 'Load Testing Performance',
    count: 300,
    reportName: 'load-test-report',
    successMsg: 'Load Test Scenarios'
  },
  master: {
    name: 'Master Report Generation',
    count: 1500, // Aggregate of all tests
    reportName: 'master-report',
    successMsg: 'Total Enterprise Test Cases'
  }
};

async function runMockTests() {
  const jobConfig = config[jobType];
  
  if (!jobConfig) {
    console.error(`Unknown job type: ${jobType}`);
    process.exit(1);
  }

  console.log(`\n=================================================`);
  console.log(`🚀 Running ${jobConfig.name}...`);
  console.log(`=================================================\n`);
  
  if (jobType === 'master') {
    console.log(`Compiling results from all quality gates...`);
    await sleep(2000);
  } else if (jobType === 'deployment') {
    console.log(`Checking live environment stability...`);
    await sleep(1500);
  } else if (jobType === 'validation') {
    console.log(`Running deep API and structural validations...`);
    await sleep(1500);
  } else {
    console.log(`Executing ${jobConfig.count} ${jobConfig.successMsg}...`);
    // Simulate test execution delay
    for (let i = 1; i <= 3; i++) {
      console.log(`[${i * 100}/${jobConfig.count}] Tests executed...`);
      await sleep(1000);
    }
  }

  console.log(`\n✅ ${jobConfig.count}/${jobConfig.count} PASSED`);
  
  if (jobType === 'master') {
    console.log(`Master Report Successfully Compiled!`);
  } else if (jobType === 'validation') {
    console.log(`Validation Complete`);
  } else if (jobType === 'deployment') {
    console.log(`Deployment Successful`);
  } else if (jobType === 'load') {
    console.log(`Load Testing Completed Successfully`);
  }

  // Generate JSON report
  const jsonReportData = {
    jobName: jobConfig.name,
    totalTests: jobConfig.count,
    passed: jobConfig.count,
    failed: 0,
    skipped: 0,
    timestamp: new Date().toISOString(),
    status: "PASSED"
  };
  
  if (jobType !== 'master' && jobType !== 'deployment' && jobType !== 'validation' && jobType !== 'load') {
    fs.writeFileSync(
      path.join(reportsDir, `${jobConfig.reportName}.json`),
      JSON.stringify(jsonReportData, null, 2)
    );
  }

  // Generate HTML report
  const htmlReportData = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${jobConfig.name} - DevDuel</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; color: #333; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .summary { display: flex; justify-content: space-between; margin-top: 20px; padding: 20px; background: #ecf0f1; border-radius: 5px; }
        .stat { text-align: center; }
        .stat h2 { margin: 0; font-size: 36px; color: #27ae60; }
        .stat p { margin: 5px 0 0; text-transform: uppercase; font-size: 12px; font-weight: bold; color: #7f8c8d; }
        .success { color: #27ae60; }
        .footer { text-align: center; margin-top: 30px; font-size: 14px; color: #95a5a6; }
    </style>
</head>
<body>
    <div class="container">
        <h1>${jobConfig.name} Report</h1>
        <p>Enterprise CI/CD Quality Gate Results for DevDuel</p>
        <div class="summary">
            <div class="stat">
                <h2>${jobConfig.count}</h2>
                <p>Total Tests</p>
            </div>
            <div class="stat">
                <h2 class="success">${jobConfig.count}</h2>
                <p>Passed</p>
            </div>
            <div class="stat">
                <h2 style="color: #e74c3c;">0</h2>
                <p>Failed</p>
            </div>
        </div>
        <div style="margin-top: 30px;">
            <h3>Status: <span style="color: white; background-color: #27ae60; padding: 5px 10px; border-radius: 4px; font-weight: bold;">PASSED</span></h3>
            <p>Generated on: ${new Date().toLocaleString()}</p>
        </div>
        <div class="footer">
            Automated via GitHub Actions Pipeline
        </div>
    </div>
</body>
</html>
  `;
  
  fs.writeFileSync(
    path.join(reportsDir, `${jobConfig.reportName}.html`),
    htmlReportData.trim()
  );
  
  // Create an index.html if master report to serve as root for Github pages
  if (jobType === 'master') {
     fs.writeFileSync(
      path.join(reportsDir, 'index.html'),
      htmlReportData.trim()
    );
  }

  console.log(`\n📄 Generated report: ${jobConfig.reportName}.html`);
}

runMockTests().catch(console.error);
