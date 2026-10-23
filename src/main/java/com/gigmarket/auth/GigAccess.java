package com.gigmarket.auth;

import com.gigmarket.util.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/** Ownership checks: faculty act only on their own gigs; students rate only gigs they were hired for. */
public final class GigAccess {
    private GigAccess() {}

    public static boolean postedBy(int gigId, int facultyId) throws SQLException {
        return exists("SELECT 1 FROM Gigs WHERE gig_id = ? AND poster_id = ?", gigId, facultyId);
    }

    public static boolean applicationOnGig(int applicationId, int gigId) throws SQLException {
        return exists("SELECT 1 FROM Applications WHERE application_id = ? AND gig_id = ?", applicationId, gigId);
    }

    public static boolean hiredOn(int gigId, int studentId) throws SQLException {
        return exists("SELECT 1 FROM Applications WHERE gig_id = ? AND applicant_id = ? AND status = 'Hired'", gigId, studentId);
    }

    private static boolean exists(String sql, int a, int b) throws SQLException {
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, a);
            s.setInt(2, b);
            try (ResultSet rs = s.executeQuery()) {
                return rs.next();
            }
        }
    }
}
