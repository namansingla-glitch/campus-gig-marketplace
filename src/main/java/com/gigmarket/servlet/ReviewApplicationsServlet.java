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

@WebServlet("/review-applications")
public class ReviewApplicationsServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String gigIdStr = request.getParameter("gigId");
        List<Application> applications = new ArrayList<>();
        
        if (gigIdStr == null || gigIdStr.isEmpty()) {
            response.sendRedirect("index.jsp");
            return;
        }

        try (Connection conn = DatabaseUtil.getConnection()) {
            String sql = "SELECT a.*, s.name FROM Applications a JOIN Students s ON a.applicant_id = s.student_id WHERE a.gig_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(gigIdStr));
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Application app = new Application();
                app.setApplicationId(rs.getInt("application_id"));
                app.setGigId(rs.getInt("gig_id"));
                app.setApplicantId(rs.getInt("applicant_id"));
                app.setApplicantName(rs.getString("name"));
                app.setPitchText(rs.getString("pitch_text"));
                app.setPortfolioPath(rs.getString("portfolio_path"));
                app.setStatus(rs.getString("status"));
                applications.add(app);
            }
        } catch (SQLException | NumberFormatException e) {
            throw new ServletException("Database error", e);
        }
        
        request.setAttribute("applications", applications);
        request.setAttribute("gigId", gigIdStr);
        request.getRequestDispatcher("review-applications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String applicationIdStr = request.getParameter("applicationId");
        String gigIdStr = request.getParameter("gigId");
        
        if ("hire".equals(action)) {
            try (Connection conn = DatabaseUtil.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    // Mark this application as Hired
                    String sqlHire = "UPDATE Applications SET status = 'Hired' WHERE application_id = ?";
                    PreparedStatement stmtHire = conn.prepareStatement(sqlHire);
                    stmtHire.setInt(1, Integer.parseInt(applicationIdStr));
                    stmtHire.executeUpdate();
                    
                    // Mark others as Rejected
                    String sqlReject = "UPDATE Applications SET status = 'Rejected' WHERE gig_id = ? AND application_id != ?";
                    PreparedStatement stmtReject = conn.prepareStatement(sqlReject);
                    stmtReject.setInt(1, Integer.parseInt(gigIdStr));
                    stmtReject.setInt(2, Integer.parseInt(applicationIdStr));
                    stmtReject.executeUpdate();
                    
                    // Close the gig
                    String sqlGig = "UPDATE Gigs SET status = 'Closed' WHERE gig_id = ?";
                    PreparedStatement stmtGig = conn.prepareStatement(sqlGig);
                    stmtGig.setInt(1, Integer.parseInt(gigIdStr));
                    stmtGig.executeUpdate();
                    
                    conn.commit();
                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                }
            } catch (SQLException | NumberFormatException e) {
                throw new ServletException("Database error", e);
            }
        }
        
        response.sendRedirect("review-applications?gigId=" + gigIdStr);
    }
}
