#!/usr/bin/env bash
# End-to-end check of accounts, access rules, every page and the gig flow (apply → hire → done) against a running app (Tomcat + MySQL), driven by real HTTP.
# Usage: BASE=http://localhost:8080/gig-marketplace MYSQL="mysql -h127.0.0.1 -uroot -proot gig_marketplace" tests/smoke.sh
# Expects a fresh database from src/main/resources/schema.sql (demo password: password123).
set -uo pipefail
BASE="${BASE:-http://localhost:8080/gig-marketplace}"
MYSQL="${MYSQL:-mysql -h127.0.0.1 -uroot -proot gig_marketplace}"
JAR="$(mktemp -d)"
SNAP="${SNAP:-}"   # folder to save page HTML for visual checks (optional)
[ -n "$SNAP" ] && mkdir -p "$SNAP"
snap() { [ -n "$SNAP" ] && printf '%s' "$BODY" > "$SNAP/$1.html"; return 0; }
FAILS=0
PASSES=0

ok()   { PASSES=$((PASSES + 1)); echo "  ok   $1"; }
bad()  { FAILS=$((FAILS + 1)); echo "::error::smoke: $1"; echo "  FAIL $1"; }
# req <jar-name> <method> <path> [curl args...] -> sets STATUS, LOCATION, BODY
req() {
  local jar="$JAR/$1" method="$2" path="$3"; shift 3
  local out; out="$(mktemp)"
  local meta
  meta="$(curl -sS -o "$out" -D "$JAR/headers" -w '%{http_code} %{redirect_url}' -b "$jar" -c "$jar" -X "$method" "$BASE$path" "$@")"
  STATUS="${meta%% *}"; LOCATION="${meta#* }"; BODY="$(cat "$out")"; HEADERS="$(cat "$JAR/headers")"; rm -f "$out"
}
expect_status() { [ "$STATUS" = "$2" ] && ok "$1 → $STATUS" || bad "$1: expected $2, got $STATUS ($LOCATION)"; }
expect_loc()    { [[ "$LOCATION" == *"$2"* ]] && ok "$1 → $2" || bad "$1: expected redirect to *$2*, got $STATUS '$LOCATION'"; }
expect_body()   { [[ "$BODY" == *"$2"* ]] && ok "$1 contains '$2'" || bad "$1: page does not contain '$2'"; }
expect_header() { [[ "${HEADERS,,}" == *"${2,,}"* ]] && ok "$1 has header '$2'" || bad "$1: missing header '$2'"; }
# The form token on the page just fetched.
csrf() { printf '%s' "$BODY" | grep -o 'name="csrf" value="[^"]*"' | head -1 | sed 's/.*value="//; s/"$//'; }
# Pages built with the kit never load Tailwind, Alpine or Inter, and show no invented figures.
expect_clean() {
  for x in 'Â' 'data-theme="auto"' cdn.tailwindcss.com alpinejs 'family=Inter' dummy 'Top Hired' '#4 of 37' '↑ 2' 'Done · paid' 'Insights'; do expect_no_body "$1" "$x"; done
}
expect_no_body(){ [[ "$BODY" != *"$2"* ]] && ok "$1 does not contain '$2'" || bad "$1: page contains '$2'"; }

echo "Pages"
req anon GET /;                          snap landing; expect_status "landing" 200; expect_no_body "landing" "Â"; expect_body "landing is light only (Naman, 24 Oct)" 'data-theme="light"'; expect_body "landing" "pick a gig."
req anon GET /login.jsp;                 snap login; expect_status "log in page" 200; expect_no_body "log in page" 'name="role"'
req anon GET "/login.jsp?error=%3Cscript%3Ealert(1)%3C/script%3E"; expect_no_body "log in page with a crafted error" "<script>alert"
req anon GET /register;                  snap register; expect_status "join page" 200; expect_body "join page" "Woxsen University"; expect_no_body "join page" 'name="role"'
req anon GET /kit/kit.css;               expect_status "kit css" 200
req anon GET /WEB-INF/views/register.jsp; [ "$STATUS" = 404 ] || [ "$STATUS" = 403 ] && ok "views are not public → $STATUS" || bad "WEB-INF view served: $STATUS"

