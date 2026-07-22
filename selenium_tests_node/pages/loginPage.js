const BasePage = require('./basePage');

class LoginPage extends BasePage {
    constructor(driver) {
        super(driver);
        this.TITLE = "Welcome Back";
        this.SUBTITLE = "Sign in to resume your terminal duel.";
        this.EMAIL_HINT = "dev@duel.sh";
        this.PASSWORD_HINT = "••••••••";
        this.LOGIN_BTN = "LOGIN";
        this.REGISTER_LINK = "Register";
        this.GOOGLE_BTN = "Continue with Google";
        this.FORGOT_PWD = "Forgot Password?";
    }

    async isOnLoginPage(timeout = 15000) {
        return await this.isTextVisible(this.TITLE, timeout);
    }

    async enterEmail(email) {
        await this.enterTextByHint(this.EMAIL_HINT, email);
    }

    async enterPassword(password) {
        await this.enterTextByHint(this.PASSWORD_HINT, password);
    }

    async clickLogin() {
        await this.clickByText(this.LOGIN_BTN);
    }

    async clickRegister() {
        await this.clickByText(this.REGISTER_LINK);
    }

    async login(email, password) {
        await this.enterEmail(email);
        await this.enterPassword(password);
        await this.clickLogin();
    }

    async isLoginErrorVisible(timeout = 8000) {
        const errorKeywords = ["Please", "error", "Error", "failed", "Incorrect"];
        for (const keyword of errorKeywords) {
            if (await this.isTextVisible(keyword, timeout / 2)) {
                return true;
            }
        }
        return false;
    }

    async isEmailEmptyError(timeout = 5000) {
        return await this.isTextVisible("fill in all fields", timeout);
    }
}

module.exports = LoginPage;
