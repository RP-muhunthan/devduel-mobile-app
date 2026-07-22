const HomePage = require('../pages/homePage');
const BattlePage = require('../pages/battlePage');
const { By } = require('selenium-webdriver');

async function runBattleTests(driver, config) {
    const results = [];
    const homePage = new HomePage(driver);
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
        results.push({ name: "Battle Tab Setup", category: "Matchmaking", status: "FAIL", error: e.message, time: 0 });
        return results;
    }

    await test("Navigate to Battle Section", "Matchmaking", async () => {
        await homePage.clickFindBattle();
        const isOnBattle = await battlePage.isOnBattleSelection();
        if (!isOnBattle) throw new Error("Did not reach Battle Selection page");
    });

    await test("Select Difficulty and Topic", "Matchmaking", async () => {
        await battlePage.selectDifficulty(battlePage.EASY_CHIP);
        await battlePage.selectTopic(battlePage.TOPIC_ARRAYS);
    });

    await test("Start Matchmaking", "Matchmaking", async () => {
        await battlePage.clickFindBattle();
        const isSearching = await battlePage.isSearching();
        if (!isSearching) throw new Error("Matchmaking searching text not visible");
    });

    await test("Cancel Search", "Matchmaking", async () => {
        await battlePage.clickCancelSearch();
        const isCancelled = await battlePage.isOnBattleSelection();
        if (!isCancelled) throw new Error("Did not return to Battle Selection after cancel");
    });

    await test("Force Enter Arena (Debug)", "Arena", async () => {
        await battlePage.clickForceEnterArena();
        const inArena = await battlePage.isInArena();
        if (!inArena) throw new Error("Did not enter Arena");
    });

    await test("Arena Run Code", "Arena", async () => {
        await battlePage.clickRunCode();
        // Fast mock backend returns passed
        const passed = await battlePage.isTestPassed();
        if (!passed) throw new Error("Test cases passed label not visible");
    });

    await test("Arena Submit and Victory", "Arena", async () => {
        await battlePage.clickSubmit();
        const victory = await battlePage.isVictoryDialogVisible(20000);
        if (!victory) throw new Error("Victory dialog not visible");
        await battlePage.clickReturnToBase();
        const onHome = await homePage.isOnHome();
        if (!onHome) throw new Error("Did not return to home after battle");
    });

    return results;
}

module.exports = runBattleTests;
