package com.gigmarket.gigs;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;

class GigHelpersTest {
    @Test
    void categoriesMapToKitColoursWithWritingNeutral() {
        assertEquals("1", Categories.colour("Tutoring"));
        assertEquals("2", Categories.colour("Design"));
        assertEquals("3", Categories.colour("Event Support"));
        assertEquals("4", Categories.colour("Development"));
        assertEquals("0", Categories.colour("Writing"));
        assertEquals("0", Categories.colour(null));
        assertEquals("0", Categories.colour("Something new"));
        assertTrue(Categories.known("Writing"));
        assertFalse(Categories.known("writing"), "categories match exactly");
        assertFalse(Categories.known("' OR 1=1 --"));
    }

    @Test
    void payIsShownTheIndianWay() {
        assertEquals("₹350", Pay.format(new BigDecimal("350")));
        assertEquals("₹1,500", Pay.format(new BigDecimal("1500.00")));
        assertEquals("₹1,24,500", Pay.format(new BigDecimal("124500")));
        assertEquals("₹12,34,567", Pay.format(new BigDecimal("1234567")));
        assertEquals("₹1,00,00,000", Pay.format(new BigDecimal("10000000")));
        assertEquals("₹99.50", Pay.format(new BigDecimal("99.5")));
        assertEquals("", Pay.format(null));
    }

    @Test
    void typedPayIsReadOrRefusedWithAFix() {
        assertNull(Pay.parse(null));
        assertNull(Pay.parse("   "));
        assertEquals(new BigDecimal("500"), Pay.parse("500"));
        assertEquals(new BigDecimal("1500"), Pay.parse(" ₹1,500 "));
        for (String bad : new String[] {"500 rs", "-5", "12.5", "abc", "1e3"}) {
            IllegalArgumentException e = assertThrows(IllegalArgumentException.class, () -> Pay.parse(bad), bad);
            assertEquals(Pay.FILTER_HELP, e.getMessage());
        }
        assertThrows(IllegalArgumentException.class, () -> Pay.parse("99999999"));
    }

    @Test
    void uploadsKeepOnlyASafeRandomNameWithAnAllowedExtension() {
        String n = Uploads.storedName("../../etc/My CV.PDF");
        assertTrue(n.matches("[0-9a-f-]{36}\\.pdf"), n);
        assertTrue(Uploads.storedName("C:\\\\Users\\\\x\\\\photo.jpeg").endsWith(".jpeg"));
        assertNull(Uploads.storedName("shell.jsp"));
        assertNull(Uploads.storedName("archive.pdf.exe"));
        assertNull(Uploads.storedName("noextension"));
        assertNull(Uploads.storedName("dot."));
        assertNull(Uploads.storedName(null));
    }

    @Test
    void datesReadLikeAPerson() {
        LocalDate today = LocalDate.of(2026, 10, 23);
        assertEquals("Today", Dates.day(Date.valueOf(today), today));
        assertEquals("Tomorrow", Dates.day(Date.valueOf(today.plusDays(1)), today));
        assertEquals("Sat 31 Oct", Dates.day(Date.valueOf(LocalDate.of(2026, 10, 31)), today));
        assertNull(Dates.day(null, today));
        assertTrue(Dates.dueToday(Date.valueOf(today), today));
        assertFalse(Dates.dueToday(Date.valueOf(today.plusDays(1)), today));
        assertEquals("21 Oct", Dates.posted(Timestamp.valueOf(LocalDateTime.of(2026, 10, 21, 9, 30))));
    }
}
