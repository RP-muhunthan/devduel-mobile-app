const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

module.exports = {
  APP_URL: process.env.WEB_APP_URL || 'http://localhost:5000',
  USER_EMAIL: process.env.TEST_EMAIL || 'purushothamannirt@gmail.com',
  USER_PASSWORD: process.env.TEST_PASSWORD || 'purushothaman@1977',
  USER_NAME: process.env.TEST_USERNAME || 'Purushothaman',
  BROWSER: process.env.BROWSER || 'chrome',
  HEADLESS: process.env.HEADLESS === 'true',
  REPORT_FILE: path.join(__dirname, 'reports', `web_e2e_report_${Date.now()}.xlsx`)
};
