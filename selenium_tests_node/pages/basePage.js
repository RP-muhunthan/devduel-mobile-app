const { Builder, By, until } = require('selenium-webdriver');

class BasePage {
    constructor(driver) {
        this.driver = driver;
    }

    async navigateTo(url) {
        await this.driver.get(url);
    }

    async waitForElementByText(text, timeout = 15000) {
        const xpath = `//*[contains(text(), '${text}')] | //*[@aria-label='${text}'] | //*[contains(@aria-label, '${text}')]`;
        const element = await this.driver.wait(until.elementLocated(By.xpath(xpath)), timeout);
        await this.driver.wait(until.elementIsVisible(element), timeout);
        return element;
    }

    async isTextVisible(text, timeout = 10000) {
        try {
            await this.waitForElementByText(text, timeout);
            return true;
        } catch (error) {
            return false;
        }
    }

    async clickByText(text, timeout = 15000) {
        const element = await this.waitForElementByText(text, timeout);
        await element.click();
    }

    async enterTextByHint(hint, text, timeout = 15000) {
        // Flutter often maps hints to aria-label or nested input elements
        // Try locating an input directly or clicking a semantics node and typing
        try {
            const xpath = `//input[@placeholder='${hint}'] | //*[@aria-label='${hint}']/following-sibling::*//input | //*[@aria-label='${hint}']`;
            const element = await this.driver.wait(until.elementLocated(By.xpath(xpath)), timeout);
            await element.click();
            await element.clear();
            await element.sendKeys(text);
        } catch (error) {
            // Fallback for Flutter web inputs: click the area and use Actions to type
            const element = await this.waitForElementByText(hint, timeout);
            await element.click();
            const actions = this.driver.actions({async: true});
            await actions.clear().sendKeys(text).perform();
        }
    }

    async sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

module.exports = BasePage;
