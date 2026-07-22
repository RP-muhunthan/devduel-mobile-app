const HomePage = require('../pages/homePage');
const ProblemsPage = require('../pages/problemsPage');

async function runProblemsTests(driver, config) {
    const results = [];
    const homePage = new HomePage(driver);
    const problemsPage = new ProblemsPage(driver);

    async function test(name, category, testFn) {
        const start = Date.now();
        let status = "PASS";
        let error = null;
        try {
            await testFn();
        } catch (e) {
            status = "FAIL";
            error = e.message;
        }
        const time = (Date.now() - start) / 1000;
        results.push({ name, category, status, error, time });
    }

    // Assuming we are already on Home from the previous test or we just navigate there
    try {
        await driver.get(config.APP_URL);
        await homePage.sleep(2000);
    } catch (e) {
        results.push({ name: "Problems Tab Setup", category: "Problems", status: "FAIL", error: e.message, time: 0 });
        return results;
    }
    // If not logged in, we might need a quick login check, but assuming session persists in same browser context

    await test("Navigate to Problems Tab", "Problems", async () => {
        await homePage.clickNavProblems();
        const isOnProblems = await problemsPage.isOnProblems();
        if (!isOnProblems) throw new Error("Did not reach Problems page");
    });

    await test("Verify Problem Title visible", "Problems", async () => {
        const titleVisible = await problemsPage.isProblemTitleVisible();
        if (!titleVisible) throw new Error("Problem title not visible");
    });

    await test("Switch to Test Cases Tab", "Problems", async () => {
        await problemsPage.clickTestCasesTab();
        // Just verify it doesn't crash
    });

    await test("Switch back to Code Tab", "Problems", async () => {
        await problemsPage.clickByText(problemsPage.CODE_TAB);
    });

    await test("Run Code functionality", "Problems", async () => {
        await problemsPage.clickRunCode();
        const toast = await problemsPage.isTestPassedToastVisible();
        if (!toast) throw new Error("Run code success toast not visible");
    });

    await test("Submit Solution and Victory", "Problems", async () => {
        await problemsPage.clickSubmit();
        const victory = await problemsPage.isVictoryDialogVisible(20000); // Allow time to grade
        if (!victory) throw new Error("Victory dialog not visible after submit");
        await problemsPage.clickReturnToLobby();
        const onHome = await homePage.isOnHome();
        if (!onHome) throw new Error("Did not return to Home after victory");
    });

    return results;
}

module.exports = runProblemsTests;
