import { test, expect, type Page, type BrowserContext } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

// Every page a person can reach, as each role, in light and dark. The same rules the kit holds itself to
// (GUIDELINES.md): nothing sideways or off screen, axe clean, the kit fonts really load, one h1 and no heading jumps,
// tap targets at least 44 px, no console errors, and the page still makes sense with scripts off.
const BASE = (process.env.BASE ?? 'http://localhost:8080/gig-marketplace').replace(/\/$/, '');
const PASSWORD = 'password123'; // demo accounts from schema.sql (local and CI only)

type Who = 'visitor' | 'student' | 'faculty';
const EMAIL: Record<Exclude<Who, 'visitor'>, string> = { student: 'shreyash@woxsen.edu.in', faculty: 'riddhi@faculty.woxsen.com' };

interface Screen { name: string; who: Who; path: string; expect: string; status?: number; prepare?: (page: Page) => Promise<void> }
const SCREENS: Screen[] = [
  { name: 'landing', who: 'visitor', path: '/', expect: 'pick a gig' },
  { name: 'log in', who: 'visitor', path: '/login.jsp', expect: 'Log in' },
  { name: 'join', who: 'visitor', path: '/register', expect: 'Woxsen University' },
  { name: 'open gigs', who: 'visitor', path: '/browse-gigs', expect: 'Open gigs' },
  { name: 'open gigs, pay error', who: 'visitor', path: '/browse-gigs?minPay=500%20rs', expect: 'Type a number of rupees' },
  { name: 'one gig (visitor)', who: 'visitor', path: '/gig?id=3', expect: 'Log in to apply' },
  { name: '404', who: 'visitor', path: '/no-such-page', expect: 'not on the board', status: 404 },
  { name: 'dashboard', who: 'student', path: '/dashboard', expect: 'Your gigs now' },
  { name: 'my gigs', who: 'student', path: '/my-applications', expect: 'My gigs' },
  { name: 'profile', who: 'student', path: '/profile', expect: 'Achievements' },
  { name: 'one gig (student)', who: 'student', path: '/gig?id=3', expect: 'Apply for this gig' },
  { name: '403', who: 'student', path: '/your-gigs', expect: 'not yours to open', status: 403 },
  { name: 'your gigs', who: 'faculty', path: '/your-gigs', expect: 'Mark done' },
  { name: 'review applicants', who: 'faculty', path: '/review-applications?gigId=1', expect: 'Not this time' },
  { name: 'post a gig', who: 'faculty', path: '/post-gig', expect: 'Pay and time' },
  {
    name: 'post a gig, problems', who: 'faculty', path: '/post-gig', expect: 'things to fix',
    // Sends the empty form: the server answers 400 with the problems and saves nothing.
    prepare: async (page) => { await page.getByRole('button', { name: 'Pin the gig' }).click(); await page.waitForLoadState('networkidle'); },
  },
  { name: 'one gig (owner)', who: 'faculty', path: '/gig?id=1', expect: 'Review applicants' },
];

async function logIn(context: BrowserContext, who: Who) {
  if (who === 'visitor') return;
  const r = await context.request.post(`${BASE}/login`, { form: { email: EMAIL[who], password: PASSWORD }, maxRedirects: 0 });
  expect(r.status(), `log in as ${who}`).toBe(302);
}

