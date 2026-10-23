package com.gigmarket.gigs;

import com.gigmarket.model.Gig;
import com.gigmarket.util.DatabaseUtil;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/** Reading gigs for the feed and the detail page, with the poster's name. */
public final class GigStore {
    private static final String SELECT = "SELECT g.*, s.name AS poster_name FROM Gigs g JOIN Students s ON s.student_id = g.poster_id";

    private GigStore() {}

    /** Open gigs, newest first, optionally limited to some categories and a minimum pay. */
    public static List<Gig> open(List<String> categories, BigDecimal minPay) throws SQLException {
        StringBuilder sql = new StringBuilder(SELECT).append(" WHERE g.status = 'Open'");
        if (categories != null && !categories.isEmpty()) {
            sql.append(" AND g.category IN (");
            for (int i = 0; i < categories.size(); i++) sql.append(i == 0 ? "?" : ", ?");
            sql.append(")");
        }
        if (minPay != null) sql.append(" AND g.budget >= ?");
        sql.append(" ORDER BY g.created_at DESC, g.gig_id DESC");
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql.toString())) {
            int i = 1;
            if (categories != null) for (String cat : categories) s.setString(i++, cat);
            if (minPay != null) s.setBigDecimal(i, minPay);
            List<Gig> list = new ArrayList<>();
            try (ResultSet rs = s.executeQuery()) {
                while (rs.next()) list.add(gig(rs));
            }
            return list;
        }
    }

    /** Any gig by id (open or closed). */
    public static Optional<Gig> byId(int id) throws SQLException {
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(SELECT + " WHERE g.gig_id = ?")) {
            s.setInt(1, id);
            try (ResultSet rs = s.executeQuery()) {
                return rs.next() ? Optional.of(gig(rs)) : Optional.empty();
            }
        }
    }

    /** A student's application: its status (Pending, Hired, Rejected) and when it was sent. */
    public static final class Applied {
        public final String status;
        public final java.sql.Timestamp at;

        Applied(String status, java.sql.Timestamp at) {
            this.status = status;
            this.at = at;
        }
    }

    /** This student's application on this gig, or empty. */
    public static Optional<Applied> application(int gigId, int studentId) throws SQLException {
        try (Connection c = DatabaseUtil.getConnection();
             PreparedStatement s = c.prepareStatement("SELECT status, applied_at FROM Applications WHERE gig_id = ? AND applicant_id = ? ORDER BY applied_at DESC LIMIT 1")) {
            s.setInt(1, gigId);
            s.setInt(2, studentId);
            try (ResultSet rs = s.executeQuery()) {
                return rs.next() ? Optional.of(new Applied(rs.getString("status"), rs.getTimestamp("applied_at"))) : Optional.empty();
            }
        }
    }

    public static int applicationCount(int gigId) throws SQLException {
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement("SELECT COUNT(*) FROM Applications WHERE gig_id = ?")) {
            s.setInt(1, gigId);
            try (ResultSet rs = s.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    private static Gig gig(ResultSet rs) throws SQLException {
        Gig g = new Gig();
        g.setGigId(rs.getInt("gig_id"));
        g.setPosterId(rs.getInt("poster_id"));
        g.setTitle(rs.getString("title"));
        g.setDescription(rs.getString("description"));
        g.setBudget(rs.getBigDecimal("budget"));
        g.setDeadline(rs.getDate("deadline"));
        g.setCompletionDeadline(rs.getDate("completion_deadline"));
        g.setCategory(rs.getString("category"));
        g.setStatus(rs.getString("status"));
        g.setCreatedAt(rs.getTimestamp("created_at"));
        g.setWhenText(rs.getString("when_text"));
        g.setWhereText(rs.getString("where_text"));
        g.setPosterName(rs.getString("poster_name"));
        return g;
    }
}
