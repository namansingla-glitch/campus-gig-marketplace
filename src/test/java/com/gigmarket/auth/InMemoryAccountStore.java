package com.gigmarket.auth;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/** Test double for the MySQL store, with the same rules (unique email, pending-only decisions). */
final class InMemoryAccountStore implements AccountStore {
    final Map<Integer, University> universities = new LinkedHashMap<>();
    final Map<Integer, Account> accounts = new LinkedHashMap<>();
    private int nextId = 1;

    InMemoryAccountStore() {
        universities.put(1, new University(1, "Woxsen University", "woxsen.edu.in", "faculty.woxsen.com"));
    }

    Account add(String name, String email, String hash, Account.Role role, Account.Status status) {
        Account a = new Account(nextId++, name, email, hash, role, status, 1, LocalDateTime.now());
        accounts.put(a.getId(), a);
        return a;
    }

    @Override public List<University> universities() { return new ArrayList<>(universities.values()); }
    @Override public Optional<University> university(int id) { return Optional.ofNullable(universities.get(id)); }

    @Override
    public Optional<Account> findByEmail(String email) {
        return accounts.values().stream().filter(a -> a.getEmail().equals(email)).findFirst();
    }

    @Override public Optional<Account> findById(int id) { return Optional.ofNullable(accounts.get(id)); }

    @Override
    public Account create(String name, String email, String passwordHash, Account.Role role, Account.Status status, int universityId) {
        if (findByEmail(email).isPresent()) throw new DuplicateEmailException();
        return add(name, email, passwordHash, role, status);
    }

    @Override
    public List<Account> pendingFaculty() {
        return accounts.values().stream()
                .filter(a -> a.getRole() == Account.Role.FACULTY && a.getStatus() == Account.Status.PENDING)
                .sorted(Comparator.comparing(Account::getId))
                .collect(Collectors.toList());
    }

    @Override
    public boolean decidePending(int accountId, Account.Status newStatus) {
        Account a = accounts.get(accountId);
        if (a == null || a.getStatus() != Account.Status.PENDING) return false;
        accounts.put(accountId, new Account(a.getId(), a.getName(), a.getEmail(), a.getPasswordHash(), a.getRole(), newStatus,
                a.getUniversityId(), a.getCreatedAt()));
        return true;
    }
}