echo "Join"
req anon POST /register --data-urlencode university=1 --data-urlencode name=Riya --data-urlencode email=riya@gmail.com --data-urlencode password=secret1
snap register-error; expect_status "join with gmail" 400; expect_body "join with gmail" "Use your Woxsen email"
req anon POST /register --data-urlencode university=1 --data-urlencode name=Riya --data-urlencode email=riya@woxsen.edu.in --data-urlencode password=12345
expect_status "join with a 5-character password" 400; expect_body "short password" "at least 6"
req riya POST /register --data-urlencode university=1 --data-urlencode "name=Riya Sharma" --data-urlencode email=Riya@Woxsen.edu.in --data-urlencode password=secret1 --data-urlencode role=poster
expect_loc "student joins (role=poster in the form is ignored)" "/dashboard"
req riya GET /dashboard;                 expect_status "student dashboard after join" 200; expect_body "new student's dashboard" "Nothing on the go"; expect_body "new student's dashboard" "0 points"
req anon POST /register --data-urlencode university=1 --data-urlencode name=Again --data-urlencode email=riya@woxsen.edu.in --data-urlencode password=secret1
expect_status "same email twice" 400; expect_body "same email twice" "already has an account"
req anon POST /register --data-urlencode university=1 --data-urlencode "name=Prof Test" --data-urlencode email=p.test@faculty.woxsen.com --data-urlencode password=secret1
snap register-pending; expect_status "faculty joins" 200; expect_body "faculty joins" "waiting for approval"

echo "Log in"
req x POST /login --data-urlencode email=naman@woxsen.edu.in --data-urlencode password=wrong12; expect_loc "wrong password" "error=invalid"
req x POST /login --data-urlencode email=nobody@woxsen.edu.in --data-urlencode password=password123; expect_loc "unknown email" "error=invalid"
req x POST /login --data-urlencode email=a.rao@faculty.woxsen.com --data-urlencode password=password123; expect_loc "pending faculty" "error=pending"
req anon GET "/login.jsp?error=pending"; snap login-pending
req naman POST /login --data-urlencode email=NAMAN@woxsen.edu.in --data-urlencode password=password123 --data-urlencode role=poster
expect_loc "student logs in (role in the form ignored)" "/dashboard"

echo "Access rules"
req naman POST /post-gig --data-urlencode title=X --data-urlencode description=Y --data-urlencode budget=100; expect_status "student posts a gig" 403
req naman GET "/review-applications?gigId=1"; expect_status "student opens review" 403
req anon GET "/review-applications?gigId=1"; expect_loc "logged out opens review" "login.jsp?error=login"
req anon POST /rate-gig --data-urlencode gigId=1 --data-urlencode rating=5; expect_loc "logged out rates" "login.jsp?error=login"
req naman POST /rate-gig --data-urlencode gigId=1 --data-urlencode rating=5; expect_status "student rates a gig they were not hired for" 403
req naman GET /admin/approvals; expect_status "student opens admin" 403

echo "Faculty and ownership"
req riddhi POST /login --data-urlencode email=riddhi@faculty.woxsen.com --data-urlencode password=password123; expect_loc "faculty logs in" "/your-gigs"
req riddhi GET /post-gig; RCSRF="$(csrf)"
$MYSQL -e "INSERT INTO Gigs (poster_id, title, description, budget, category) VALUES (3, 'Someone else''s gig', 'x', 100, 'Tutoring');" 2>/dev/null
OTHER=$($MYSQL -N -e "SELECT MAX(gig_id) FROM Gigs;" 2>/dev/null)
req riddhi GET "/review-applications?gigId=$OTHER"; expect_status "faculty opens another person's gig" 403
req riddhi POST /review-applications --data-urlencode action=hire --data-urlencode applicationId=1 --data-urlencode "gigId=$OTHER" --data-urlencode "csrf=$RCSRF"; expect_status "faculty hires on another person's gig (with a valid token)" 403
req riddhi POST /your-gigs --data-urlencode action=done --data-urlencode "gigId=$OTHER" --data-urlencode "csrf=$RCSRF"; expect_status "faculty marks another person's gig done" 403
$MYSQL -e "INSERT INTO Gigs (poster_id, title, description, budget, category) VALUES (2, 'Riddhi''s gig', 'x', 100, 'Tutoring');" 2>/dev/null
MINE=$($MYSQL -N -e "SELECT MAX(gig_id) FROM Gigs;" 2>/dev/null)
req riddhi GET "/review-applications?gigId=$MINE"; expect_status "faculty opens their own gig" 200

