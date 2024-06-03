import { test, expect } from '@playwright/test'

test('page should load without errors', async ({ page }) => {
    await page.goto('/')

    expect(page).toHaveTitle(/ngrok-free/)
})
