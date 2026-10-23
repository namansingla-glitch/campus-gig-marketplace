package com.gigmarket.auth;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Objects;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/** Session handling and role checks shared by every servlet. Pages read the same session keys. */
public final class Auth {
    public static final String USER_ID = "userId";
    public static final String USER_NAME = "userName";
    public static final String USER_ROLE = "userRole";
    private static final String CSRF = "csrfToken";
    private static final SecureRandom RANDOM = new SecureRandom();
    private static volatile AccountService service;

    private Auth() {}

    /** One service for the app, backed by MySQL. */
    public static AccountService accounts() {
        AccountService s = service;
        if (s == null) {
            synchronized (Auth.class) {
                if (service == null) service = new AccountService(new JdbcAccountStore(), new PasswordHasher());
                s = service;
            }
        }
        return s;
    }

    /** Starts a logged-in session with a new session id (prevents session fixation). */
    public static void logIn(HttpServletRequest req, Account a) {
        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate();
        HttpSession s = req.getSession(true);
        s.setAttribute(USER_ID, a.getId());
        s.setAttribute(USER_NAME, a.getName());
        s.setAttribute(USER_ROLE, a.sessionRole());
    }

    /** Where each role lands after logging in. Relative to the app root. */
    public static String home(String sessionRole) {
        if ("admin".equals(sessionRole)) return "admin/approvals";
        if ("poster".equals(sessionRole)) return "poster-dashboard.jsp";
        return "student-dashboard.jsp";
    }

    /**
     * Returns the user id when the session has one of the roles. Otherwise answers the request itself
     * (log in page when signed out, 403 when the role is wrong) and returns null; the caller just returns.
     */
    public static Integer require(HttpServletRequest req, HttpServletResponse resp, String... roles) throws IOException {
        HttpSession s = req.getSession(false);
        Integer id = s == null ? null : (Integer) s.getAttribute(USER_ID);
        if (id == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=login");
            return null;
        }
        Object role = s.getAttribute(USER_ROLE);
        for (String r : roles) {
            if (r.equals(role)) return id;
        }
        resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        return null;
    }

    /** A per-session token for forms that change data (admin decisions). */
    public static String csrfToken(HttpServletRequest req) {
        HttpSession s = req.getSession(true);
        String t = (String) s.getAttribute(CSRF);
        if (t == null) {
            byte[] b = new byte[24];
            RANDOM.nextBytes(b);
            t = Base64.getUrlEncoder().withoutPadding().encodeToString(b);
            s.setAttribute(CSRF, t);
        }
        return t;
    }

    public static boolean csrfOk(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        Object expected = s.getAttribute(CSRF);
        String sent = req.getParameter("csrf");
        return expected != null && sent != null && java.security.MessageDigest.isEqual(
                Objects.toString(expected).getBytes(java.nio.charset.StandardCharsets.UTF_8),
                sent.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }

    /** HTML-escapes text for JSP output. */
    public static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
}
