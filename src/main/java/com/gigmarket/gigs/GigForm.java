package com.gigmarket.gigs;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.function.Function;

/**
 * The post-a-gig form: reads what was typed, and says what to fix next to each field (in form order).
 * Field names double as element ids, so the error summary links straight to the field.
 */
public final class GigForm {
    public static final String[] FIELDS = {"title", "category", "description", "pay", "when", "where", "applyBy", "doneBy"};
    public static final int MAX_TITLE = 200;
    public static final int MAX_DESCRIPTION = 4000;
    public static final int MAX_SHORT = 120;

    /** What was typed (trimmed, for re-showing) and the problems found. */
    public final Map<String, String> typed = new LinkedHashMap<>();
    public final Map<String, String> errors = new LinkedHashMap<>();
    public BigDecimal pay;
    public LocalDate applyBy;
    public LocalDate doneBy;

    private GigForm() {}

    public static GigForm empty() {
        GigForm f = new GigForm();
        for (String k : FIELDS) f.typed.put(k, "");
        return f;
    }

    public static GigForm read(Function<String, String> param, LocalDate today) {
        GigForm f = new GigForm();
        for (String k : FIELDS) {
            String v = param.apply(k);
            f.typed.put(k, v == null ? "" : v.trim());
        }
        String title = f.typed.get("title");
        if (title.isEmpty()) f.errors.put("title", "Give the gig a title.");
        else if (title.length() > MAX_TITLE) f.errors.put("title", "Keep the title under 200 characters.");

        if (!Categories.known(f.typed.get("category"))) f.errors.put("category", "Choose a category.");

        String d = f.typed.get("description");
        if (d.isEmpty()) f.errors.put("description", "Say what needs doing.");
        else if (d.length() > MAX_DESCRIPTION) f.errors.put("description", "Keep this under 4,000 characters.");

        try {
            f.pay = Pay.parse(f.typed.get("pay"));
            if (f.pay == null) f.errors.put("pay", "Add the pay in rupees, for example 500.");
            else if (f.pay.signum() == 0) f.errors.put("pay", "Pay must be more than ₹0.");
        } catch (IllegalArgumentException e) {
            f.errors.put("pay", e.getMessage());
        }

        String when = f.typed.get("when");
        if (when.isEmpty()) f.errors.put("when", "Say when the work happens, for example “Sat, 9 am–12 pm”.");
        else if (when.length() > MAX_SHORT) f.errors.put("when", "Keep this under 120 characters.");
        String where = f.typed.get("where");
        if (where.isEmpty()) f.errors.put("where", "Say where the work happens, or “Remote”.");
        else if (where.length() > MAX_SHORT) f.errors.put("where", "Keep this under 120 characters.");

        f.applyBy = date(f, "applyBy", "Apply by", today);
        f.doneBy = date(f, "doneBy", "Done by", today);
        if (f.applyBy != null && f.doneBy != null && f.doneBy.isBefore(f.applyBy) && !f.errors.containsKey("doneBy")) {
            f.errors.put("doneBy", "Done by must be on or after Apply by.");
        }
        return f;
    }

    private static LocalDate date(GigForm f, String key, String label, LocalDate today) {
        String v = f.typed.get(key);
        if (v.isEmpty()) return null;
        try {
            LocalDate d = LocalDate.parse(v);
            if (d.isBefore(today)) {
                f.errors.put(key, label + " can’t be in the past.");
                return null;
            }
            return d;
        } catch (DateTimeParseException e) {
            f.errors.put(key, "Pick a date for " + label + ".");
            return null;
        }
    }

    public boolean ok() {
        return errors.isEmpty();
    }

    /** "One thing to fix", "Two things to fix", … */
    public static String summaryTitle(int n) {
        String[] words = {"", "One thing", "Two things", "Three things", "Four things", "Five things", "Six things", "Seven things", "Eight things"};
        return (n < words.length ? words[n] : n + " things") + " to fix";
    }
}
