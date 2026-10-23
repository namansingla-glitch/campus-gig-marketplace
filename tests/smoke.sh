#!/usr/bin/env bash
# End-to-end check of accounts and access rules against a running app (Tomcat + MySQL), driven by real HTTP.
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
  meta="$(curl -sS -o "$out" -w '%{http_code} %{redirect_url}' -b "$jar" -c "$jar" -X "$method" "$BASE$path" "$@")"
  STATUS="${meta%% *}"; LOCATION="${meta#* }"; BODY="$(cat "$out")"; rm -f "$out"
}
expect_status() { [ "$STATUS" = "$2" ] && ok "$1 → $STATUS" || bad "$1: expected $2, got $STATUS ($LOCATION)"; }
expect_loc()    { [[ "$LOCATION" == *"$2"* ]] && ok "$1 → $2" || bad "$1: expected redirect to *$2*, got $STATUS '$LOCATION'"; }
expect_body()   { [[ "$BODY" == *"$2"* ]] && ok "$1 contains '$2'" || bad "$1: page does not contain '$2'"; }
expect_no_body(){ [[ "$BODY" != *"$2"* ]] && ok "$1 does not contain '$2'" || bad "$1: page contains '$2'"; }

echo "Pages"
req anon GET /;                          snap landing; expect_status "landing" 200; expect_body "landing" "pick a gig."
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
expect_loc "student joins (role=poster in the form is ignored)" "student-dashboard.jsp"
req riya GET /student-dashboard.jsp;     expect_status "student dashboard after join" 200
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
expect_loc "student logs in (role in the form ignored)" "student-dashboard.jsp"

echo "Access rules"
req naman POST /post-gig --data-urlencode title=X --data-urlencode description=Y --data-urlencode budget=100; expect_status "student posts a gig" 403
req naman GET "/review-applications?gigId=1"; expect_status "student opens review" 403
req anon GET "/review-applications?gigId=1"; expect_loc "logged out opens review" "login.jsp?error=login"
req anon POST /rate-gig --data-urlencode gigId=1 --data-urlencode rating=5; expect_loc "logged out rates" "login.jsp?error=login"
req naman POST /rate-gig --data-urlencode gigId=1 --data-urlencode rating=5; expect_status "student rates a gig they were not hired for" 403
req naman GET /admin/approvals; expect_status "student opens admin" 403

echo "Faculty and ownership"
req riddhi POST /login --data-urlencode email=riddhi@faculty.woxsen.com --data-urlencode password=password123; expect_loc "faculty logs in" "poster-dashboard.jsp"
$MYSQL -e "INSERT INTO Gigs (poster_id, title, description, budget, category) VALUES (3, 'Someone else''s gig', 'x', 100, 'Tutoring');" 2>/dev/null
OTHER=$($MYSQL -N -e "SELECT MAX(gig_id) FROM Gigs;" 2>/dev/null)
req riddhi GET "/review-applications?gigId=$OTHER"; expect_status "faculty opens another person's gig" 403
req riddhi POST /review-applications --data-urlencode action=hire --data-urlencode applicationId=1 --data-urlencode "gigId=$OTHER"; expect_status "faculty hires on another person's gig" 403
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
req rao POST /login --data-urlencode email=a.rao@faculty.woxsen.com --data-urlencode password=password123; expect_loc "approved faculty logs in" "poster-dashboard.jsp"
TEST=$($MYSQL -N -e "SELECT student_id FROM Students WHERE email='p.test@faculty.woxsen.com';" 2>/dev/null)
req admin POST /admin/approvals --data-urlencode action=reject --data-urlencode "accountId=$TEST" --data-urlencode "csrf=$CSRF"; expect_loc "reject" "done=rejected"
req x POST /login --data-urlencode email=p.test@faculty.woxsen.com --data-urlencode password=secret1; expect_loc "rejected faculty" "error=rejected"
req admin GET /admin/approvals; snap admin-empty; expect_body "approvals after deciding" "Nobody waiting"

echo "Passwords are stored as hashes"
PLAIN=$($MYSQL -N -e "SELECT COUNT(*) FROM Students WHERE password_hash NOT LIKE 'pbkdf2_sha256\$%';" 2>/dev/null)
[ "$PLAIN" = "0" ] && ok "every password is a PBKDF2 hash" || bad "$PLAIN accounts have a password that is not a PBKDF2 hash"

