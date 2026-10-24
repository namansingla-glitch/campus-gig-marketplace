package com.gigmarket.gigs;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Locale;

/**
 * Rewards from real work only (decisions §20u): points, tier, achievements and the student's own standing.
 * Points: 100 per finished gig + 10 per ₹1,000 earned (rounded down). A gig counts once the faculty member marks it done.
 */
public final class Rewards {
    public static final int PER_GIG = 100;
    public static final int PER_THOUSAND = 10;
    public static final String RULE = "100 per finished gig, 10 per ₹1,000 earned";
    private static final DateTimeFormatter EARNED = DateTimeFormatter.ofPattern("d MMM", Locale.ENGLISH);

    private Rewards() {}

    /** One finished gig: the day it was marked done and what it paid. */
    public static final class Done {
        public final LocalDate at;
        public final BigDecimal pay;

        public Done(LocalDate at, BigDecimal pay) {
            this.at = at;
            this.pay = pay == null ? BigDecimal.ZERO : pay;
        }
    }

    public static int points(int done, BigDecimal earned) {
        BigDecimal e = earned == null ? BigDecimal.ZERO : earned.max(BigDecimal.ZERO);
        // earned / 1000 * 10, rounded down, is earned / 100 rounded down.
        return done * PER_GIG + e.divideToIntegralValue(BigDecimal.valueOf(100)).intValue();
    }

    public static int points(List<Done> done) {
        BigDecimal sum = BigDecimal.ZERO;
        for (Done d : done) sum = sum.add(d.pay);
        return points(done.size(), sum);
    }

    /** Bronze below 500, Silver 500 to 1,999, Gold from 2,000. */
    public static final class Tier {
        public final String name;
        public final int points;
        /** Next tier and the points it starts at; null at Gold. */
        public final String next;
        public final Integer nextAt;

        Tier(String name, int points, String next, Integer nextAt) {
            this.name = name;
            this.points = points;
            this.next = next;
            this.nextAt = nextAt;
        }

        public int toNext() {
            return nextAt == null ? 0 : nextAt - points;
        }
    }

    public static Tier tier(int points) {
        if (points >= 2000) return new Tier("Gold", points, null, null);
        if (points >= 500) return new Tier("Silver", points, "Gold", 2000);
        return new Tier("Bronze", points, "Silver", 500);
    }

    /** An achievement, with the day it was earned or how far along it is. */
    public static final class Achievement {
        public final String mark;
        public final String title;
        public final LocalDate earnedOn;
        public final String progress;

        Achievement(String mark, String title, LocalDate earnedOn, String progress) {
            this.mark = mark;
            this.title = title;
            this.earnedOn = earnedOn;
            this.progress = progress;
        }

        public boolean earned() {
            return earnedOn != null;
        }

        public String note() {
            return earned() ? "Earned " + earnedOn.format(EARNED) + "." : progress;
        }
    }

    /** First gig done, ₹1,000 earned, ten gigs done. Finished gigs must be oldest first. */
    public static List<Achievement> achievements(List<Done> doneOldestFirst) {
        List<Achievement> out = new ArrayList<>();
        int n = doneOldestFirst.size();
        out.add(new Achievement("1", "First gig done", n >= 1 ? doneOldestFirst.get(0).at : null, "Finish your first gig."));
        BigDecimal sum = BigDecimal.ZERO;
        LocalDate thousandOn = null;
        BigDecimal thousand = BigDecimal.valueOf(1000);
        for (Done d : doneOldestFirst) {
            sum = sum.add(d.pay);
            if (thousandOn == null && sum.compareTo(thousand) >= 0) thousandOn = d.at;
        }
        out.add(new Achievement("₹", "₹1,000 earned", thousandOn, Pay.format(sum.min(thousand)) + " of ₹1,000 so far."));
        out.add(new Achievement("10", "Ten gigs done", n >= 10 ? doneOldestFirst.get(9).at : null, Math.min(n, 10) + " of 10 so far."));
        return out;
    }

    /** The student's own place this month: {rank, of}. Null when they have no points this month (no rank to show). */
    public static int[] standing(int mine, Collection<Integer> everyone) {
        if (mine <= 0) return null;
        int above = 0;
        for (int p : everyone) if (p > mine) above++;
        return new int[] {above + 1, everyone.size()};
    }
}
