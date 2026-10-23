package com.gigmarket.auth;

import com.gigmarket.util.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

/** MySQL store (see src/main/resources/schema.sql). The Students table holds every account. */
public final class JdbcAccountStore implements AccountStore {
    private static final String ACCOUNT_COLUMNS = "student_id, name, email, password_hash, role, status, university_id, created_at";

    @Override
    public List<University> universities() {
        List<University> list = new ArrayList<>();
        try (Connection c = DatabaseUtil.getConnection();
             PreparedStatement s = c.prepareStatement("SELECT university_id, name, student_domain, faculty_domain FROM Universities ORDER BY name");
             ResultSet rs = s.executeQuery()) {
            while (rs.next()) list.add(university(rs));
            return list;
        } catch (SQLException e) {
            throw new IllegalStateException("Could not load universities", e);
        }
    }

    @Override
    public Optional<University> university(int id) {
        try (Connection c = DatabaseUtil.getConnection();
             PreparedStatement s = c.prepareStatement("SELECT university_id, name, student_domain, faculty_domain FROM Universities WHERE university_id = ?")) {
            s.setInt(1, id);
            try (ResultSet rs = s.executeQuery()) {
                return rs.next() ? Optional.of(university(rs)) : Optional.empty();
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Could not load university", e);
        }
    }

    @Override
    public Optional<Account> findByEmail(String email) {
        return one("SELECT " + ACCOUNT_COLUMNS + " FROM Students WHERE email = ?", email);
    }

    @Override
    public Optional<Account> findById(int id) {
        return one("SELECT " + ACCOUNT_COLUMNS + " FROM Students WHERE student_id = ?", id);
    }

    @Override
    public Account create(String name, String email, String passwordHash, Account.Role role, Account.Status status, int universityId) {
        String sql = "INSERT INTO Students (name, email, password_hash, role, status, university_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection c = DatabaseUtil.getConnection();
             PreparedStatement s = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            s.setString(1, name);
            s.setString(2, email);
            s.setString(3, passwordHash);
            s.setString(4, role.name().toLowerCase(Locale.ROOT));
            s.setString(5, status.name().toLowerCase(Locale.ROOT));
            s.setInt(6, universityId);
            s.executeUpdate();
            try (ResultSet keys = s.getGeneratedKeys()) {
                keys.next();
                return findById(keys.getInt(1)).orElseThrow(() -> new IllegalStateException("Account vanished after insert"));
            }
        } catch (SQLIntegrityConstraintViolationException e) {
            throw new DuplicateEmailException();
        } catch (SQLException e) {
            throw new IllegalStateException("Could not create account", e);
        }
    }

    @Override
    public List<Account> pendingFaculty() {
        List<Account> list = new ArrayList<>();
        String sql = "SELECT " + ACCOUNT_COLUMNS + " FROM Students WHERE role = 'faculty' AND status = 'pending' ORDER BY created_at, student_id";
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql); ResultSet rs = s.executeQuery()) {
            while (rs.next()) list.add(account(rs));
            return list;
        } catch (SQLException e) {
            throw new IllegalStateException("Could not load pending faculty", e);
        }
    }

    @Override
    public boolean decidePending(int accountId, Account.Status newStatus) {
        String sql = "UPDATE Students SET status = ? WHERE student_id = ? AND status = 'pending'";
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setString(1, newStatus.name().toLowerCase(Locale.ROOT));
            s.setInt(2, accountId);
            return s.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new IllegalStateException("Could not update account", e);
        }
    }

    private Optional<Account> one(String sql, Object key) {
        try (Connection c = DatabaseUtil.getConnection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setObject(1, key);
            try (ResultSet rs = s.executeQuery()) {
                return rs.next() ? Optional.of(account(rs)) : Optional.empty();
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Could not load account", e);
        }
    }

    private static University university(ResultSet rs) throws SQLException {
        return new University(rs.getInt("university_id"), rs.getString("name"), rs.getString("student_domain"), rs.getString("faculty_domain"));
    }

    private static Account account(ResultSet rs) throws SQLException {
        int uni = rs.getInt("university_id");
        Integer universityId = rs.wasNull() ? null : uni;
        Timestamp created = rs.getTimestamp("created_at");
        return new Account(rs.getInt("student_id"), rs.getString("name"), rs.getString("email"), rs.getString("password_hash"),
                Account.Role.valueOf(rs.getString("role").toUpperCase(Locale.ROOT)),
                Account.Status.valueOf(rs.getString("status").toUpperCase(Locale.ROOT)),
                universityId, created == null ? null : created.toLocalDateTime());
    }
}
