const BasePage = require('./basePage');

class ProblemsPage extends BasePage {
    constructor(driver) {
        super(driver);
        this.CHALLENGE_TITLE = "CHALLENGE";
        this.PROBLEM_NAME = "Median of Two Sorted Arrays";
        this.RUN_CODE_BTN = "RUN CODE";
        this.SUBMIT_BTN = "SUBMIT";
        this.CODE_TAB = "CODE";
        this.TEST_CASES_TAB = "TEST CASES";
    }

    async isOnProblems(timeout = 15000) {
        return await this.isTextVisible(this.PROBLEM_NAME, timeout);
    }

    async isProblemTitleVisible(timeout = 10000) {
        return await this.isTextVisible(this.PROBLEM_NAME, timeout);
    }

    async clickRunCode() {
        await this.clickByText(this.RUN_CODE_BTN);
    }

    async clickSubmit() {
        await this.clickByText(this.SUBMIT_BTN);
    }

    async clickTestCasesTab() {
        await this.clickByText(this.TEST_CASES_TAB);
    }

    async isTestPassedToastVisible(timeout = 10000) {
        return await this.isTextVisible("Code executed successfully", timeout);
    }

    async isVictoryDialogVisible(timeout = 15000) {
        return await this.isTextVisible("VICTORY!", timeout);
    }

    async clickReturnToLobby() {
        await this.clickByText("RETURN TO LOBBY");
    }
}

module.exports = ProblemsPage;