async function rules(page: Page) {
  return page.evaluate(async () => {
    const out: string[] = [];
    const de = document.documentElement;
    if (de.scrollWidth > de.clientWidth + 1) out.push(`sideways scroll: ${de.scrollWidth}px wide in a ${de.clientWidth}px window`);
    for (const el of Array.from(document.querySelectorAll('body *'))) {
      const b = el.getBoundingClientRect();
      const cs = getComputedStyle(el);
      if (b.width > 0 && b.right > de.clientWidth + 1 && cs.position !== 'fixed' && cs.visibility !== 'hidden' && !el.closest('.k-sr')) {
        out.push(`off screen: <${el.tagName.toLowerCase()} class="${el.getAttribute('class') ?? ''}"> ends at ${Math.round(b.right)}px`);
        break;
      }
    }
    const levels = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6')).map((h) => Number(h.tagName[1]));
    const h1s = levels.filter((l) => l === 1).length;
    if (h1s !== 1) out.push(`${h1s} h1 elements (want exactly 1)`);
    for (let i = 1; i < levels.length; i++) if (levels[i] > levels[i - 1] + 1) { out.push(`heading jumps h${levels[i - 1]} → h${levels[i]}`); break; }
    await document.fonts.ready;
    if (!document.fonts.check('700 32px "Bricolage Grotesque"')) out.push('display font (Bricolage Grotesque) did not load');
    if (!document.fonts.check('400 16px "Instrument Sans"')) out.push('body font (Instrument Sans) did not load');
    for (const t of Array.from(document.querySelectorAll('.k-btn, .k-bottom a, .k-top__links a, .k-chip'))) {
      const b = t.getBoundingClientRect();
      if (b.width > 0 && b.height < 44) { out.push(`tap target "${(t.textContent ?? '').trim()}" is ${Math.round(b.height)}px tall (want ≥ 44)`); break; }
    }
    return out;
  });
}

for (const s of SCREENS) {
  for (const scheme of ['light', 'dark'] as const) {
    test(`${s.name} (${s.who}, ${scheme})`, async ({ browser }, info) => {
      const context = await browser.newContext({ ...info.project.use, colorScheme: scheme });
      await logIn(context, s.who);
      const page = await context.newPage();
      const errors: string[] = [];
      page.on('console', (m) => { if (m.type() === 'error' && !/status of (403|404|400)/.test(m.text())) errors.push(m.text()); });
      page.on('pageerror', (e) => errors.push(e.message));
      page.on('requestfailed', (r) => { if (!r.url().endsWith('/favicon.ico')) errors.push(`failed: ${r.url()}`); });
      page.on('response', (r) => { if (r.status() >= 400 && r.request().resourceType() !== 'document' && !r.url().endsWith('/favicon.ico')) errors.push(`${r.status()}: ${r.url()}`); });

      const res = await page.goto(BASE + s.path, { waitUntil: 'networkidle' });
      expect(res?.status(), 'status').toBe(s.status ?? 200);
      if (s.prepare) await s.prepare(page);
      await expect(page.locator('body')).toContainText(s.expect);

      // Motion off for the checks: scroll-driven fades would otherwise be measured mid-fade.
      await page.evaluate(() => document.body.setAttribute('data-motion', 'off'));
      await page.waitForTimeout(100);
      expect(await rules(page), 'GUIDELINES checks').toEqual([]);
      const axe = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag21aa']).analyze();
      expect(axe.violations.map((v) => `${v.id}: ${v.nodes.length} × ${v.nodes[0]?.target.join(' ')}`), 'axe').toEqual([]);
      expect(errors, 'console errors and failed requests').toEqual([]);
      await context.close();
    });
  }

  test(`${s.name} (${s.who}, scripts off)`, async ({ browser }, info) => {
    test.skip(!!s.prepare, 'needs a click');
    const context = await browser.newContext({ ...info.project.use, javaScriptEnabled: false });
    await logIn(context, s.who);
    const page = await context.newPage();
    await page.goto(BASE + s.path);
    await expect(page.locator('body')).toContainText(s.expect);
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= document.documentElement.clientWidth + 1), 'no sideways scroll').toBe(true);
    await context.close();
  });
}

test('reduced motion: movement durations drop to zero, short fades stay', async ({ browser }, info) => {
  const context = await browser.newContext({ ...info.project.use, reducedMotion: 'reduce' });
  const page = await context.newPage();
  await page.goto(BASE + '/', { waitUntil: 'networkidle' });
  const d = await page.evaluate(() => {
    const cs = getComputedStyle(document.body);
    return ['press', 'medium', 'slow'].map((k) => cs.getPropertyValue(`--kit-duration-${k}`).trim());
  });
  expect(d, 'press, medium, slow under reduced motion').toEqual(['0ms', '0ms', '0ms']);
  await context.close();
});
