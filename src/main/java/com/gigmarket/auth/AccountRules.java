package com.gigmarket.auth;

import java.util.Locale;

/** The account rules decided on 23 Oct 2026: role comes from the email domain; passwords are 6+ characters. */
public final class AccountRules {
    public static final int MIN_PASSWORD = 6;
    public static final int MAX_PASSWORD = 200;
    public static final int MAX_NAME = 100;
    public static final int MAX_EMAIL = 100;

    private AccountRules() {}

    /** Trimmed and lower-cased; null stays null. */
    public static String normalizeEmail(String email) {
        return email == null ? null : email.trim().toLowerCase(Locale.ROOT);
    }

    /**
     * Student for the university's student domain, faculty for its faculty domain, otherwise null.
     * The domain must match exactly: "x@faculty.woxsen.com.evil.org" and "x@notwoxsen.edu.in" do not count.
     */
    public static Account.Role roleFor(String email, University university) {
        String e = normalizeEmail(email);
        if (e == null || university == null) return null;
        int at = e.lastIndexOf('@');
        if (at <= 0 || at != e.indexOf('@') || at == e.length() - 1) return null;
        String domain = e.substring(at + 1);
        if (domain.equals(university.getFacultyDomain().toLowerCase(Locale.ROOT))) return Account.Role.FACULTY;
        if (domain.equals(university.getStudentDomain().toLowerCase(Locale.ROOT))) return Account.Role.STUDENT;
        return null;
    }

    /** Null when fine, otherwise the message to show (what is wrong and how to fix it). */
    public static String checkPassword(String password) {
        if (password == null || password.length() < MIN_PASSWORD) return "Use at least " + MIN_PASSWORD + " characters for your password.";
        if (password.length() > MAX_PASSWORD) return "Use at most " + MAX_PASSWORD + " characters for your password.";
        return null;
    }

    public static String checkName(String name) {
        String n = name == null ? "" : name.trim();
        if (n.isEmpty()) return "Add your full name.";
        if (n.length() > MAX_NAME) return "Keep your name under " + MAX_NAME + " characters.";
        return null;
    }

    public static String wrongDomainMessage(University u) {
        return "Use your " + shortName(u) + " email: @" + u.getStudentDomain() + " for students, @" + u.getFacultyDomain() + " for faculty.";
    }

    private static String shortName(University u) {
        String n = u.getName();
        return n.endsWith(" University") ? n.substring(0, n.length() - " University".length()) : n;
    }
}
