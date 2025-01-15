import { test, expect } from '@playwright/test'

test('page should load without errors', async ({ page }) => {
    await page.goto('/')

    expect(page).toHaveTitle("docker-pixelfed e2e")
})

test('/api/nodeinfo/2.0.json', async ({ page }) => {
    const response = await page.get('/api/nodeinfo/2.0.json')
    const json = JSON.parse(await response.text())

    expect(json.nodeName).toBe("docker-pixelfed e2e")
    expect(json.software.name).toBe("pixelfed")
    expect(json.usage.users.total).toBe(0)
})

test('/api/v1/instance', async ({ page }) => {
    const response = await page.get('/api/v1/instance')
    const json = JSON.parse(await response.text())

    expect(json.email).toBe("github@example.com")
})

