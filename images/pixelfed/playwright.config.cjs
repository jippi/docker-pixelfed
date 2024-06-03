module.exports = {
    testDir: 'tests/playwright',

    // Fail the build on CI if you accidentally left test.only in the source code.
    forbidOnly: !!process.env.CI,

    // Retry on CI only.
    retries: process.env.CI ? 2 : 0,

    // Opt out of parallel tests on CI.
    workers: process.env.CI ? 1 : undefined,

    use: {
        // Base URL to use in actions like `await page.goto('/')`.
        baseURL: process.env.E2E_URL ?? 'http://127.0.0.1:8080',

        // Collect trace when retrying the failed test.
        trace: 'on-first-retry',
    },
};
