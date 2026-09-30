package com.gigmarket.servlet;

import com.gigmarket.model.Application;
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

@WebServlet("/my-applications")
public class TrackApplicationStatusServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        javax.servlet.http.HttpSession session = request.getSession();
        Integer applicantId = (Integer) session.getAttribute("userId");
        if (applicantId == null) {
            response.sendRedirect("login.jsp?error=Please login first");
            return;
        }
        
        List<Application> applications = new ArrayList<>();
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            String sql = "SELECT a.*, g.title as gig_title FROM Applications a JOIN Gigs g ON a.gig_id = g.gig_id WHERE a.applicant_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, applicantId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Application app = new Application();
                app.setApplicationId(rs.getInt("application_id"));
                app.setGigId(rs.getInt("gig_id"));
                app.setPitchText(rs.getString("gig_title")); // Repurposing field for UI simplicity
                app.setStatus(rs.getString("status"));
                applications.add(app);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
        
        request.setAttribute("applications", applications);
        request.getRequestDispatcher("my-applications.jsp").forward(request, response);
    }
}
