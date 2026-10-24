package com.gigmarket.auth;

import java.util.List;
import java.util.Optional;

/** Where accounts and universities live. JdbcAccountStore in the app; an in-memory one in tests. */
public interface AccountStore {
    List<University> universities();

    Optional<University> university(int id);

    /** Email is already normalised by the caller. */
    Optional<Account> findByEmail(String email);

    Optional<Account> findById(int id);

    /** Creates the account and returns it with its new id. Throws DuplicateEmailException if the email exists. */
    Account create(String name, String email, String passwordHash, Account.Role role, Account.Status status, int universityId);

    /** Pending faculty, oldest first. */
    List<Account> pendingFaculty();

    /** Changes a pending account's status; returns false if the account is missing or no longer pending. */
    boolean decidePending(int accountId, Account.Status newStatus);

    final class DuplicateEmailException extends RuntimeException {
        public DuplicateEmailException() {
            super("email already registered");
        }
    }
}
