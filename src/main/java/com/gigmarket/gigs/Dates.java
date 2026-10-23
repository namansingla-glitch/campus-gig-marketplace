package com.gigmarket.gigs;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/** Short, human dates for cards and details: "Fri 31 Oct"; "Today" / "Tomorrow" when close. */
public final class Dates {
    private static final DateTimeFormatter DAY = DateTimeFormatter.ofPattern("EEE d MMM", Locale.ENGLISH);
    private static final DateTimeFormatter POSTED = DateTimeFormatter.ofPattern("d MMM", Locale.ENGLISH);

    private Dates() {}

    public static String day(java.sql.Date d, LocalDate today) {
        if (d == null) return null;
        LocalDate x = d.toLocalDate();
        if (x.equals(today)) return "Today";
        if (x.equals(today.plusDays(1))) return "Tomorrow";
        return x.format(DAY);
    }

    public static String day(java.sql.Date d) {
        return day(d, LocalDate.now());
    }

    public static String posted(java.sql.Timestamp t) {
        return t == null ? null : t.toLocalDateTime().toLocalDate().format(POSTED);
    }

    /** True when the last day to apply is today: the card gets the "due tonight!" note. */
    public static boolean dueToday(java.sql.Date d, LocalDate today) {
        return d != null && d.toLocalDate().equals(today);
    }
}
