const LoginPage = require('../pages/loginPage');
const HomePage = require('../pages/homePage');

async function runHomeTests(driver, config) {
    const results = [];
    const loginPage = new LoginPage(driver);
    const homePage = new HomePage(driver);

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

    // Pre-requisite: Login
    try {
        await driver.get(config.APP_URL);
        await loginPage.sleep(2000);
        await loginPage.login(config.USER_EMAIL, config.USER_PASSWORD);
        await homePage.isOnHome();
    } catch (e) {
        results.push({ name: "Home Dashboard Setup", category: "Home Dashboard", status: "FAIL", error: e.message, time: 0 });
        return results;
    }

    await test("Verify Greeting is visible", "Home Dashboard", async () => {
        const hasGreeting = await homePage.isGreetingVisible();
        if (!hasGreeting) throw new Error("Greeting not visible");
    });

    await test("Verify XP is visible", "Home Dashboard", async () => {
        const hasXp = await homePage.isXpVisible();
        if (!hasXp) throw new Error("XP not visible");
    });

    await test("Verify Streak is visible", "Home Dashboard", async () => {
        const hasStreak = await homePage.isStreakVisible();
        if (!hasStreak) throw new Error("Streak not visible");
    });

    await test("Verify Daily Challenge card", "Home Dashboard", async () => {
        const hasChallenge = await homePage.isDailyChallengeVisible();
        if (!hasChallenge) throw new Error("Daily Challenge not visible");
    });

    return results;
}

module.exports = runHomeTests;
