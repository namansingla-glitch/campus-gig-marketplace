package com.gigmarket.gigs;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;
import org.junit.jupiter.api.Test;

class StatusAndFormTest {
    @Test
    void studentSeesWhereTheirApplicationStands() {
        assertArrayEquals(new String[] {"pending", "Pending"}, Statuses.student("Pending", "Open"));
        assertArrayEquals(new String[] {"progress", "Hired · in progress"}, Statuses.student("Hired", "In progress"));
        assertArrayEquals(new String[] {"done", "Done"}, Statuses.student("Hired", "Done"));
        assertArrayEquals(new String[] {"declined", "Not picked"}, Statuses.student("Rejected", "In progress"));
        assertArrayEquals(new String[] {"declined", "Closed"}, Statuses.student("Pending", "Done"));
        for (String g : new String[] {"Open", "In progress", "Done"}) {
            for (String a : new String[] {"Pending", "Hired", "Rejected"}) {
                assertFalse(Statuses.student(a, g)[1].toLowerCase().contains("paid"), "the site does not handle payment");
            }
        }
    }

    @Test
    void gigAndApplicantBadges() {
        assertArrayEquals(new String[] {"open", "Open"}, Statuses.gig("Open"));
        assertArrayEquals(new String[] {"progress", "In progress"}, Statuses.gig("In progress"));
        assertArrayEquals(new String[] {"done", "Done"}, Statuses.gig("Done"));
        assertArrayEquals(new String[] {"hired", "Hired"}, Statuses.applicant("Hired"));
        assertEquals("<span class=\"k-status\" data-status=\"open\">Open</span>", Statuses.badge(Statuses.gig("Open")));
        assertTrue(Statuses.active("Pending", "Open"));
        assertTrue(Statuses.active("Hired", "In progress"));
        assertFalse(Statuses.active("Hired", "Done"));
        assertFalse(Statuses.active("Rejected", "Open"));
    }

    private static final LocalDate TODAY = LocalDate.of(2026, 10, 24);

    private static GigForm form(String... kv) {
        Map<String, String> m = new HashMap<>();
        m.put("title", "Help at the open day");
        m.put("category", "Event Support");
        m.put("description", "Guide visitors.");
        m.put("pay", "700");
        m.put("when", "Sun, 10 am–2 pm");
        m.put("where", "Main gate");
        for (int i = 0; i < kv.length; i += 2) m.put(kv[i], kv[i + 1]);
        return GigForm.read(m::get, TODAY);
    }

    @Test
    void aGoodFormHasNoProblems() {
        GigForm f = form("pay", "₹1,500", "applyBy", "2026-10-30", "doneBy", "2026-11-02");
        assertTrue(f.ok(), f.errors.toString());
        assertEquals(1500, f.pay.intValue());
        assertEquals(LocalDate.of(2026, 10, 30), f.applyBy);
    }

    @Test
    void problemsAreListedInFormOrderWithAFixForEach() {
        GigForm f = form("title", " ", "pay", "", "where", "", "category", "Hacking");
        assertArrayEquals(new String[] {"title", "category", "pay", "where"}, f.errors.keySet().toArray(new String[0]));
        assertEquals("Add the pay in rupees, for example 500.", f.errors.get("pay"));
        assertEquals("Four things to fix", GigForm.summaryTitle(f.errors.size()));
        assertEquals("One thing to fix", GigForm.summaryTitle(1));
        assertEquals("", f.typed.get("title"), "what was typed comes back trimmed");
    }

    @Test
    void payAndDatesAreChecked() {
        assertEquals("Pay must be more than ₹0.", form("pay", "0").errors.get("pay"));
        assertEquals(Pay.FILTER_HELP, form("pay", "500 rs").errors.get("pay"));
        assertEquals("Apply by can’t be in the past.", form("applyBy", "2026-10-01").errors.get("applyBy"));
        assertEquals("Pick a date for Done by.", form("doneBy", "next week").errors.get("doneBy"));
        assertEquals("Done by must be on or after Apply by.", form("applyBy", "2026-11-05", "doneBy", "2026-11-01").errors.get("doneBy"));
        assertTrue(form("when", new String(new char[121]).replace('\0', 'x')).errors.containsKey("when"));
    }
}
