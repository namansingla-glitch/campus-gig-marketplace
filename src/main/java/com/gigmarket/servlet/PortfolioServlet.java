package com.gigmarket.servlet;

import com.gigmarket.auth.Auth;
import com.gigmarket.gigs.Uploads;
import com.gigmarket.gigs.Work;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Download an applicant's portfolio (/portfolio?application=…). Only the faculty member who owns the gig, or the
 * student who sent it. The file is looked up by its stored random name inside the upload folder only, and is always
 * sent as a download (never shown inline, no type sniffing), so an uploaded file cannot run as a page on this site.
 */
@WebServlet("/portfolio")
public class PortfolioServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = Auth.require(request, response, "poster", "student");
        if (userId == null) return;
        HttpSession session = request.getSession(false);
        String role = (String) session.getAttribute(Auth.USER_ROLE);
        int applicationId;
        try {
            applicationId = Integer.parseInt(request.getParameter("application"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        Work.Portfolio p;
        try {
            p = Work.portfolio(applicationId);
        } catch (SQLException e) {
            throw new ServletException("Could not find the portfolio", e);
        }
        if (p == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        boolean allowed = ("poster".equals(role) && p.posterId == userId) || ("student".equals(role) && p.applicantId == userId);
        if (!allowed) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String name = Uploads.storedFile(p.path);
        File dir = new File(getServletContext().getInitParameter("portfolio-upload-dir")).getCanonicalFile();
        File file = name == null ? null : new File(dir, name).getCanonicalFile();
        if (file == null || !dir.equals(file.getParentFile()) || !file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String ext = Uploads.extension(p.path);
        response.setContentType(Uploads.contentType(ext));
        response.setHeader("Content-Disposition", "attachment; filename=\"portfolio-" + applicationId + "." + ext + "\"");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "private, no-store");
        response.setHeader("Content-Security-Policy", "default-src 'none'; sandbox");
        response.setContentLengthLong(file.length());
        Files.copy(file.toPath(), response.getOutputStream());
    }
}
