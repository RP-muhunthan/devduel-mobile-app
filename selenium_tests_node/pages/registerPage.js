const BasePage = require('./basePage');

class RegisterPage extends BasePage {
    constructor(driver) {
        super(driver);
        this.TITLE = "Create Account";
        this.SUBTITLE = "Join the elite arena of competitive coders.";
        this.FULL_NAME_HINT = "John Doe";
        this.EMAIL_HINT = "dev@duel.io";
        this.COLLEGE_HINT = "Start typing your institute...";
        this.PASSWORD_HINT = "••••••••";
        this.REGISTER_BTN = "REGISTER";
        this.LOGIN_LINK = "Login";
    }

    async isOnRegisterPage(timeout = 15000) {
        return await this.isTextVisible(this.TITLE, timeout);
    }

    async enterFullName(name) {
        await this.enterTextByHint(this.FULL_NAME_HINT, name);
    }

    async enterEmail(email) {
        await this.enterTextByHint(this.EMAIL_HINT, email);
    }

    async enterCollege(college) {
        await this.enterTextByHint(this.COLLEGE_HINT, college);
    }

    async enterPassword(password) {
        // Find all password fields and fill the first one
        const fields = await this.driver.findElements(require('selenium-webdriver').By.xpath(`//*[@aria-label='${this.PASSWORD_HINT}'] | //input[@placeholder='${this.PASSWORD_HINT}']`));
        if (fields.length > 0) {
            await fields[0].click();
            await fields[0].clear();
            await fields[0].sendKeys(password);
        } else {
             // fallback via base method
             await this.enterTextByHint(this.PASSWORD_HINT, password);
        }
    }

    async enterConfirmPassword(password) {
        // Find all password fields and fill the last one
        const fields = await this.driver.findElements(require('selenium-webdriver').By.xpath(`//*[@aria-label='${this.PASSWORD_HINT}'] | //input[@placeholder='${this.PASSWORD_HINT}']`));
        if (fields.length > 1) {
            const lastField = fields[fields.length - 1];
            await lastField.click();
            await lastField.clear();
            await lastField.sendKeys(password);
        }
    }

    async clickRegister() {
        await this.clickByText(this.REGISTER_BTN);
    }

    async clickLoginLink() {
        await this.clickByText(this.LOGIN_LINK);
    }

    async register(name, email, college, password) {
        await this.enterFullName(name);
        await this.enterEmail(email);
        await this.enterCollege(college);
        await this.enterPassword(password);
        await this.enterConfirmPassword(password);
        await this.clickRegister();
    }

    async isMismatchErrorVisible(timeout = 8000) {
        return await this.isTextVisible("do not match", timeout);
    }

    async isShortPasswordErrorVisible(timeout = 8000) {
        return await this.isTextVisible("at least 6", timeout);
    }

    async isEmptyFieldsErrorVisible(timeout = 8000) {
        return await this.isTextVisible("fill in all fields", timeout);
    }

    async isSuccessVisible(timeout = 15000) {
        return await this.isTextVisible("Account created", timeout);
    }
}

module.exports = RegisterPage;
