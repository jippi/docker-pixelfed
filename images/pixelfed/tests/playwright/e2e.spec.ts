import { test, expect } from '@playwright/test'

test('page should load without errors', async ({ page }) => {
    console.error("E2E_URL", process.env.E2E_URL)

    await page.goto('/')

    expect(page).toHaveTitle("docker-pixelfed e2e")
})
