package com.gigmarket.auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class PasswordHasherTest {
    private final PasswordHasher fast = new PasswordHasher(1_000);

    @Test
    void rightPasswordMatchesWrongOneDoesNot() {
        String stored = fast.hash("password123");
        assertTrue(fast.verify("password123", stored));
        assertFalse(fast.verify("password124", stored));
        assertFalse(fast.verify("", stored));
        assertFalse(fast.verify(null, stored));
    }

    @Test
    void sameGivesDifferentHashesBecauseOfTheSalt() {
        assertNotEquals(fast.hash("same"), fast.hash("same"));
    }

    @Test
    void storedFormatNamesTheAlgorithmAndWorkFactor() {
        String[] parts = fast.hash("x").split("\\$");
        assertEquals(4, parts.length);
        assertEquals("pbkdf2_sha256", parts[0]);
        assertEquals("1000", parts[1]);
    }

    @Test
    void theWorkFactorIsReadFromTheStoredValue() {
        String stored = new PasswordHasher(2_000).hash("abc123");
        assertTrue(fast.verify("abc123", stored), "a hasher with another default still checks old hashes");
    }

    @Test
    void malformedValuesNeverMatch() {
        for (String bad : new String[] {null, "", "password123", "md5$1$a$b", "pbkdf2_sha256$x$a$b", "pbkdf2_sha256$0$AA==$AA==",
                "pbkdf2_sha256$1000$not base64!$AA=="}) {
            assertFalse(fast.verify("password123", bad), String.valueOf(bad));
        }
    }

    @Test
    void theSeededDemoHashesMatchPassword123() {
        // Same values as src/main/resources/schema.sql (Naman and the pending faculty demo account).
        PasswordHasher real = new PasswordHasher();
        assertTrue(real.verify("password123", "pbkdf2_sha256$600000$ehLrVrT9dEKeNKqYXn9S9Q==$jnOUiN3MW5crsILCEIoad9SybTBiod3otFlanEJgBh0="));
        assertTrue(real.verify("password123", "pbkdf2_sha256$600000$H8FRPM0VrpVPayqMHbKcXQ==$6aOYwitBJ4g+BrJgBceCaJ46yuxCBS+Q9Ll5xrM/bz0="));
    }
}