echo "Feed"
req anon GET /browse-gigs; snap feed; expect_status "feed (visitor)" 200; expect_body "feed" "Tutor first-years in C pointers"; expect_body "feed" '₹2,500'; expect_body "feed" 'data-cat="0">Writing'; expect_no_body "feed" "dummy"
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
req naman POST /login --data-urlencode email=naman@woxsen.edu.in --data-urlencode password=password123; expect_loc "student logs in again" "student-dashboard.jsp"
req naman GET "/gig?id=3"; snap gig-student; expect_body "gig (student)" "Apply for this gig"
req naman POST /apply-gig -F gigId=3 -F pitchText=; expect_loc "apply with no pitch" "error=pitch"
BAD="$(mktemp --suffix=.jsp)"; echo '<% out.print(1); %>' > "$BAD"
req naman POST /apply-gig -F gigId=3 -F "pitchText=I made the fest poster." -F "portfolioFile=@$BAD;filename=../../shell.jsp"; expect_loc "apply with a .jsp file" "error=type"
PDF="$(mktemp --suffix=.pdf)"; printf '%%PDF-1.4\n%%EOF\n' > "$PDF"
req naman POST /apply-gig -F gigId=3 -F "pitchText=I made the fest poster." -F "portfolioFile=@$PDF;filename=../../My CV.pdf"; expect_loc "apply" "gig?id=3&applied=1"
req naman GET "/gig?id=3&applied=1"; snap gig-applied; expect_body "after applying" "Application sent"; expect_no_body "after applying" "Send application"
STORED=$($MYSQL -N -e "SELECT portfolio_path FROM Applications WHERE gig_id=3 ORDER BY application_id DESC LIMIT 1;" 2>/dev/null)
[[ "$STORED" =~ /[0-9a-f-]{36}\.pdf$ && "$STORED" != *..* ]] && ok "upload stored under a safe random name" || bad "upload stored as '$STORED'"
req naman POST /apply-gig -F gigId=3 -F "pitchText=Again"; expect_loc "apply twice" "error=already"
$MYSQL -e "UPDATE Gigs SET status='Closed' WHERE gig_id=5;" 2>/dev/null
req naman GET "/gig?id=5"; expect_body "closed gig" "This gig is closed"
req naman POST /apply-gig -F gigId=5 -F "pitchText=Hi"; expect_loc "apply to a closed gig" "error=closed"
req anon GET /browse-gigs; expect_no_body "closed gigs leave the feed" "Proofread the placement brochure"
req riddhi GET "/gig?id=3"; snap gig-owner; expect_body "gig (owner)" "Review applicants (1)"; expect_no_body "gig (owner)" "Apply for this gig"

echo "Post a gig with When and Where"
req riddhi POST /post-gig --data-urlencode "title=Help at the open day" --data-urlencode "description=Guide visitors." --data-urlencode budget=700 --data-urlencode "category=Event Support" --data-urlencode "whenText=Sun, 10 am–2 pm" --data-urlencode "whereText=Main gate"
expect_loc "post a gig" "poster-dashboard.jsp"
WHERE=$($MYSQL -N -e "SELECT CONCAT(when_text,' | ',where_text) FROM Gigs WHERE title='Help at the open day';" 2>/dev/null)
[ "$WHERE" = "Sun, 10 am–2 pm | Main gate" ] && ok "when and where saved" || bad "when/where saved as '$WHERE'"
req riddhi POST /post-gig --data-urlencode "title=No place" --data-urlencode "description=x" --data-urlencode budget=100 --data-urlencode category=Design --data-urlencode "whenText=Today"
expect_loc "post without where" "post-gig.jsp?error="
req riddhi POST /post-gig --data-urlencode "title=Bad category" --data-urlencode "description=x" --data-urlencode budget=100 --data-urlencode category=Hacking --data-urlencode "whenText=a" --data-urlencode "whereText=b"
expect_loc "post with an unknown category" "post-gig.jsp?error="

echo "Log out"
req naman GET /logout; expect_loc "log out" "login.jsp?error=out"
req naman GET /student-dashboard.jsp; expect_loc "dashboard after log out" "login.jsp"

rm -rf "$JAR"
echo "smoke: $PASSES passed, $FAILS failed"
echo "::notice::campus-gig smoke: $PASSES passed, $FAILS failed"
[ "$FAILS" = 0 ]
