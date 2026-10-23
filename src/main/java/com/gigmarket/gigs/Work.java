package com.gigmarket.gigs;

import com.gigmarket.util.DatabaseUtil;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Who is doing what: dashboards, applicants, and the actions that move a gig along
 * (hire → In progress, mark done → Done; reject a pending applicant). Every number here is counted from the database.
 * Servlets check the role and ownership first; the SQL also carries the owner or state in its WHERE, so a stale
 * form cannot move a gig backwards.
 */
public final class Work {
    private Work() {}

    // ---------- student

    public static final class StudentSummary {
        public int applied;
        public int hired;
        public int done;
        public BigDecimal earned = BigDecimal.ZERO;
    }

    public static StudentSummary studentSummary(int studentId) throws SQLException {
        String sql = "SELECT COUNT(*) applied, COALESCE(SUM(a.status = 'Hired'), 0) hired,"
                + " COALESCE(SUM(a.status = 'Hired' AND g.status = 'Done'), 0) done,"
                + " COALESCE(SUM(CASE WHEN a.status = 'Hired' AND g.status = 'Done' THEN g.budget END), 0) earned"
                + " FROM Applications a JOIN Gigs g ON g.gig_id = a.gig_id WHERE a.applicant_id = ?";
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, studentId);
            try (ResultSet rs = s.executeQuery()) {
                StudentSummary out = new StudentSummary();
                if (rs.next()) {
                    out.applied = rs.getInt("applied");
                    out.hired = rs.getInt("hired");
                    out.done = rs.getInt("done");
                    out.earned = rs.getBigDecimal("earned");
                }
                return out;
            }
        }
    }

    /** One of the student's applications with its gig. */
    public static final class StudentRow {
        public int applicationId;
        public String applicationStatus;
        public Timestamp appliedAt;
        public int gigId;
        public String title;
        public BigDecimal pay;
        public String whenText;
        public Date applyBy;
        public Date doneBy;
        public String gigStatus;
        public Timestamp doneAt;
    }

    public static List<StudentRow> studentRows(int studentId) throws SQLException {
        String sql = "SELECT a.application_id, a.status app_status, a.applied_at, g.gig_id, g.title, g.budget, g.when_text,"
                + " g.deadline, g.completion_deadline, g.status gig_status, g.done_at"
                + " FROM Applications a JOIN Gigs g ON g.gig_id = a.gig_id WHERE a.applicant_id = ?"
                + " ORDER BY a.applied_at DESC, a.application_id DESC";
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, studentId);
            List<StudentRow> out = new ArrayList<>();
            try (ResultSet rs = s.executeQuery()) {
                while (rs.next()) {
                    StudentRow r = new StudentRow();
                    r.applicationId = rs.getInt("application_id");
                    r.applicationStatus = rs.getString("app_status");
                    r.appliedAt = rs.getTimestamp("applied_at");
                    r.gigId = rs.getInt("gig_id");
                    r.title = rs.getString("title");
                    r.pay = rs.getBigDecimal("budget");
                    r.whenText = rs.getString("when_text");
                    r.applyBy = rs.getDate("deadline");
                    r.doneBy = rs.getDate("completion_deadline");
                    r.gigStatus = rs.getString("gig_status");
                    r.doneAt = rs.getTimestamp("done_at");
                    out.add(r);
                }
            }
            return out;
        }
    }

    /** The student's finished gigs, oldest first (for points and achievements). */
    public static List<Rewards.Done> finished(int studentId) throws SQLException {
        String sql = "SELECT g.done_at, g.budget FROM Applications a JOIN Gigs g ON g.gig_id = a.gig_id"
                + " WHERE a.applicant_id = ? AND a.status = 'Hired' AND g.status = 'Done' ORDER BY g.done_at, g.gig_id";
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, studentId);
            List<Rewards.Done> out = new ArrayList<>();
            try (ResultSet rs = s.executeQuery()) {
                while (rs.next()) {
                    Timestamp t = rs.getTimestamp("done_at");
                    out.add(new Rewards.Done(t == null ? null : t.toLocalDateTime().toLocalDate(), rs.getBigDecimal("budget")));
                }
            }
            return out;
        }
    }

    /** Points this month for every active student, from gigs marked done this month. */
    public static Map<Integer, Integer> monthPoints(LocalDate today) throws SQLException {
        LocalDate from = today.withDayOfMonth(1);
        String sql = "SELECT s.student_id, COUNT(g.gig_id) done, COALESCE(SUM(g.budget), 0) earned FROM Students s"
                + " LEFT JOIN Applications a ON a.applicant_id = s.student_id AND a.status = 'Hired'"
                + " LEFT JOIN Gigs g ON g.gig_id = a.gig_id AND g.status = 'Done' AND g.done_at >= ? AND g.done_at < ?"
                + " WHERE s.role = 'student' AND s.status = 'active' GROUP BY s.student_id";
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setTimestamp(1, Timestamp.valueOf(from.atStartOfDay()));
            s.setTimestamp(2, Timestamp.valueOf(from.plusMonths(1).atStartOfDay()));
            Map<Integer, Integer> out = new HashMap<>();
            try (ResultSet rs = s.executeQuery()) {
                while (rs.next()) out.put(rs.getInt("student_id"), Rewards.points(rs.getInt("done"), rs.getBigDecimal("earned")));
            }
            return out;
        }
    }

    public static final class Person {
        public String name;
        public String email;
        public String university;
    }

    public static Person person(int id) throws SQLException {
        String sql = "SELECT s.name, s.email, u.name uni FROM Students s LEFT JOIN Universities u ON u.university_id = s.university_id WHERE s.student_id = ?";
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, id);
            try (ResultSet rs = s.executeQuery()) {
                Person p = new Person();
                if (rs.next()) {
                    p.name = rs.getString("name");
                    p.email = rs.getString("email");
                    p.university = rs.getString("uni");
                }
                return p;
            }
        }
    }

    // ---------- faculty

    public static final class FacultySummary {
        public int open;
        public int waiting;
        public int inProgress;
        public int done;
    }

    public static FacultySummary facultySummary(int posterId) throws SQLException {
        FacultySummary out = new FacultySummary();
        try (Connection c = DatabaseUtil.getConnection()) {
            try (PreparedStatement s = c.prepareStatement("SELECT COALESCE(SUM(status = 'Open'), 0), COALESCE(SUM(status = 'In progress'), 0),"
                    + " COALESCE(SUM(status = 'Done'), 0) FROM Gigs WHERE poster_id = ?")) {
                s.setInt(1, posterId);
                try (ResultSet rs = s.executeQuery()) {
                    if (rs.next()) {
                        out.open = rs.getInt(1);
                        out.inProgress = rs.getInt(2);
                        out.done = rs.getInt(3);
                    }
                }
            }
            try (PreparedStatement s = c.prepareStatement("SELECT COUNT(*) FROM Applications a JOIN Gigs g ON g.gig_id = a.gig_id"
                    + " WHERE g.poster_id = ? AND g.status = 'Open' AND a.status = 'Pending'")) {
                s.setInt(1, posterId);
                try (ResultSet rs = s.executeQuery()) {
                    if (rs.next()) out.waiting = rs.getInt(1);
                }
            }
        }
        return out;
    }

    /** One of the faculty member's gigs. */
    public static final class FacultyRow {
        public int gigId;
        public String title;
        public BigDecimal pay;
        public Date applyBy;
        public Date doneBy;
        public String status;
        public Timestamp createdAt;
        public Timestamp doneAt;
        public int applicants;
        public int pending;
        public String hiredName;
    }

    public static List<FacultyRow> facultyRows(int posterId) throws SQLException {
        String sql = "SELECT g.gig_id, g.title, g.budget, g.deadline, g.completion_deadline, g.status, g.created_at, g.done_at,"
                + " (SELECT COUNT(*) FROM Applications a WHERE a.gig_id = g.gig_id) applicants,"
                + " (SELECT COUNT(*) FROM Applications a WHERE a.gig_id = g.gig_id AND a.status = 'Pending') pending,"
                + " (SELECT s.name FROM Applications a JOIN Students s ON s.student_id = a.applicant_id"
                + "    WHERE a.gig_id = g.gig_id AND a.status = 'Hired' LIMIT 1) hired_name"
                + " FROM Gigs g WHERE g.poster_id = ? ORDER BY g.created_at DESC, g.gig_id DESC";
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, posterId);
            List<FacultyRow> out = new ArrayList<>();
            try (ResultSet rs = s.executeQuery()) {
                while (rs.next()) {
                    FacultyRow r = new FacultyRow();
                    r.gigId = rs.getInt("gig_id");
                    r.title = rs.getString("title");
                    r.pay = rs.getBigDecimal("budget");
                    r.applyBy = rs.getDate("deadline");
                    r.doneBy = rs.getDate("completion_deadline");
                    r.status = rs.getString("status");
                    r.createdAt = rs.getTimestamp("created_at");
                    r.doneAt = rs.getTimestamp("done_at");
                    r.applicants = rs.getInt("applicants");
                    r.pending = rs.getInt("pending");
                    r.hiredName = rs.getString("hired_name");
                    out.add(r);
                }
            }
            return out;
        }
    }

    /** One applicant on a gig, as the gig's owner sees them. */
    public static final class Applicant {
        public int applicationId;
        public String name;
        public String email;
        public String pitch;
        public String status;
        public Timestamp appliedAt;
        public boolean hasPortfolio;
        public String portfolioType;
    }

    public static List<Applicant> applicants(int gigId) throws SQLException {
        String sql = "SELECT a.application_id, a.pitch_text, a.status, a.applied_at, a.portfolio_path, s.name, s.email"
                + " FROM Applications a JOIN Students s ON s.student_id = a.applicant_id WHERE a.gig_id = ?"
                + " ORDER BY FIELD(a.status, 'Hired', 'Pending', 'Rejected'), a.applied_at, a.application_id";
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, gigId);
            List<Applicant> out = new ArrayList<>();
            try (ResultSet rs = s.executeQuery()) {
                while (rs.next()) {
                    Applicant a = new Applicant();
                    a.applicationId = rs.getInt("application_id");
                    a.name = rs.getString("name");
                    a.email = rs.getString("email");
                    a.pitch = rs.getString("pitch_text");
                    a.status = rs.getString("status");
                    a.appliedAt = rs.getTimestamp("applied_at");
                    String p = rs.getString("portfolio_path");
                    a.hasPortfolio = p != null && !p.isEmpty();
                    a.portfolioType = a.hasPortfolio ? Uploads.extension(p) : null;
                    out.add(a);
                }
            }
            return out;
        }
    }

    // ---------- actions

    /** Hire one pending applicant on an open gig: they become Hired, every other pending applicant Not picked, the gig In progress. */
    public static boolean hire(int gigId, int applicationId) throws SQLException {
        try (Connection c = DatabaseUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                try (PreparedStatement s = c.prepareStatement("SELECT status FROM Gigs WHERE gig_id = ? FOR UPDATE")) {
                    s.setInt(1, gigId);
                    try (ResultSet rs = s.executeQuery()) {
                        if (!rs.next() || !"Open".equals(rs.getString(1))) {
                            c.rollback();
                            return false;
                        }
                    }
                }
                int hired;
                try (PreparedStatement s = c.prepareStatement("UPDATE Applications SET status = 'Hired' WHERE application_id = ? AND gig_id = ? AND status = 'Pending'")) {
                    s.setInt(1, applicationId);
                    s.setInt(2, gigId);
                    hired = s.executeUpdate();
                }
                if (hired != 1) {
                    c.rollback();
                    return false;
                }
                try (PreparedStatement s = c.prepareStatement("UPDATE Applications SET status = 'Rejected' WHERE gig_id = ? AND application_id <> ? AND status = 'Pending'")) {
                    s.setInt(1, gigId);
                    s.setInt(2, applicationId);
                    s.executeUpdate();
                }
                try (PreparedStatement s = c.prepareStatement("UPDATE Gigs SET status = 'In progress' WHERE gig_id = ?")) {
                    s.setInt(1, gigId);
                    s.executeUpdate();
                }
                c.commit();
                return true;
            } catch (SQLException e) {
                c.rollback();
                throw e;
            }
        }
    }

    /** "Not this time": only a pending applicant on this gig. */
    public static boolean reject(int gigId, int applicationId) throws SQLException {
        try (Connection c = DatabaseUtil.getConnection();
             PreparedStatement s = c.prepareStatement("UPDATE Applications SET status = 'Rejected' WHERE application_id = ? AND gig_id = ? AND status = 'Pending'")) {
            s.setInt(1, applicationId);
            s.setInt(2, gigId);
            return s.executeUpdate() == 1;
        }
    }

    /** The owner marks an in-progress gig done. */
    public static boolean markDone(int gigId, int posterId) throws SQLException {
        try (Connection c = DatabaseUtil.getConnection();
             PreparedStatement s = c.prepareStatement("UPDATE Gigs SET status = 'Done', done_at = CURRENT_TIMESTAMP WHERE gig_id = ? AND poster_id = ? AND status = 'In progress'")) {
            s.setInt(1, gigId);
            s.setInt(2, posterId);
            return s.executeUpdate() == 1;
        }
    }

    /** Where an application's portfolio is stored, and who may open it. */
    public static final class Portfolio {
        public String path;
        public int applicantId;
        public int posterId;
    }

    public static Portfolio portfolio(int applicationId) throws SQLException {
        String sql = "SELECT a.portfolio_path, a.applicant_id, g.poster_id FROM Applications a JOIN Gigs g ON g.gig_id = a.gig_id WHERE a.application_id = ?";
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, applicationId);
            try (ResultSet rs = s.executeQuery()) {
                if (!rs.next()) return null;
                Portfolio p = new Portfolio();
                p.path = rs.getString("portfolio_path");
                p.applicantId = rs.getInt("applicant_id");
                p.posterId = rs.getInt("poster_id");
                return p;
            }
        }
    }
}
