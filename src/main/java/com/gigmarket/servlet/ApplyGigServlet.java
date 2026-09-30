package com.gigmarket.servlet;

import com.gigmarket.util.DatabaseUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet("/apply-gig")
@MultipartConfig // Required for handling multipart/form-data
public class ApplyGigServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        javax.servlet.http.HttpSession session = request.getSession();
        Integer applicantId = (Integer) session.getAttribute("userId");
        if (applicantId == null) {
            response.sendRedirect("login.jsp?error=Please login first");
            return;
        }
        
        String gigIdStr = request.getParameter("gigId");
        String pitchText = request.getParameter("pitchText");
        
        // Read init parameters from web.xml context
        String uploadDir = getServletContext().getInitParameter("portfolio-upload-dir");
        String maxFileSizeStr = getServletContext().getInitParameter("max-file-size");
        long maxFileSize = maxFileSizeStr != null ? Long.parseLong(maxFileSizeStr) : 5242880; // default 5MB

        File uploadDirFile = new File(uploadDir);
        if (!uploadDirFile.exists()) {
            uploadDirFile.mkdirs();
        }

        Part filePart = request.getPart("portfolioFile");
        String portfolioPath = null;
        
        if (filePart != null && filePart.getSize() > 0) {
            if (filePart.getSize() > maxFileSize) {
                response.sendRedirect("apply-gig.jsp?gigId=" + gigIdStr + "&error=File size exceeds maximum allowed size");
                return;
            }
            
            String fileName = UUID.randomUUID().toString() + "_" + filePart.getSubmittedFileName();
            portfolioPath = uploadDir + File.separator + fileName;
            filePart.write(portfolioPath);
        }

        try (Connection conn = DatabaseUtil.getConnection()) {
            String sql = "INSERT INTO Applications (gig_id, applicant_id, pitch_text, portfolio_path) VALUES (?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(gigIdStr));
            stmt.setInt(2, applicantId);
            stmt.setString(3, pitchText);
            stmt.setString(4, portfolioPath);

            stmt.executeUpdate();
            response.sendRedirect("my-applications?message=Application submitted");
        } catch (SQLException | NumberFormatException e) {
            throw new ServletException("Database error", e);
        }
    }
}
