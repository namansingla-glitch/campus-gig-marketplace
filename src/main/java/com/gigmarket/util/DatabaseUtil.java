package com.gigmarket.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database settings come from environment variables, never from the code (the repo is public):
 * DB_URL (default: local MySQL, database gig_marketplace), DB_USER (default root), DB_PASSWORD (default empty).
 */
public class DatabaseUtil {
    private static final String URL = env("DB_URL", "jdbc:mysql://localhost:3306/gig_marketplace?createDatabaseIfNotExist=true");
    private static final String USER = env("DB_USER", "root");
    private static final String PASSWORD = env("DB_PASSWORD", "");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private static String env(String name, String fallback) {
        String v = System.getenv(name);
        return v == null || v.isEmpty() ? fallback : v;
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
