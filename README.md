# campus.gig

A campus gig board. Faculty pin small paid tasks; students pick the ones that fit between classes. Built for Woxsen University first.

## Features

- **Accounts by university email.** Join with your university email: `@woxsen.edu.in` makes you a student, `@faculty.woxsen.com` makes you faculty. Nobody picks their own role.
- **Faculty approval.** New faculty accounts wait until an admin approves them on the Approvals page.
- **Students:** browse open gigs, apply with a pitch and portfolio, track applications, rate finished gigs.
- **Faculty:** post gigs, review applicants on their own gigs, hire one, close the gig.
- **Gamified rewards:** Bronze / Silver / Gold tiers and achievements from completed gigs and earnings.
- **Look:** built with Naman's design kit (Campus Board skin): a kraft pin board, paper notes, light and dark, works on phones and with scripts off.

## Tech

- Java 11 Servlets + JSP on Apache Tomcat 9, built with Maven
- MySQL 8 over JDBC
- Front end: kit CSS and small framework-free effects in `src/main/webapp/kit/` (copied from a tagged kit build; see `kit/KIT_VERSION`). Pages not yet moved to the kit still use `header.jsp`.

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

Delete the demo accounts before anyone outside uses the site.

### Make yourself admin

There is no built-in admin (a known admin password in a public repo would let anyone in). Join with your own Woxsen email, then run once:

```sql
UPDATE Students SET role = 'admin', status = 'active' WHERE email = 'you@woxsen.edu.in';
```

Log in again and you land on **Approvals**.

## Tests

- `mvn verify`: unit tests for password hashing, the email rules, join, log in and approvals.
- `tests/smoke.sh`: drives a running app over HTTP (join, log in, pending faculty, approvals, role and ownership checks).
- CI (`.github/workflows/ci.yml`) runs both on every push, with MySQL and Tomcat on GitHub's machines.

## Security notes

- Passwords are stored as salted PBKDF2-HMAC-SHA256 hashes; 6 characters minimum.
- Every servlet checks the role from the session, and faculty can only review or hire on their own gigs.
- Admin decisions carry a per-session form token.
