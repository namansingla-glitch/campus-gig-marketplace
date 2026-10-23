// Lighthouse on the main pages (phone settings, Lighthouse's default), with Playwright's Chromium.
// Prints each page's scores as a CI notice. LIMITS stays empty until the first real run in CI has given numbers;
// then each limit is set from what was measured (no invented numbers) and a lower score fails CI.
import lighthouse from 'lighthouse';
import * as chromeLauncher from 'chrome-launcher';
import { chromium } from '@playwright/test';

const BASE = (process.env.BASE ?? 'http://localhost:8080/gig-marketplace').replace(/\/$/, '');
const LIMITS = {}; // e.g. { performance: 90, accessibility: 100 }, set from the first measured run
const PAGES = [
  { name: 'landing', path: '/' },
  { name: 'open gigs', path: '/browse-gigs' },
  { name: 'one gig', path: '/gig?id=3' },
  { name: 'student dashboard', path: '/dashboard', email: 'shreyash@woxsen.edu.in' },
  { name: 'your gigs', path: '/your-gigs', email: 'riddhi@faculty.woxsen.com' },
];

async function sessionCookie(email) {
  const r = await fetch(`${BASE}/login`, { method: 'POST', redirect: 'manual', body: new URLSearchParams({ email, password: 'password123' }) });
  const c = (r.headers.get('set-cookie') ?? '').match(/JSESSIONID=[^;]+/);
  if (r.status !== 302 || !c) throw new Error(`log in failed for ${email}: ${r.status}`);
  return c[0];
}

const chrome = await chromeLauncher.launch({ chromePath: chromium.executablePath(), chromeFlags: ['--headless=new', '--no-sandbox'] });
let failed = 0;
try {
  for (const p of PAGES) {
    const extraHeaders = p.email ? { Cookie: await sessionCookie(p.email) } : undefined;
    const { lhr } = await lighthouse(BASE + p.path, { port: chrome.port, output: 'json', logLevel: 'error', extraHeaders },
      { extends: 'lighthouse:default', settings: { onlyCategories: ['performance', 'accessibility', 'best-practices', 'seo'] } });
    const s = Object.fromEntries(Object.entries(lhr.categories).map(([k, v]) => [k, Math.round((v.score ?? 0) * 100)]));
    const lcp = lhr.audits['largest-contentful-paint']?.displayValue ?? '?';
    const cls = lhr.audits['cumulative-layout-shift']?.displayValue ?? '?';
    console.log(`::notice title=lighthouse ${p.name}::performance ${s.performance} · accessibility ${s.accessibility} · best practices ${s['best-practices']} · SEO ${s.seo} · LCP ${lcp} · CLS ${cls}`);
    for (const [k, min] of Object.entries(LIMITS)) {
      if ((s[k] ?? 0) < min) { failed++; console.log(`::error::lighthouse ${p.name}: ${k} ${s[k]} is below ${min}`); }
    }
    const misses = Object.values(lhr.audits)
      .filter((a) => a.scoreDisplayMode === 'binary' && a.score === 0)
      .map((a) => a.id);
    if (misses.length) console.log(`::warning title=lighthouse ${p.name} misses::${misses.join(', ')}`);
  }
} finally {
  await chrome.kill();
}
process.exit(failed ? 1 : 0);
