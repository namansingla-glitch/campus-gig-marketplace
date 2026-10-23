package com.gigmarket.auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.gigmarket.auth.AccountService.JoinResult;
import com.gigmarket.auth.AccountService.LoginOutcome;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class AccountServiceTest {
    private InMemoryAccountStore store;
    private PasswordHasher hasher;
    private AccountService accounts;

    @BeforeEach
    void setUp() {
        store = new InMemoryAccountStore();
        hasher = new PasswordHasher(1_000);
        accounts = new AccountService(store, hasher);
    }

    private Account admin() {
        return store.add("Naman", "naman@woxsen.edu.in", hasher.hash("secret1"), Account.Role.ADMIN, Account.Status.ACTIVE);
    }

    // ---- Join ----

    @Test
    void aStudentEmailJoinsAsAnActiveStudent() {
        JoinResult r = accounts.join("1", "Riya Sharma", "Riya@Woxsen.edu.in", "secret1");
        assertEquals(JoinResult.Kind.ACTIVE, r.getKind());
        assertEquals(Account.Role.STUDENT, r.getAccount().getRole());
        assertEquals("riya@woxsen.edu.in", r.getAccount().getEmail());
        assertEquals("student", r.getAccount().sessionRole());
        assertTrue(hasher.verify("secret1", r.getAccount().getPasswordHash()), "the password is stored as a hash");
    }

    @Test
    void aFacultyEmailJoinsAsPendingFaculty() {
        JoinResult r = accounts.join("1", "Anika Rao", "a.rao@faculty.woxsen.com", "secret1");
        assertEquals(JoinResult.Kind.PENDING, r.getKind());
        assertEquals(Account.Role.FACULTY, r.getAccount().getRole());
        assertEquals(Account.Status.PENDING, r.getAccount().getStatus());
        assertEquals(1, accounts.pendingFaculty().size());
    }

    @Test
    void anOutsideEmailIsRefusedWithTheFix() {
        JoinResult r = accounts.join("1", "Riya", "riya@gmail.com", "secret1");
        assertEquals(JoinResult.Kind.ERROR, r.getKind());
        assertEquals("email", r.getField());
        assertTrue(r.getMessage().contains("@woxsen.edu.in"));
        assertTrue(store.accounts.isEmpty());
    }

    @Test
    void eachFieldIsChecked() {
        assertEquals("university", accounts.join("9", "Riya", "riya@woxsen.edu.in", "secret1").getField());
        assertEquals("university", accounts.join("abc", "Riya", "riya@woxsen.edu.in", "secret1").getField());
        assertEquals("university", accounts.join(null, "Riya", "riya@woxsen.edu.in", "secret1").getField());
        assertEquals("name", accounts.join("1", " ", "riya@woxsen.edu.in", "secret1").getField());
        assertEquals("email", accounts.join("1", "Riya", "", "secret1").getField());
        assertEquals("password", accounts.join("1", "Riya", "riya@woxsen.edu.in", "12345").getField());
        assertTrue(store.accounts.isEmpty());
    }

    @Test
    void anEmailCanJoinOnlyOnce() {
        accounts.join("1", "Riya", "riya@woxsen.edu.in", "secret1");
        JoinResult again = accounts.join("1", "Riya again", " RIYA@woxsen.edu.in ", "secret2");
        assertEquals(JoinResult.Kind.ERROR, again.getKind());
        assertEquals("email", again.getField());
        assertEquals(1, store.accounts.size());
    }

    // ---- Log in ----

    @Test
    void theRightPasswordLogsIn() {
        accounts.join("1", "Riya", "riya@woxsen.edu.in", "secret1");
        AccountService.LoginResult r = accounts.login(" Riya@woxsen.edu.in", "secret1");
        assertEquals(LoginOutcome.OK, r.getOutcome());
        assertEquals("riya@woxsen.edu.in", r.getAccount().getEmail());
    }

    @Test
    void aWrongPasswordAndAnUnknownEmailLookTheSame() {
        accounts.join("1", "Riya", "riya@woxsen.edu.in", "secret1");
        assertEquals(LoginOutcome.INVALID, accounts.login("riya@woxsen.edu.in", "wrong1").getOutcome());
        assertEquals(LoginOutcome.INVALID, accounts.login("nobody@woxsen.edu.in", "secret1").getOutcome());
        assertEquals(LoginOutcome.INVALID, accounts.login(null, null).getOutcome());
        assertNull(accounts.login("riya@woxsen.edu.in", "wrong1").getAccount());
    }

    @Test
    void pendingFacultyCannotLogInAndOnlyLearnItWithTheRightPassword() {
        accounts.join("1", "Anika", "a.rao@faculty.woxsen.com", "secret1");
        assertEquals(LoginOutcome.PENDING, accounts.login("a.rao@faculty.woxsen.com", "secret1").getOutcome());
        assertEquals(LoginOutcome.INVALID, accounts.login("a.rao@faculty.woxsen.com", "guess1").getOutcome());
    }

    // ---- Approvals ----

    @Test
    void anAdminApprovesFacultyWhoCanThenLogInAsPoster() {
        Account admin = admin();
        Account faculty = accounts.join("1", "Anika", "a.rao@faculty.woxsen.com", "secret1").getAccount();
        assertTrue(accounts.decide(admin.getId(), faculty.getId(), true));
        AccountService.LoginResult r = accounts.login("a.rao@faculty.woxsen.com", "secret1");
        assertEquals(LoginOutcome.OK, r.getOutcome());
        assertEquals("poster", r.getAccount().sessionRole());
        assertTrue(accounts.pendingFaculty().isEmpty());
    }

    @Test
    void aRejectedAccountIsToldSoWithTheRightPassword() {
        Account admin = admin();
        Account faculty = accounts.join("1", "Fake", "fake@faculty.woxsen.com", "secret1").getAccount();
        assertTrue(accounts.decide(admin.getId(), faculty.getId(), false));
        assertEquals(LoginOutcome.REJECTED, accounts.login("fake@faculty.woxsen.com", "secret1").getOutcome());
    }

    @Test
    void onlyAnActiveAdminCanDecideAndOnlyOnce() {
        Account student = accounts.join("1", "Riya", "riya@woxsen.edu.in", "secret1").getAccount();
        Account faculty = accounts.join("1", "Anika", "a.rao@faculty.woxsen.com", "secret1").getAccount();
        assertFalse(accounts.decide(student.getId(), faculty.getId(), true), "a student cannot approve");
        assertFalse(accounts.decide(999, faculty.getId(), true), "an unknown id cannot approve");
        Account admin = admin();
        assertTrue(accounts.decide(admin.getId(), faculty.getId(), true));
        assertFalse(accounts.decide(admin.getId(), faculty.getId(), false), "an approved account is no longer pending");
        assertFalse(accounts.decide(admin.getId(), student.getId(), true), "a student was never pending");
    }

    @Test
    void adminLandsOnTheApprovalsPage() {
        assertEquals("admin/approvals", Auth.home(admin().sessionRole()));
        assertEquals("poster-dashboard.jsp", Auth.home("poster"));
        assertEquals("student-dashboard.jsp", Auth.home("student"));
    }
}
