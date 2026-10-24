# campus.gig

A campus gig board. Faculty pin small paid tasks; students pick the ones that fit between classes. Built for Woxsen University first.

## Features

- **Accounts by university email.** Join with your university email: `@woxsen.edu.in` makes you a student, `@faculty.woxsen.com` makes you faculty. Nobody picks their own role.
- **Faculty approval.** New faculty accounts wait until an admin approves them on the Approvals page.
- **Students:** browse open gigs, apply with a pitch and an optional portfolio (PDF or image), follow each application on a dashboard and on My gigs.
- **Faculty:** post gigs, review applicants on their own gigs, hire one or say “Not this time”, then mark the gig done when the work is in.
- **A gig moves Open → In progress (someone hired) → Done (marked done).** Payment happens outside the site; nothing here says a gig was paid.
- **Gamified rewards, from real work only:** 100 points per finished gig + 10 per ₹1,000 earned. Bronze below 500, Silver from 500, Gold from 2,000. Achievements show the day they were earned. Each student sees only their own place this month.
- **Look:** built with Naman's design kit (Campus Board skin): a kraft pin board, paper notes, light theme only for now (dark is on the list for later), works on phones and with scripts off.

## Tech

- Java 11 Servlets + JSP on Apache Tomcat 9, built with Maven
- MySQL 8 over JDBC
- Front end: kit CSS and small framework-free effects in `src/main/webapp/kit/` (copied from a tagged kit build; see `kit/KIT_VERSION`).

## Run it locally

Needs JDK 11+, Maven and MySQL 8.

1. Create the database (this resets it):
   ```bash
   mysql -u root -p < src/main/resources/schema.sql
   ```
2. Tell the app how to reach MySQL. Nothing is stored in the code:
   ```bash
   export DB_URL="jdbc:mysql://localhost:3306/gig_marketplace"
   export DB_USER="root"
   export DB_PASSWORD="your-mysql-password"
   ```
3. Build, test and start Tomcat:
   ```bash
   mvn clean package cargo:run
   ```
4. Open `http://localhost:8080/gig-marketplace/`.

### Demo accounts (local testing only)

All use the password `password123`.

| Email | Role |
|---|---|
| `naman@woxsen.edu.in` | student |
| `riddhi@faculty.woxsen.com` | faculty |
| `a.rao@faculty.woxsen.com` | faculty, **waiting for approval** |
| `shreyash@woxsen.edu.in` | student with one finished gig and one in progress |
| `mohak@woxsen.edu.in`, `shivam@woxsen.edu.in` | students waiting on Riddhi's C tutoring gig |

The example gigs and applications are labelled “Example” in their text.

Delete the demo accounts before anyone outside uses the site.

### Make yourself admin

There is no built-in admin (a known admin password in a public repo would let anyone in). Join with your own Woxsen email, then run once:

```sql
UPDATE Students SET role = 'admin', status = 'active' WHERE email = 'you@woxsen.edu.in';
```

Log in again and you land on **Approvals**.

## Tests

- `mvn verify`: unit tests for password hashing, the email rules, join, log in, approvals, pay and dates, uploads, statuses, the post-a-gig rules and rewards.
- `tests/smoke.sh`: drives a running app over HTTP: every page, join and log in, approvals, who can open what, apply → hire / not picked → mark done, portfolio downloads, form tokens, escaping, no invented figures and no Tailwind left.
- `tests/e2e` (Playwright): every page as visitor, student and faculty in Chromium and WebKit (Safari's engine), desktop and phone, light and dark: no sideways scroll, axe accessibility check, the kit fonts load, one h1 and no heading jumps, tap targets at least 44 px, no console errors, still readable with scripts off, reduced motion. Run against a running app: `cd tests/e2e && npm ci && npx playwright install chromium webkit && BASE=http://localhost:8080/gig-marketplace npx playwright test`.
- `tests/e2e/lighthouse.mjs`: Lighthouse on the main pages (phone settings); CI fails below performance 85, accessibility 96, best practices 96, SEO 90 (set from the first measured run).
- CI (`.github/workflows/ci.yml`) runs all of these on every push, with MySQL and Tomcat on GitHub's machines.

## Security notes

- Passwords are stored as salted PBKDF2-HMAC-SHA256 hashes; 6 characters minimum.
- Every servlet that shows or changes private data checks the role from the session (browsing open gigs is public), and faculty can only review or hire on their own gigs.
- Every form that changes data (apply, post, hire, not this time, mark done, rating, admin decisions) carries a per-session token.
- Portfolios are stored under random names and only the gig's owner or the student who sent one can download it; it is always sent as a download, never shown as a page.
- Everything people type is escaped on every page, including the page title.
