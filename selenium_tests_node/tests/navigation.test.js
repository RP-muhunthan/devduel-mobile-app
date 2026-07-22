const HomePage = require('../pages/homePage');
const ProblemsPage = require('../pages/problemsPage');
const BattlePage = require('../pages/battlePage');

async function runNavigationTests(driver, config) {
    const results = [];
    const homePage = new HomePage(driver);
    const problemsPage = new ProblemsPage(driver);
    const battlePage = new BattlePage(driver);

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

    try {
        await driver.get(config.APP_URL);
        await homePage.sleep(2000);
    } catch (e) {
        results.push({ name: "Navigation Setup", category: "Navigation", status: "FAIL", error: e.message, time: 0 });
        return results;
    }

    await test("Navigate Home to Problems", "Navigation", async () => {
        await homePage.clickNavProblems();
        const isOnProblems = await problemsPage.isOnProblems();
        if (!isOnProblems) throw new Error("Navigation to Problems failed");
    });

    await test("Navigate Problems to Battle", "Navigation", async () => {
        await homePage.clickNavBattle(); // bottom nav is shared
        const isOnBattle = await battlePage.isOnBattleSelection();
        if (!isOnBattle) throw new Error("Navigation to Battle failed");
    });

    await test("Navigate Battle to Home", "Navigation", async () => {
        await homePage.clickNavHome();
        const isOnHome = await homePage.isOnHome();
        if (!isOnHome) throw new Error("Navigation to Home failed");
    });

    await test("Navigate Home to Profile", "Navigation", async () => {
        await homePage.clickNavProfile();
        // Assuming we look for something on profile or just verify it doesn't crash
        await homePage.sleep(1000);
    });

    await test("Navigate Profile to Leaderboard", "Navigation", async () => {
        await homePage.clickNavLeaderboard();
        await homePage.sleep(1000);
    });

    return results;
}

module.exports = runNavigationTests;
