package com.gigmarket.gigs;

/**
 * What a status badge says, and which kit status colour it uses (open, progress, done, hired, pending, declined).
 * Gig: Open → In progress (someone hired) → Done (the faculty member marked it done). Nothing here says "paid":
 * the site does not handle payment.
 */
public final class Statuses {
    private Statuses() {}

    /** {kit status, label}. */
    public static String[] gig(String gigStatus) {
        if ("In progress".equals(gigStatus)) return new String[] {"progress", "In progress"};
        if ("Done".equals(gigStatus)) return new String[] {"done", "Done"};
        return new String[] {"open", "Open"};
    }

    /** What the student sees for their own application. */
    public static String[] student(String applicationStatus, String gigStatus) {
        if ("Hired".equals(applicationStatus)) {
            return "Done".equals(gigStatus) ? new String[] {"done", "Done"} : new String[] {"progress", "Hired · in progress"};
        }
        if ("Rejected".equals(applicationStatus)) return new String[] {"declined", "Not picked"};
        return "Open".equals(gigStatus) ? new String[] {"pending", "Pending"} : new String[] {"declined", "Closed"};
    }

    /** What the faculty member sees for one applicant. */
    public static String[] applicant(String applicationStatus) {
        if ("Hired".equals(applicationStatus)) return new String[] {"hired", "Hired"};
        if ("Rejected".equals(applicationStatus)) return new String[] {"declined", "Not picked"};
        return new String[] {"pending", "Pending"};
    }

    /** The application is still in play (shown under "Your gigs now"). */
    public static boolean active(String applicationStatus, String gigStatus) {
        return ("Hired".equals(applicationStatus) && "In progress".equals(gigStatus))
                || ("Pending".equals(applicationStatus) && "Open".equals(gigStatus));
    }

    /** The kit badge markup. Labels are fixed strings from this class, never user text. */
    public static String badge(String[] s) {
        return "<span class=\"k-status\" data-status=\"" + s[0] + "\">" + s[1] + "</span>";
    }
}
