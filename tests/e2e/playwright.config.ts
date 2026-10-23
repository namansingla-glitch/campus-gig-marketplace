import { defineConfig, devices } from '@playwright/test';

// Browser checks against the running app: BASE (default http://localhost:8080/gig-marketplace).
// CI starts Tomcat + MySQL with a fresh schema first; these tests only read pages and log in (the smoke test runs after).
// Locally, E2E_CHROMIUM can point at an existing Chromium binary.
const chromium = process.env.E2E_CHROMIUM ? { launchOptions: { executablePath: process.env.E2E_CHROMIUM } } : {};

export default defineConfig({
  testDir: './specs',
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: 2,
  reporter: process.env.CI ? [['list'], ['json', { outputFile: 'results.json' }]] : [['list'], ['json', { outputFile: 'results.json' }]],
  use: { trace: 'retain-on-failure' },
  projects: [
    { name: 'chromium-desktop', use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 900 }, ...chromium } },
    { name: 'chromium-phone', use: { ...devices['Pixel 7'], ...chromium } },
    { name: 'webkit-desktop', use: { ...devices['Desktop Safari'], viewport: { width: 1280, height: 900 } } },
    { name: 'webkit-phone', use: { ...devices['iPhone 14'] } },
  ],
});
