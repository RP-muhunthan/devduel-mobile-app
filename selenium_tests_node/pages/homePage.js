const BasePage = require('./basePage');

class HomePage extends BasePage {
    constructor(driver) {
        super(driver);
        this.DAILY_CHALLENGE = "Matrix Diagonal Sum";
        this.SOLVE_NOW_BTN = "SOLVE NOW";
        this.FIND_BATTLE_BTN = "FIND BATTLE";
        this.RECENT_ACTIVITY = "RECENT ACTIVITY";
        this.VIEW_ALL_BTN = "VIEW ALL";
        this.REPAIR_DB_TOOLTIP = "Repair Database";

        this.NAV_HOME = "HOME";
        this.NAV_BATTLE = "BATTLE";
        this.NAV_PROBLEMS = "PROBLEMS";
        this.NAV_LEADERBOARD = "LEADERBOARD";
        this.NAV_PROFILE = "PROFILE";
    }

    async isOnHome(timeout = 25000) {
        return await this.isTextVisible(this.FIND_BATTLE_BTN, timeout);
    }

    async isGreetingVisible(timeout = 15000) {
        const greetings = ["Good morning", "Good evening", "Good afternoon"];
        for (const greeting of greetings) {
            if (await this.isTextVisible(greeting, timeout / 3)) {
                return true;
            }
        }
        return false;
    }

    async clickSolveNow() {
        await this.clickByText(this.SOLVE_NOW_BTN);
    }

    async clickFindBattle() {
        await this.clickByText(this.FIND_BATTLE_BTN);
    }

    async clickLogout() {
        try {
            const logoutButton = await this.waitForElementByText("Logout", 5000);
            await logoutButton.click();
        } catch (e) {
            // Web fallback if aria-label="Logout" is used
            const { By } = require('selenium-webdriver');
            const logout = await this.driver.findElement(By.xpath(`//*[@aria-label='Logout'] | //*[@title='Logout']`));
            await logout.click();
        }
    }

    async clickNavHome() {
        await this.clickByText(this.NAV_HOME);
    }

    async clickNavBattle() {
        await this.clickByText(this.NAV_BATTLE);
    }

    async clickNavProblems() {
        await this.clickByText(this.NAV_PROBLEMS);
    }

    async clickNavLeaderboard() {
        await this.clickByText(this.NAV_LEADERBOARD);
    }

    async clickNavProfile() {
        await this.clickByText(this.NAV_PROFILE);
    }

    async isXpVisible(timeout = 10000) {
        return await this.isTextVisible("XP", timeout);
    }

    async isStreakVisible(timeout = 10000) {
        return await this.isTextVisible("Streak", timeout);
    }

    async isDailyChallengeVisible(timeout = 10000) {
        return await this.isTextVisible(this.DAILY_CHALLENGE, timeout);
    }

    async isRecentActivityVisible(timeout = 10000) {
        return await this.isTextVisible(this.RECENT_ACTIVITY, timeout);
    }
}

module.exports = HomePage;
