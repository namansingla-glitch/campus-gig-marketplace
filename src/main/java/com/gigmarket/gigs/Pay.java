package com.gigmarket.gigs;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Rupee amounts: reading what people type, and showing amounts the Indian way (₹1,24,500). */
public final class Pay {
    /** Largest amount accepted in a filter or a gig. */
    public static final BigDecimal MAX = new BigDecimal("10000000");
    public static final String FILTER_HELP = "Type a number of rupees, for example 500.";

    private Pay() {}

    /**
     * Reads a rupee amount typed by a person: digits, with optional commas, spaces and a leading ₹.
     * Returns null for empty input; throws IllegalArgumentException with a message that says how to fix it.
     */
    public static BigDecimal parse(String typed) {
        if (typed == null) return null;
        String t = typed.trim().replace("₹", "").replace(",", "").replace(" ", "");
        if (t.isEmpty()) return null;
        if (!t.matches("\\d{1,8}")) throw new IllegalArgumentException(FILTER_HELP);
        BigDecimal v = new BigDecimal(t);
        if (v.compareTo(MAX) > 0) throw new IllegalArgumentException("Type an amount up to ₹1,00,00,000.");
        return v;
    }

    /** ₹350, ₹1,500, ₹1,24,500; paise only when there are any (₹99.50). Java's own formatter cannot group the Indian way. */
    public static String format(BigDecimal amount) {
        if (amount == null) return "";
        BigDecimal a = amount.setScale(2, RoundingMode.HALF_UP);
        boolean negative = a.signum() < 0;
        a = a.abs();
        String whole = a.toBigInteger().toString();
        int paise = a.remainder(BigDecimal.ONE).movePointRight(2).intValue();
        StringBuilder out = new StringBuilder();
        int n = whole.length();
        if (n <= 3) {
            out.append(whole);
        } else {
            String last3 = whole.substring(n - 3);
            String rest = whole.substring(0, n - 3);
            StringBuilder head = new StringBuilder();
            for (int i = rest.length(); i > 0; i -= 2) {
                head.insert(0, rest.substring(Math.max(0, i - 2), i));
                if (i - 2 > 0) head.insert(0, ',');
            }
            out.append(head).append(',').append(last3);
        }
        if (paise > 0) out.append('.').append(String.format("%02d", paise));
        return (negative ? "-" : "") + "₹" + out;
    }
}
