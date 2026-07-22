const LoginPage = require('../pages/loginPage');
const RegisterPage = require('../pages/registerPage');
const HomePage = require('../pages/homePage');

async function runAuthTests(driver, config) {
    const results = [];
    const loginPage = new LoginPage(driver);
    const registerPage = new RegisterPage(driver);
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

    await test("Navigate to App", "Navigation", async () => {
        await driver.get(config.APP_URL);
        const isOnLogin = await loginPage.isOnLoginPage(10000);
        if (!isOnLogin) throw new Error("Did not reach login page");
    });

    await test("Login with invalid credentials", "Auth", async () => {
        await loginPage.login("wrong@duel.sh", "wrongpass");
        const isErrorVisible = await loginPage.isLoginErrorVisible();
        if (!isErrorVisible) throw new Error("Expected error message not visible");
        // Clear for next test
        await driver.navigate().refresh();
        await loginPage.sleep(2000);
    });

    await test("Login with valid credentials", "Auth", async () => {
        await loginPage.login(config.USER_EMAIL, config.USER_PASSWORD);
        const isOnHome = await homePage.isOnHome();
        if (!isOnHome) throw new Error("Did not reach home page after login");
    });

    await test("Logout functionality", "Auth", async () => {
        await homePage.clickLogout();
        const isOnLogin = await loginPage.isOnLoginPage();
        if (!isOnLogin) throw new Error("Did not return to login page after logout");
    });

    return results;
}

module.exports = runAuthTests;
