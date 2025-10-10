import { test, expect } from '@playwright/test';

test.describe('Frontend Homepage', () => {
  test('displays hero section', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('.nav-brand')).toContainText('ShortApp');
    await expect(page.locator('.hero h1')).toBeVisible();
    await page.screenshot({ path: 'screenshots/01-homepage-hero.png' });
  });

  test('displays URL shortener form', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('#url-input')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toContainText('Shorten');
    await page.screenshot({ path: 'screenshots/02-shortener-form.png' });
  });

  test('shows advanced options on toggle', async ({ page }) => {
    await page.goto('/');
    await page.click('.advanced-toggle');
    await expect(page.locator('#custom-alias')).toBeVisible();
    await page.screenshot({ path: 'screenshots/03-advanced-options.png' });
  });

  test('displays statistics section', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('.stats')).toBeVisible();
    await page.screenshot({ path: 'screenshots/04-statistics.png' });
  });

  test('displays features section', async ({ page }) => {
    await page.goto('/');
    await page.locator('#features').scrollIntoViewIfNeeded();
    await expect(page.locator('.feature-card')).toHaveCount(6);
    await page.screenshot({ path: 'screenshots/05-features.png' });
  });

  test('captures full page', async ({ page }) => {
    await page.goto('/');
    await page.screenshot({ path: 'screenshots/06-full-page.png', fullPage: true });
  });
});

test.describe('Responsive Design', () => {
  test('mobile view', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await page.goto('/');
    await page.screenshot({ path: 'screenshots/07-mobile-view.png', fullPage: true });
  });
});
