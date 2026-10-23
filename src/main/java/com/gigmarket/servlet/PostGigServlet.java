package com.gigmarket.servlet;

import com.gigmarket.auth.Auth;
import com.gigmarket.gigs.GigForm;
import com.gigmarket.util.DatabaseUtil;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Post a gig (/post-gig). Faculty only (role from the database at log in, never from a form).
 * GET shows the form; POST checks every field and, when something is wrong, shows the form again with what was typed,
 * a summary that links to each problem and the message next to its field (status 400).
 */
@WebServlet("/post-gig")
public class PostGigServlet extends HttpServlet {
    static final String VIEW = "/WEB-INF/views/post-gig.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (Auth.require(request, response, "poster") == null) return;
        request.setAttribute("form", GigForm.empty());
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer posterId = Auth.require(request, response, "poster");
        if (posterId == null) return;
        if (!Auth.requireCsrf(request, response)) return;

        GigForm form = GigForm.read(request::getParameter, LocalDate.now());
        try (Connection conn = DatabaseUtil.getConnection()) {
            if (form.ok()) {
                try (PreparedStatement s = conn.prepareStatement("SELECT COUNT(*) FROM Gigs WHERE poster_id = ? AND title = ? AND status = 'Open'")) {
                    s.setInt(1, posterId);
                    s.setString(2, form.typed.get("title"));
                    try (ResultSet rs = s.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) form.errors.put("title", "You already have an open gig with this title.");
                    }
                }
            }
            if (!form.ok()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                request.setAttribute("form", form);
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }
            try (PreparedStatement s = conn.prepareStatement("INSERT INTO Gigs (poster_id, title, description, budget, deadline, completion_deadline,"
                    + " category, when_text, where_text) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")) {
                s.setInt(1, posterId);
                s.setString(2, form.typed.get("title"));
                s.setString(3, form.typed.get("description"));
                s.setBigDecimal(4, form.pay);
                if (form.applyBy != null) s.setDate(5, Date.valueOf(form.applyBy)); else s.setNull(5, Types.DATE);
                if (form.doneBy != null) s.setDate(6, Date.valueOf(form.doneBy)); else s.setNull(6, Types.DATE);
                s.setString(7, form.typed.get("category"));
                s.setString(8, form.typed.get("when"));
                s.setString(9, form.typed.get("where"));
                s.executeUpdate();
            }
        } catch (SQLException e) {
            throw new ServletException("Could not save the gig", e);
        }
        response.sendRedirect("your-gigs?posted=1");
    }
}
