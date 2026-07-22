require('dotenv').config();
const { Builder, Browser } = require('selenium-webdriver');
const config = require('./config');
const { ExcelReporter, ResultRecord } = require('./utils/excelReporter');

// Test suites
const runAuthTests = require('./tests/auth.test');
const runHomeTests = require('./tests/home.test');
const runProblemsTests = require('./tests/problems.test');
const runBattleTests = require('./tests/battle.test');
const runNavigationTests = require('./tests/navigation.test');

async function main() {
    console.log("Starting Web E2E Test Suite...");
    let driver;
    const allResults = [];

    try {
        // Build Chrome driver
        driver = await new Builder().forBrowser(Browser.CHROME).build();
        // Manage window state
        await driver.manage().window().maximize();

        console.log("-> Running Auth Tests");
        const authResults = await runAuthTests(driver, config);
        allResults.push(...authResults);

        console.log("-> Running Home Tests");
        const homeResults = await runHomeTests(driver, config);
        allResults.push(...homeResults);

        console.log("-> Running Navigation Tests");
        const navResults = await runNavigationTests(driver, config);
        allResults.push(...navResults);

        console.log("-> Running Problems Tests");
        const problemsResults = await runProblemsTests(driver, config);
        allResults.push(...problemsResults);

        console.log("-> Running Battle Tests");
        const battleResults = await runBattleTests(driver, config);
        allResults.push(...battleResults);

    } catch (err) {
        console.error("Fatal Error during test execution:", err);
    } finally {
        if (driver) {
            await driver.quit();
        }
        
        console.log("Generating Excel Report...");
        const reporter = new ExcelReporter();
        for (let i = 0; i < allResults.length; i++) {
            const res = allResults[i];
            const record = new ResultRecord(
                `TEST-WEB-${(i + 1).toString().padStart(3, '0')}`,
                res.name,
                "Web UI",
                res.status,
                res.time,
                res.error || "",
                res.category
            );
            reporter.addResult(record);
        }
        await reporter.save();
        console.log(`Excel Report successfully generated`);
        console.log("Web E2E Test Suite Completed.");
    }
}

main();
