package com.gigmarket.auth;

import java.time.LocalDateTime;

/** A person who can log in. Stored in the Students table, which holds every account. */
public final class Account {
    public enum Role { STUDENT, FACULTY, ADMIN }
    public enum Status { ACTIVE, PENDING, REJECTED }

    private final int id;
    private final String name;
    private final String email;
    private final String passwordHash;
    private final Role role;
    private final Status status;
    private final Integer universityId;
    private final LocalDateTime createdAt;

    public Account(int id, String name, String email, String passwordHash, Role role, Status status,
                   Integer universityId, LocalDateTime createdAt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.status = status;
        this.universityId = universityId;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getPasswordHash() { return passwordHash; }
    public Role getRole() { return role; }
    public Status getStatus() { return status; }
    public Integer getUniversityId() { return universityId; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    /**
     * The value the JSP pages already check in the session: "student", "poster" (faculty) or "admin".
     * Kept as "poster" for faculty so the existing pages keep working unchanged.
     */
    public String sessionRole() {
        switch (role) {
            case FACULTY: return "poster";
            case ADMIN: return "admin";
            default: return "student";
        }
    }
}
