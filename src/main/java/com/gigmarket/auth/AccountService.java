package com.gigmarket.auth;

import java.util.List;
import java.util.Optional;

/** Join, log in and faculty approval. No servlet code here, so all of it is unit-tested. */
public final class AccountService {
    private final AccountStore store;
    private final PasswordHasher hasher;
    /** Verified when the email is unknown, so a wrong email takes as long as a wrong password. */
    private final String dummyHash;

    public AccountService(AccountStore store, PasswordHasher hasher) {
        this.store = store;
        this.hasher = hasher;
        this.dummyHash = hasher.hash("not-a-real-password");
    }

    // ---------- Join ----------

    public static final class JoinResult {
        public enum Kind { ACTIVE, PENDING, ERROR }
        private final Kind kind;
        private final Account account;
        private final String field;
        private final String message;

        private JoinResult(Kind kind, Account account, String field, String message) {
            this.kind = kind;
            this.account = account;
            this.field = field;
            this.message = message;
        }

        static JoinResult error(String field, String message) { return new JoinResult(Kind.ERROR, null, field, message); }

        public Kind getKind() { return kind; }
        public Account getAccount() { return account; }
        /** Which form field the error belongs to: university, name, email or password. */
        public String getField() { return field; }
        public String getMessage() { return message; }
    }

    /** Students become active at once; faculty wait for an admin. Nobody can choose their own role. */
    public JoinResult join(String universityIdParam, String name, String emailParam, String password) {
        University uni = parseUniversity(universityIdParam);
        if (uni == null) return JoinResult.error("university", "Choose your university.");
        String nameError = AccountRules.checkName(name);
        if (nameError != null) return JoinResult.error("name", nameError);
        String email = AccountRules.normalizeEmail(emailParam);
        if (email == null || email.isEmpty()) return JoinResult.error("email", "Add your university email.");
        if (email.length() > AccountRules.MAX_EMAIL) return JoinResult.error("email", "That email is too long.");
        Account.Role role = AccountRules.roleFor(email, uni);
        if (role == null) return JoinResult.error("email", AccountRules.wrongDomainMessage(uni));
        String passwordError = AccountRules.checkPassword(password);
        if (passwordError != null) return JoinResult.error("password", passwordError);
        if (store.findByEmail(email).isPresent()) return JoinResult.error("email", "That email already has an account. Log in instead.");

        Account.Status status = role == Account.Role.FACULTY ? Account.Status.PENDING : Account.Status.ACTIVE;
        try {
            Account created = store.create(name.trim(), email, hasher.hash(password), role, status, uni.getId());
            return new JoinResult(status == Account.Status.ACTIVE ? JoinResult.Kind.ACTIVE : JoinResult.Kind.PENDING, created, null, null);
        } catch (AccountStore.DuplicateEmailException e) {
            return JoinResult.error("email", "That email already has an account. Log in instead.");
        }
    }

    private University parseUniversity(String idParam) {
        if (idParam == null) return null;
        try {
            return store.university(Integer.parseInt(idParam.trim())).orElse(null);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // ---------- Log in ----------

    public enum LoginOutcome { OK, INVALID, PENDING, REJECTED }

    public static final class LoginResult {
        private final LoginOutcome outcome;
        private final Account account;

        LoginResult(LoginOutcome outcome, Account account) {
            this.outcome = outcome;
            this.account = account;
        }

        public LoginOutcome getOutcome() { return outcome; }
        public Account getAccount() { return account; }
    }

    /**
     * A wrong email and a wrong password give the same INVALID result, so the form never reveals who has an
     * account. PENDING and REJECTED are only told to someone who knows the password.
     */
    public LoginResult login(String emailParam, String password) {
        String email = AccountRules.normalizeEmail(emailParam);
        Optional<Account> found = (email == null || email.isEmpty()) ? Optional.empty() : store.findByEmail(email);
        if (!found.isPresent()) {
            hasher.verify(password == null ? "" : password, dummyHash);
            return new LoginResult(LoginOutcome.INVALID, null);
        }
        Account a = found.get();
        if (!hasher.verify(password, a.getPasswordHash())) return new LoginResult(LoginOutcome.INVALID, null);
        if (a.getStatus() == Account.Status.PENDING) return new LoginResult(LoginOutcome.PENDING, null);
        if (a.getStatus() == Account.Status.REJECTED) return new LoginResult(LoginOutcome.REJECTED, null);
        return new LoginResult(LoginOutcome.OK, a);
    }

    // ---------- Approvals ----------

    public List<Account> pendingFaculty() {
        return store.pendingFaculty();
    }

    /** Only an active admin may decide; returns false if not allowed or the account is not pending. */
    public boolean decide(int adminId, int accountId, boolean approve) {
        Optional<Account> admin = store.findById(adminId);
        if (!admin.isPresent() || admin.get().getRole() != Account.Role.ADMIN || admin.get().getStatus() != Account.Status.ACTIVE) return false;
        return store.decidePending(accountId, approve ? Account.Status.ACTIVE : Account.Status.REJECTED);
    }

    public List<University> universities() {
        return store.universities();
    }
}
