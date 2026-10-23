package com.gigmarket.servlet;

import com.gigmarket.auth.Auth;
import com.gigmarket.gigs.Categories;
import com.gigmarket.util.DatabaseUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/post-gig")
public class PostGigServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Faculty only (role from the database at log in, never from a form).
        Integer posterId = Auth.require(request, response, "poster");
        if (posterId == null) return;

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String budgetStr = request.getParameter("budget");
        String deadlineStr = request.getParameter("deadline");
        String completionDeadlineStr = request.getParameter("completionDeadline");
        String category = request.getParameter("category");
        String whenText = request.getParameter("whenText");
        String whereText = request.getParameter("whereText");
        whenText = whenText == null ? "" : whenText.trim();
        whereText = whereText == null ? "" : whereText.trim();

        if (title == null || title.trim().isEmpty() || description == null || budgetStr == null || budgetStr.trim().isEmpty()
                || whenText.isEmpty() || whereText.isEmpty()) {
            response.sendRedirect("post-gig.jsp?error=Fill in every field: title, description, pay, when and where.");
            return;
        }
        if (whenText.length() > 120 || whereText.length() > 120 || title.trim().length() > 200) {
            response.sendRedirect("post-gig.jsp?error=Keep when and where under 120 characters, and the title under 200.");
            return;
        }
        if (!Categories.known(category)) {
            response.sendRedirect("post-gig.jsp?error=Choose one of the categories.");
            return;
        }

        try (Connection conn = DatabaseUtil.getConnection()) {
            // Duplicate Open Gig check (Rule #13)
            String checkSql = "SELECT COUNT(*) FROM Gigs WHERE poster_id = ? AND title = ? AND status = 'Open'";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, posterId);
                checkStmt.setString(2, title.trim());
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    response.sendRedirect("post-gig.jsp?error=An active gig with this title already exists.");
                    return;
                }
            }

            String sql = "INSERT INTO Gigs (poster_id, title, description, budget, deadline, completion_deadline, category, when_text, where_text) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, posterId);
            stmt.setString(2, title.trim());
            stmt.setString(3, description.trim());
            stmt.setBigDecimal(4, new BigDecimal(budgetStr));
            
            if (deadlineStr != null && !deadlineStr.trim().isEmpty()) {
                stmt.setDate(5, Date.valueOf(deadlineStr));
            } else {
                stmt.setNull(5, java.sql.Types.DATE);
            }

            if (completionDeadlineStr != null && !completionDeadlineStr.trim().isEmpty()) {
                stmt.setDate(6, Date.valueOf(completionDeadlineStr));
            } else {
                stmt.setNull(6, java.sql.Types.DATE);
            }

            stmt.setString(7, category);
            stmt.setString(8, whenText);
            stmt.setString(9, whereText);

            stmt.executeUpdate();
            response.sendRedirect("poster-dashboard.jsp?message=Gig created successfully.");
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        } catch (IllegalArgumentException e) {
            response.sendRedirect("post-gig.jsp?error=Invalid data format");
        }
    }
}
