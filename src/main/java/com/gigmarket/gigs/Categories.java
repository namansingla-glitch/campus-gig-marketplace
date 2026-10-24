package com.gigmarket.gigs;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * The five gig categories (decisions §20t, option b) and the kit category colour each one uses:
 * Tutoring 1, Design 2, Event Support 3, Development 4 (the kit's "Coding" colour), Writing 0 (neutral).
 */
public final class Categories {
    public static final List<String> ALL = Collections.unmodifiableList(
            Arrays.asList("Tutoring", "Design", "Development", "Writing", "Event Support"));

    private Categories() {}

    /** The kit's data-cat value for a category: "1" to "4", or "0" for neutral (also for unknown or empty). */
    public static String colour(String category) {
        if (category == null) return "0";
        switch (category) {
            case "Tutoring": return "1";
            case "Design": return "2";
            case "Event Support": return "3";
            case "Development": return "4";
            default: return "0";
        }
    }

    public static boolean known(String category) {
        return category != null && ALL.contains(category);
    }
}
