#!/usr/bin/env bash
# End-to-end check of accounts and access rules against a running app (Tomcat + MySQL), driven by real HTTP.
# Usage: BASE=http://localhost:8080/gig-marketplace MYSQL="mysql -h127.0.0.1 -uroot -proot gig_marketplace" tests/smoke.sh
# Expects a fresh database from src/main/resources/schema.sql (demo password: password123).
set -uo pipefail
BASE="${BASE:-http://localhost:8080/gig-marketplace}"
MYSQL="${MYSQL:-mysql -h127.0.0.1 -uroot -proot gig_marketplace}"
JAR="$(mktemp -d)"
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
req anon GET /;                          expect_status "landing" 200; expect_body "landing" "pick a gig."
req anon GET /login.jsp;                 expect_status "log in page" 200; expect_no_body "log in page" 'name="role"'
req anon GET "/login.jsp?error=%3Cscript%3Ealert(1)%3C/script%3E"; expect_no_body "log in page with a crafted error" "<script>alert"
req anon GET /register;                  expect_status "join page" 200; expect_body "join page" "Woxsen University"; expect_no_body "join page" 'name="role"'
req anon GET /kit/kit.css;               expect_status "kit css" 200
req anon GET /WEB-INF/views/register.jsp; [ "$STATUS" = 404 ] || [ "$STATUS" = 403 ] && ok "views are not public → $STATUS" || bad "WEB-INF view served: $STATUS"

echo "Join"
req anon POST /register --data-urlencode university=1 --data-urlencode name=Riya --data-urlencode email=riya@gmail.com --data-urlencode password=secret1
expect_status "join with gmail" 400; expect_body "join with gmail" "Use your Woxsen email"
req anon POST /register --data-urlencode university=1 --data-urlencode name=Riya --data-urlencode email=riya@woxsen.edu.in --data-urlencode password=12345
expect_status "join with a 5-character password" 400; expect_body "short password" "at least 6"
req riya POST /register --data-urlencode university=1 --data-urlencode "name=Riya Sharma" --data-urlencode email=Riya@Woxsen.edu.in --data-urlencode password=secret1 --data-urlencode role=poster
expect_loc "student joins (role=poster in the form is ignored)" "student-dashboard.jsp"
req riya GET /student-dashboard.jsp;     expect_status "student dashboard after join" 200
req anon POST /register --data-urlencode university=1 --data-urlencode name=Again --data-urlencode email=riya@woxsen.edu.in --data-urlencode password=secret1
expect_status "same email twice" 400; expect_body "same email twice" "already has an account"
req anon POST /register --data-urlencode university=1 --data-urlencode "name=Prof Test" --data-urlencode email=p.test@faculty.woxsen.com --data-urlencode password=secret1
expect_status "faculty joins" 200; expect_body "faculty joins" "waiting for approval"

echo "Log in"
req x POST /login --data-urlencode email=naman@woxsen.edu.in --data-urlencode password=wrong12; expect_loc "wrong password" "error=invalid"
req x POST /login --data-urlencode email=nobody@woxsen.edu.in --data-urlencode password=password123; expect_loc "unknown email" "error=invalid"
req x POST /login --data-urlencode email=a.rao@faculty.woxsen.com --data-urlencode password=password123; expect_loc "pending faculty" "error=pending"
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
req admin GET /admin/approvals; expect_status "approvals page" 200; expect_body "approvals page" "a.rao@faculty.woxsen.com"; expect_body "approvals page" "p.test@faculty.woxsen.com"
CSRF="$(printf '%s' "$BODY" | grep -o 'name="csrf" value="[^"]*"' | head -1 | sed 's/.*value="//; s/"$//')"
RAO=$($MYSQL -N -e "SELECT student_id FROM Students WHERE email='a.rao@faculty.woxsen.com';" 2>/dev/null)
req admin POST /admin/approvals --data-urlencode action=approve --data-urlencode "accountId=$RAO"; expect_status "approve without the form token" 403
req admin POST /admin/approvals --data-urlencode action=approve --data-urlencode "accountId=$RAO" --data-urlencode "csrf=$CSRF"; expect_loc "approve" "done=approved"
req admin POST /admin/approvals --data-urlencode action=approve --data-urlencode "accountId=$RAO" --data-urlencode "csrf=$CSRF"; expect_loc "approve twice" "done=none"
req rao POST /login --data-urlencode email=a.rao@faculty.woxsen.com --data-urlencode password=password123; expect_loc "approved faculty logs in" "poster-dashboard.jsp"
TEST=$($MYSQL -N -e "SELECT student_id FROM Students WHERE email='p.test@faculty.woxsen.com';" 2>/dev/null)
req admin POST /admin/approvals --data-urlencode action=reject --data-urlencode "accountId=$TEST" --data-urlencode "csrf=$CSRF"; expect_loc "reject" "done=rejected"
req x POST /login --data-urlencode email=p.test@faculty.woxsen.com --data-urlencode password=secret1; expect_loc "rejected faculty" "error=rejected"
req admin GET /admin/approvals; expect_body "approvals after deciding" "Nobody waiting"

echo "Passwords are stored as hashes"
PLAIN=$($MYSQL -N -e "SELECT COUNT(*) FROM Students WHERE password_hash NOT LIKE 'pbkdf2_sha256\$%';" 2>/dev/null)
[ "$PLAIN" = "0" ] && ok "every password is a PBKDF2 hash" || bad "$PLAIN accounts have a password that is not a PBKDF2 hash"

echo "Log out"
req naman GET /logout; expect_loc "log out" "login.jsp?error=out"
req naman GET /student-dashboard.jsp; expect_loc "dashboard after log out" "login.jsp"

rm -rf "$JAR"
echo "smoke: $PASSES passed, $FAILS failed"
echo "::notice::campus-gig smoke: $PASSES passed, $FAILS failed"
[ "$FAILS" = 0 ]
