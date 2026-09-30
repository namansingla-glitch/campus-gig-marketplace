package com.gigmarket.servlet;

import com.gigmarket.util.DatabaseUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/rate-gig")
public class RateGigServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String gigIdStr = request.getParameter("gigId");
        String ratingStr = request.getParameter("rating");
        
        if (gigIdStr != null && ratingStr != null) {
            try (Connection conn = DatabaseUtil.getConnection()) {
                String sql = "INSERT INTO Reviews (gig_id, rating) VALUES (?, ?)";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(gigIdStr));
                stmt.setInt(2, Integer.parseInt(ratingStr));
                stmt.executeUpdate();
            } catch (SQLException | NumberFormatException e) {
                throw new ServletException("Error saving rating", e);
            }
        }
        
        response.sendRedirect("my-applications");
    }
}
