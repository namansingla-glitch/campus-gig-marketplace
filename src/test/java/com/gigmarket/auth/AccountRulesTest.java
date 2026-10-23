package com.gigmarket.auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.Test;

class AccountRulesTest {
    private final University woxsen = new University(1, "Woxsen University", "woxsen.edu.in", "faculty.woxsen.com");

    @Test
    void theEmailDomainDecidesTheRole() {
        assertEquals(Account.Role.STUDENT, AccountRules.roleFor("riya@woxsen.edu.in", woxsen));
        assertEquals(Account.Role.FACULTY, AccountRules.roleFor("a.rao@faculty.woxsen.com", woxsen));
    }

    @Test
    void caseAndSpacesDoNotMatter() {
        assertEquals(Account.Role.FACULTY, AccountRules.roleFor("  A.Rao@Faculty.Woxsen.COM ", woxsen));
    }

    @Test
    void lookAlikeAndOutsideDomainsAreRefused() {
        for (String e : new String[] {"x@gmail.com", "x@faculty.woxsen.com.evil.org", "x@notwoxsen.edu.in", "x@sub.woxsen.edu.in",
                "x@woxsen.com", "faculty.woxsen.com", "@faculty.woxsen.com", "x@", "a@b@faculty.woxsen.com", "", null}) {
            assertNull(AccountRules.roleFor(e, woxsen), String.valueOf(e));
        }
    }

    @Test
    void passwordsNeedSixCharacters() {
        assertNotNull(AccountRules.checkPassword("12345"));
        assertNull(AccountRules.checkPassword("123456"));
        assertNotNull(AccountRules.checkPassword(null));
        assertNotNull(AccountRules.checkPassword("x".repeat(201)));
    }

    @Test
    void namesAreRequiredAndBounded() {
        assertNotNull(AccountRules.checkName("   "));
        assertNull(AccountRules.checkName("Riya Sharma"));
        assertNotNull(AccountRules.checkName("x".repeat(101)));
    }

    @Test
    void theWrongDomainMessageSaysHowToFixIt() {
        assertEquals("Use your Woxsen email: @woxsen.edu.in for students, @faculty.woxsen.com for faculty.",
                AccountRules.wrongDomainMessage(woxsen));
    }
}
