const BasePage = require('./basePage');
const { By } = require('selenium-webdriver');

class BattlePage extends BasePage {
    constructor(driver) {
        super(driver);
        this.TITLE = "Choose Battle Mode";
        this.FIND_BATTLE_BTN = "START";
        this.EASY_CHIP = "Easy";
        this.MEDIUM_CHIP = "Medium";
        this.HARD_CHIP = "Hard";
        this.RANDOM_CHIP = "Random";

        this.TOPIC_ALL = "All";
        this.TOPIC_ARRAYS = "Arrays";
        this.TOPIC_TREES = "Trees";
        this.TOPIC_DP = "DP";
        this.TOPIC_GRAPHS = "Graphs";
        this.TOPIC_STRINGS = "Strings";

        this.SEARCHING_TEXT = "SEARCHING FOR OPPONENT";
        this.CANCEL_SEARCH = "CANCEL SEARCH";
        this.FORCE_ARENA_BTN = "DEBUG: FORCE ENTER ARENA";

        this.CHALLENGE_LABEL = "CHALLENGE";
        this.RUN_CODE_BTN = "RUN CODE";
        this.SUBMIT_BTN = "SUBMIT";
        this.CONSOLE_BTN = "CONSOLE";
        this.CODE_TAB = "CODE";
        this.TEST_CASES_TAB = "TEST CASES";
    }

    async isOnBattleSelection(timeout = 15000) {
        return await this.isTextVisible(this.FIND_BATTLE_BTN, timeout);
    }

    async isSearching(timeout = 15000) {
        return await this.isTextVisible(this.SEARCHING_TEXT, timeout);
    }

    async isInArena(timeout = 30000) {
        return await this.isTextVisible(this.CHALLENGE_LABEL, timeout);
    }

    async selectDifficulty(difficulty) {
        await this.clickByText(difficulty);
    }

    async selectTopic(topic) {
        await this.clickByText(topic);
    }

    async clickFindBattle() {
        await this.clickByText(this.FIND_BATTLE_BTN);
    }

    async clickCancelSearch() {
        await this.clickByText(this.CANCEL_SEARCH);
    }

    async clickForceEnterArena() {
        await this.clickByText(this.FORCE_ARENA_BTN);
    }

    async clickRunCode() {
        await this.clickByText(this.RUN_CODE_BTN);
    }

    async clickSubmit() {
        await this.clickByText(this.SUBMIT_BTN);
    }

    async clickConsole() {
        await this.clickByText(this.CONSOLE_BTN);
    }

    async clickCodeTab() {
        await this.clickByText(this.CODE_TAB);
    }

    async clickTestCasesTab() {
        await this.clickByText(this.TEST_CASES_TAB);
    }

    async enterCode(code) {
        try {
            // Locating by text area or editor classes typically used in web
            const editor = await this.driver.findElement(By.css('textarea, input[type="text"], .view-lines'));
            await editor.clear();
            await editor.sendKeys(code);
        } catch (e) {
            // For flutter web canvaskit
            const actions = this.driver.actions({async: true});
            await actions.sendKeys(code).perform();
        }
    }

    async isTestPassed(timeout = 20000) {
        return await this.isTextVisible("TEST CASES PASSED", timeout);
    }

    async isTestFailed(timeout = 10000) {
        return await this.isTextVisible("TEST CASES FAILED", timeout);
    }

    async isVictoryDialogVisible(timeout = 15000) {
        return await this.isTextVisible("VICTORY!", timeout);
    }

    async clickReturnToBase() {
        await this.clickByText("RETURN TO BASE");
    }

    async isProblemStatementVisible(timeout = 15000) {
        return await this.isTextVisible("Problem Statement", timeout);
    }
}

module.exports = BattlePage;
