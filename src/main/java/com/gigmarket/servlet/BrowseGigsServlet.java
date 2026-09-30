package com.gigmarket.servlet;

import com.gigmarket.model.Gig;
import com.gigmarket.util.DatabaseUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/browse-gigs")
public class BrowseGigsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String categoryFilter = request.getParameter("category");
        String minBudgetStr = request.getParameter("minBudget");

        List<Gig> gigs = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT * FROM Gigs WHERE status = 'Open'");
        if (categoryFilter != null && !categoryFilter.trim().isEmpty()) {
            sql.append(" AND category = ?");
        }
        if (minBudgetStr != null && !minBudgetStr.trim().isEmpty()) {
            sql.append(" AND budget >= ?");
        }

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (categoryFilter != null && !categoryFilter.trim().isEmpty()) {
                stmt.setString(paramIndex++, categoryFilter);
            }
            if (minBudgetStr != null && !minBudgetStr.trim().isEmpty()) {
                stmt.setBigDecimal(paramIndex++, new java.math.BigDecimal(minBudgetStr));
            }

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Gig gig = new Gig();
                gig.setGigId(rs.getInt("gig_id"));
                gig.setTitle(rs.getString("title"));
                gig.setDescription(rs.getString("description"));
                gig.setBudget(rs.getBigDecimal("budget"));
                gig.setDeadline(rs.getDate("deadline"));
                gig.setCategory(rs.getString("category"));
                gigs.add(gig);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }

        request.setAttribute("gigs", gigs);
        request.getRequestDispatcher("browse-gigs.jsp").forward(request, response);
    }
}
