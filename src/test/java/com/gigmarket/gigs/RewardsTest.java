package com.gigmarket.gigs;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.Test;

class RewardsTest {
    private static Rewards.Done done(int day, int pay) {
        return new Rewards.Done(LocalDate.of(2026, 10, day), BigDecimal.valueOf(pay));
    }

    @Test
    void pointsAre100PerGigAnd10PerThousandRoundedDown() {
        assertEquals(0, Rewards.points(0, BigDecimal.ZERO));
        assertEquals(107, Rewards.points(1, BigDecimal.valueOf(700)));
        assertEquals(115, Rewards.points(1, BigDecimal.valueOf(1599)));
        assertEquals(240, Rewards.points(2, new BigDecimal("4000.99")));
        assertEquals(0, Rewards.points(0, null));
        assertEquals(223, Rewards.points(Arrays.asList(done(1, 800), done(2, 1500))));
    }

    @Test
    void tiersAndTheGapToTheNext() {
        Rewards.Tier b = Rewards.tier(115);
        assertEquals("Bronze", b.name);
        assertEquals("Silver", b.next);
        assertEquals(385, b.toNext());
        assertEquals("Silver", Rewards.tier(500).name);
        assertEquals("Silver", Rewards.tier(1999).name);
        Rewards.Tier g = Rewards.tier(2000);
        assertEquals("Gold", g.name);
        assertNull(g.nextAt);
        assertEquals(0, g.toNext());
    }

    @Test
    void achievementsCarryTheRealDay() {
        List<Rewards.Achievement> none = Rewards.achievements(Collections.emptyList());
        assertFalse(none.get(0).earned());
        assertEquals("Finish your first gig.", none.get(0).note());
        assertEquals("₹0 of ₹1,000 so far.", none.get(1).note());
        assertEquals("0 of 10 so far.", none.get(2).note());

        List<Rewards.Achievement> some = Rewards.achievements(Arrays.asList(done(18, 800), done(21, 300)));
        assertEquals("Earned 18 Oct.", some.get(0).note());
        assertTrue(some.get(1).earned());
        assertEquals("Earned 21 Oct.", some.get(1).note(), "₹1,000 is reached on the second gig");
        assertEquals("2 of 10 so far.", some.get(2).note());

        List<Rewards.Done> ten = new ArrayList<>();
        for (int d = 1; d <= 12; d++) ten.add(done(d, 100));
        assertEquals("Earned 10 Oct.", Rewards.achievements(ten).get(2).note());
    }

    @Test
    void standingIsTheStudentsOwnPlaceOnly() {
        assertArrayEquals(new int[] {1, 4}, Rewards.standing(300, Arrays.asList(300, 100, 0, 0)));
        assertArrayEquals(new int[] {2, 4}, Rewards.standing(100, Arrays.asList(300, 100, 100, 0)), "ties share a place");
        assertNull(Rewards.standing(0, Arrays.asList(300, 0)), "no points this month, no rank");
    }
}