echo "Admin approval"
$MYSQL -e "UPDATE Students SET role='admin', status='active' WHERE email='shivam@woxsen.edu.in';" 2>/dev/null
req admin POST /login --data-urlencode email=shivam@woxsen.edu.in --data-urlencode password=password123; expect_loc "admin logs in" "admin/approvals"
req admin GET /admin/approvals; snap admin; expect_status "approvals page" 200; expect_body "approvals page" "a.rao@faculty.woxsen.com"; expect_body "approvals page" "p.test@faculty.woxsen.com"
CSRF="$(printf '%s' "$BODY" | grep -o 'name="csrf" value="[^"]*"' | head -1 | sed 's/.*value="//; s/"$//')"
RAO=$($MYSQL -N -e "SELECT student_id FROM Students WHERE email='a.rao@faculty.woxsen.com';" 2>/dev/null)
req admin POST /admin/approvals --data-urlencode action=approve --data-urlencode "accountId=$RAO"; expect_status "approve without the form token" 403
req admin POST /admin/approvals --data-urlencode action=approve --data-urlencode "accountId=$RAO" --data-urlencode "csrf=$CSRF"; expect_loc "approve" "done=approved"
req admin POST /admin/approvals --data-urlencode action=approve --data-urlencode "accountId=$RAO" --data-urlencode "csrf=$CSRF"; expect_loc "approve twice" "done=none"
req rao POST /login --data-urlencode email=a.rao@faculty.woxsen.com --data-urlencode password=password123; expect_loc "approved faculty logs in" "/your-gigs"
req rao GET /your-gigs; snap your-gigs-empty; expect_body "new faculty's gigs" "No gigs yet"
TEST=$($MYSQL -N -e "SELECT student_id FROM Students WHERE email='p.test@faculty.woxsen.com';" 2>/dev/null)
req admin POST /admin/approvals --data-urlencode action=reject --data-urlencode "accountId=$TEST" --data-urlencode "csrf=$CSRF"; expect_loc "reject" "done=rejected"
req x POST /login --data-urlencode email=p.test@faculty.woxsen.com --data-urlencode password=secret1; expect_loc "rejected faculty" "error=rejected"
req admin GET /admin/approvals; snap admin-empty; expect_body "approvals after deciding" "Nobody waiting"

echo "Passwords are stored as hashes"
PLAIN=$($MYSQL -N -e "SELECT COUNT(*) FROM Students WHERE password_hash NOT LIKE 'pbkdf2_sha256\$%';" 2>/dev/null)
[ "$PLAIN" = "0" ] && ok "every password is a PBKDF2 hash" || bad "$PLAIN accounts have a password that is not a PBKDF2 hash"

echo "Feed"
req anon GET /browse-gigs; snap feed; expect_status "feed (visitor)" 200; expect_body "feed" "Tutor first-years in C pointers"; expect_body "feed" '₹2,500'; expect_body "feed" 'data-cat="0">Writing'; expect_no_body "feed" "dummy"; expect_no_body "feed lists only open gigs" "Record the lab safety video"; expect_no_body "feed lists only open gigs" "Help at the orientation desk"
req anon GET "/browse-gigs?category=Writing"; expect_body "Writing filter" "Proofread the placement brochure"; expect_no_body "Writing filter" "Tutor first-years"
req anon GET "/browse-gigs?category=Writing&category=Tutoring"; expect_body "two categories" "Proofread"; expect_body "two categories" "Tutor first-years"; expect_no_body "two categories" "Poster for the robotics expo"
req anon GET "/browse-gigs?minPay=1000"; expect_body "pay at least 1000" "Fix the lab booking form"; expect_no_body "pay at least 1000" "Tutor first-years"
req anon GET "/browse-gigs?minPay=500%20rs"; snap feed-error; expect_status "pay that is not a number" 200; expect_body "pay that is not a number" "Type a number of rupees"
req anon GET "/browse-gigs?category=%27%20OR%201%3D1%20--"; expect_body "unknown category is ignored" "Tutor first-years"
req anon GET "/browse-gigs?category=Writing&minPay=100000"; expect_body "nothing matches" "No open gigs match"
$MYSQL -e "INSERT INTO Gigs (poster_id, title, description, budget, category, when_text, where_text) VALUES (2, '<script>alert(1)</script>', '<img src=x onerror=alert(2)>', 100, 'Writing', '<b>when</b>', 'where');" 2>/dev/null
req anon GET /browse-gigs; expect_body "feed escapes titles" "&lt;script&gt;alert(1)&lt;/script&gt;"; expect_no_body "feed escapes titles" "<script>alert(1)"
XSS=$($MYSQL -N -e "SELECT MAX(gig_id) FROM Gigs;" 2>/dev/null)
req anon GET "/gig?id=$XSS"; expect_no_body "detail escapes" "<img src=x"; expect_no_body "detail escapes" "<b>when</b>"

echo "Gig detail"
req anon GET "/gig?id=abc"; expect_status "gig with a bad id" 404
req anon GET "/gig?id=999999"; expect_status "gig that does not exist" 404
req anon GET "/gig?id=3"; snap gig-visitor; expect_status "gig (visitor)" 200; expect_body "gig (visitor)" "Log in to apply"; expect_body "gig (visitor)" "What needs doing"
req anon GET "/apply-gig.jsp?gigId=3"; expect_loc "old apply link" "gig?id=3"
req naman POST /login --data-urlencode email=naman@woxsen.edu.in --data-urlencode password=password123; expect_loc "student logs in again" "/dashboard"
req naman GET "/gig?id=3"; snap gig-student; expect_body "gig (student)" "Apply for this gig"; NCSRF="$(csrf)"
req naman POST /apply-gig -F gigId=3 -F "pitchText=No token"; expect_status "apply without the form token" 403
req naman POST /apply-gig -F "csrf=$NCSRF" -F gigId=3 -F pitchText=; expect_loc "apply with no pitch" "error=pitch"
BAD="$(mktemp --suffix=.jsp)"; echo '<% out.print(1); %>' > "$BAD"
req naman POST /apply-gig -F "csrf=$NCSRF" -F gigId=3 -F "pitchText=I made the fest poster." -F "portfolioFile=@$BAD;filename=../../shell.jsp"; expect_loc "apply with a .jsp file" "error=type"
PDF="$(mktemp --suffix=.pdf)"; printf '%%PDF-1.4\n%%EOF\n' > "$PDF"
req naman POST /apply-gig -F "csrf=$NCSRF" -F gigId=3 -F "pitchText=I made the fest poster." -F "portfolioFile=@$PDF;filename=../../My CV.pdf"; expect_loc "apply" "gig?id=3&applied=1"
req naman GET "/gig?id=3&applied=1"; snap gig-applied; expect_body "after applying" "Application sent"; expect_body "after applying" 'data-status="pending">Pending' ; expect_no_body "after applying" "Send application"
STORED=$($MYSQL -N -e "SELECT portfolio_path FROM Applications WHERE gig_id=3 ORDER BY application_id DESC LIMIT 1;" 2>/dev/null)
[[ "$STORED" =~ /[0-9a-f-]{36}\.pdf$ && "$STORED" != *..* ]] && ok "upload stored under a safe random name" || bad "upload stored as '$STORED'"
req naman POST /apply-gig -F "csrf=$NCSRF" -F gigId=3 -F "pitchText=Again"; expect_loc "apply twice" "error=already"
$MYSQL -e "UPDATE Gigs SET status='Done', done_at=NOW() WHERE gig_id=5;" 2>/dev/null
req naman GET "/gig?id=5"; expect_body "finished gig" "no longer taking applications"
req naman POST /apply-gig -F "csrf=$NCSRF" -F gigId=5 -F "pitchText=Hi"; expect_loc "apply to a closed gig" "error=closed"
req anon GET /browse-gigs; expect_no_body "closed gigs leave the feed" "Proofread the placement brochure"
req riddhi GET "/gig?id=3"; snap gig-owner; expect_body "gig (owner)" "Review applicants (1)"; expect_no_body "gig (owner)" "Apply for this gig"

echo "Post a gig"
req riddhi GET /post-gig; snap post-gig; expect_status "post a gig form" 200; expect_body "post a gig form" "Pay and time"; expect_clean "post a gig form"; RCSRF="$(csrf)"
req riddhi POST /post-gig --data-urlencode "title=No token" --data-urlencode "description=x" --data-urlencode pay=100 --data-urlencode category=Design --data-urlencode "when=a" --data-urlencode "where=b"
expect_status "post without the form token" 403
req riddhi POST /post-gig --data-urlencode "csrf=$RCSRF" --data-urlencode "title=Help at the open day" --data-urlencode "description=Guide visitors." --data-urlencode pay=700 --data-urlencode "category=Event Support" --data-urlencode "when=Sun, 10 am–2 pm" --data-urlencode "where=Main gate"
expect_loc "post a gig" "your-gigs?posted=1"
WHERE=$($MYSQL -N -e "SELECT CONCAT(when_text,' | ',where_text,' | ',budget) FROM Gigs WHERE title='Help at the open day';" 2>/dev/null)
[ "$WHERE" = "Sun, 10 am–2 pm | Main gate | 700.00" ] && ok "when, where and pay saved" || bad "saved as '$WHERE'"
req riddhi POST /post-gig --data-urlencode "csrf=$RCSRF" --data-urlencode "title=<b>No place</b>" --data-urlencode "description=x" --data-urlencode "pay=500 rs" --data-urlencode category=Design --data-urlencode "when=Today"
snap post-gig-error; expect_status "post with problems" 400; expect_body "post with problems" "Two things to fix"; expect_body "post with problems" 'href="#pay"'; expect_body "post with problems" "Say where the work happens"
expect_body "post with problems keeps what was typed (escaped)" 'value="&lt;b&gt;No place&lt;/b&gt;"'; expect_no_body "post with problems" "<b>No place"
req riddhi POST /post-gig --data-urlencode "csrf=$RCSRF" --data-urlencode "title=Bad category" --data-urlencode "description=x" --data-urlencode pay=100 --data-urlencode category=Hacking --data-urlencode "when=a" --data-urlencode "where=b"
expect_status "post with an unknown category" 400; expect_body "post with an unknown category" "Choose a category."
req riddhi POST /post-gig --data-urlencode "csrf=$RCSRF" --data-urlencode "title=Help at the open day" --data-urlencode "description=Again" --data-urlencode pay=700 --data-urlencode "category=Event Support" --data-urlencode "when=a" --data-urlencode "where=b"
expect_status "same open title twice" 400; expect_body "same open title twice" "already have an open gig"

echo "Student pages (real counts only)"
req shreyash POST /login --data-urlencode email=shreyash@woxsen.edu.in --data-urlencode password=password123; expect_loc "shreyash logs in" "/dashboard"
req shreyash GET /dashboard; snap dashboard; expect_status "dashboard" 200; expect_clean "dashboard"
expect_body "dashboard earned" '₹700'; expect_body "dashboard now" "Record the lab safety video"; expect_body "dashboard now" "Hired · in progress"
expect_body "dashboard points" "107 points"; expect_body "dashboard meter" 'aria-valuenow="107"'; expect_body "dashboard meter" "393 to Silver"
expect_no_body "dashboard now leaves out finished gigs" "Help at the orientation desk"
req shreyash GET /my-applications; snap my-applications; expect_status "my gigs" 200; expect_clean "my gigs"
expect_body "my gigs" "Help at the orientation desk"; expect_body "my gigs" 'data-status="done">Done'; expect_body "my gigs" "Finished "
req shreyash GET /profile; snap profile; expect_status "profile" 200; expect_clean "profile"
expect_body "profile" "shreyash@woxsen.edu.in · Woxsen University"; expect_body "profile" "Bronze"; expect_body "profile standing" "You are #1 of "
expect_body "profile achievement earned" 'data-earned="true"'; expect_body "profile achievement" "First gig done"; expect_body "profile achievement to do" "1 of 10 so far."
req mohak POST /login --data-urlencode email=mohak@woxsen.edu.in --data-urlencode password=password123
req mohak GET /profile; expect_body "profile with nothing this month" "Finish a gig this month"; expect_body "profile with nothing done" "Finish your first gig."

echo "Who can open what"
req shreyash GET /your-gigs; expect_status "student opens your gigs" 403; snap 403; expect_body "403 page" "not yours to open"; expect_clean "403 page"
req riddhi GET /dashboard; expect_status "faculty opens the student dashboard" 403
req riddhi GET /profile; expect_status "faculty opens the student profile" 403
req riddhi GET /my-applications; expect_status "faculty opens my gigs" 403
req anon GET /dashboard; expect_loc "visitor opens the dashboard" "login.jsp?error=login"
req anon GET /your-gigs; expect_loc "visitor opens your gigs" "login.jsp?error=login"
req anon GET /no-such-page; expect_status "unknown page" 404; snap 404; expect_body "404 page" "not on the board"; expect_body "404 page" "kit/kit.css"

echo "Review: reject, hire, mark done"
MOHAK_APP=$($MYSQL -N -e "SELECT application_id FROM Applications WHERE gig_id=1 AND applicant_id=(SELECT student_id FROM Students WHERE email='mohak@woxsen.edu.in');" 2>/dev/null)
SHIVAM_APP=$($MYSQL -N -e "SELECT application_id FROM Applications WHERE gig_id=1 AND applicant_id=(SELECT student_id FROM Students WHERE email='shivam@woxsen.edu.in');" 2>/dev/null)
req riddhi GET /your-gigs; snap your-gigs; expect_status "your gigs" 200; expect_clean "your gigs"; expect_body "your gigs" "Review applicants (2)"; expect_body "your gigs" "Mark done"; expect_body "your gigs" "Hired: Shreyash"
req riddhi GET "/review-applications?gigId=1"; snap review; expect_status "review" 200; expect_clean "review"; expect_body "review" "Hire Mohak"; expect_body "review" "Not this time"; RCSRF="$(csrf)"
req riddhi POST /review-applications --data-urlencode action=reject --data-urlencode gigId=1 --data-urlencode "applicationId=$SHIVAM_APP"; expect_status "reject without the form token" 403
req riddhi POST /review-applications --data-urlencode action=reject --data-urlencode gigId=1 --data-urlencode "applicationId=$SHIVAM_APP" --data-urlencode "csrf=$RCSRF"; expect_loc "reject" "done=rejected"
ST=$($MYSQL -N -e "SELECT status FROM Applications WHERE application_id=$SHIVAM_APP;" 2>/dev/null); [ "$ST" = "Rejected" ] && ok "rejected in the database" || bad "after reject: '$ST'"
req riddhi POST /review-applications --data-urlencode action=reject --data-urlencode gigId=1 --data-urlencode "applicationId=$SHIVAM_APP" --data-urlencode "csrf=$RCSRF"; expect_loc "reject twice" "done=none"
req riddhi POST /review-applications --data-urlencode action=hire --data-urlencode gigId=1 --data-urlencode "applicationId=$SHIVAM_APP" --data-urlencode "csrf=$RCSRF"; expect_loc "hire someone already not picked" "done=none"
req riddhi POST /review-applications --data-urlencode action=hire --data-urlencode gigId=1 --data-urlencode "applicationId=$MOHAK_APP" --data-urlencode "csrf=$RCSRF"; expect_loc "hire" "done=hired"
ST=$($MYSQL -N -e "SELECT CONCAT(g.status,' | ',a.status) FROM Gigs g JOIN Applications a ON a.gig_id=g.gig_id WHERE a.application_id=$MOHAK_APP;" 2>/dev/null)
[ "$ST" = "In progress | Hired" ] && ok "hire moves the gig to In progress" || bad "after hire: '$ST'"
req anon GET /browse-gigs; expect_no_body "hired gig leaves the feed" "Tutor first-years"
req mohak GET /my-applications; expect_body "student sees the hire" "Hired · in progress"
req riddhi POST /your-gigs --data-urlencode action=done --data-urlencode gigId=1; expect_status "mark done without the form token" 403
req riddhi POST /your-gigs --data-urlencode action=done --data-urlencode gigId=1 --data-urlencode "csrf=$RCSRF"; expect_loc "mark done" "done=1"
ST=$($MYSQL -N -e "SELECT CONCAT(status,' | ',done_at IS NOT NULL) FROM Gigs WHERE gig_id=1;" 2>/dev/null); [ "$ST" = "Done | 1" ] && ok "marked done with a date" || bad "after done: '$ST'"
req riddhi POST /your-gigs --data-urlencode action=done --data-urlencode gigId=1 --data-urlencode "csrf=$RCSRF"; expect_loc "mark done twice" "done=none"
req mohak GET /dashboard; expect_body "student's earnings count the done gig" '₹350'; expect_body "student's points" "103 points"
req mohak GET /profile; expect_body "first gig achievement" "Earned "; expect_body "standing after a done gig" "You are #2 of "

echo "Portfolio downloads"
APP=$($MYSQL -N -e "SELECT application_id FROM Applications WHERE gig_id=3 AND portfolio_path IS NOT NULL ORDER BY application_id DESC LIMIT 1;" 2>/dev/null)
req riddhi GET "/portfolio?application=$APP"; expect_status "gig owner downloads the portfolio" 200
expect_header "portfolio" "Content-Disposition: attachment"; expect_header "portfolio" "X-Content-Type-Options: nosniff"; expect_header "portfolio" "Content-Type: application/pdf"; expect_body "portfolio" "%PDF-1.4"
req naman GET "/portfolio?application=$APP"; expect_status "the student who sent it" 200
req shreyash GET "/portfolio?application=$APP"; expect_status "another student" 403
req rao GET "/portfolio?application=$APP"; expect_status "faculty who does not own the gig" 403
req anon GET "/portfolio?application=$APP"; expect_loc "visitor" "login.jsp?error=login"
req riddhi GET "/portfolio?application=abc"; expect_status "bad id" 404
$MYSQL -e "UPDATE Applications SET portfolio_path='/etc/passwd' WHERE application_id=$MOHAK_APP;" 2>/dev/null
req riddhi GET "/portfolio?application=$MOHAK_APP"; expect_status "a stored path outside the upload folder is never opened" 404; expect_no_body "tampered path" "root:"
req riddhi GET "/review-applications?gigId=3"; expect_body "review links the portfolio" "/portfolio?application=$APP"; expect_no_body "review" 'href="#"'

echo "Escaping on the new pages"
$MYSQL -e "UPDATE Students SET name='<i>Evil</i> Naman' WHERE email='naman@woxsen.edu.in'; UPDATE Applications SET pitch_text='<script>alert(3)</script>' WHERE application_id=$APP; UPDATE Gigs SET title='</title><script>alert(4)</script>' WHERE gig_id=3;" 2>/dev/null
req naman POST /login --data-urlencode email=naman@woxsen.edu.in --data-urlencode password=password123
req naman GET /dashboard; expect_no_body "greeting escapes the name" "<i>Evil"; expect_body "greeting escapes the name" "&lt;i&gt;Evil"
req naman GET /my-applications; expect_no_body "my gigs escapes titles" "<script>alert(4)"
req riddhi GET "/review-applications?gigId=3"; expect_no_body "review escapes the pitch" "<script>alert(3)"; expect_no_body "review escapes the name" "<i>Evil"; expect_no_body "review escapes the page title" "</title><script>"
req anon GET "/gig?id=3"; expect_no_body "gig page escapes its title tag" "</title><script>"

echo "Old addresses and old files"
req naman GET /student-dashboard.jsp; expect_loc "old student dashboard" "/dashboard"
req riddhi GET /poster-dashboard.jsp; expect_loc "old faculty dashboard" "/your-gigs"
req riddhi GET /post-gig.jsp; expect_loc "old post form" "/post-gig"
req naman GET /student-profile.jsp; expect_loc "old profile" "/profile"
req riddhi GET "/review-applications.jsp?gigId=3"; expect_loc "old review" "review-applications?gigId=3"
req anon GET /header.jsp; expect_status "Tailwind header is gone" 404
LEFT=$(grep -rlE "cdn.tailwindcss.com|alpinejs|family=Inter|header.jsp|footer.jsp" src/main/webapp 2>/dev/null | grep -v '^src/main/webapp/kit/' | tr '\n' ' ')
[ -z "$LEFT" ] && ok "no page uses Tailwind, Alpine, Inter or the old header/footer" || bad "still referenced in: $LEFT"

echo "Log out"
req naman GET /logout; expect_loc "log out" "login.jsp?error=out"
req naman GET /dashboard; expect_loc "dashboard after log out" "login.jsp"

rm -rf "$JAR"
echo "smoke: $PASSES passed, $FAILS failed"
echo "::notice::campus-gig smoke: $PASSES passed, $FAILS failed"
[ "$FAILS" = 0 ]
