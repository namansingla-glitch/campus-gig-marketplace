package com.gigmarket.servlet;

import com.gigmarket.auth.Auth;
import com.gigmarket.gigs.GigStore;
import com.gigmarket.gigs.Uploads;
import com.gigmarket.model.Gig;
import com.gigmarket.util.DatabaseUtil;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Optional;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

/**
 * A student applies to an open gig, once, with a pitch and an optional portfolio (PDF or image, up to 5 MB).
 * Problems go back to the gig page as short codes; the page shows a fixed message for each.
 */
@WebServlet("/apply-gig")
@MultipartConfig
public class ApplyGigServlet extends HttpServlet {
    public static final int MAX_PITCH = 2000;

    /** Old links (apply-gig?gigId=…) go to the gig page. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("gigId");
        response.sendRedirect(id != null && id.matches("\\d{1,9}") ? "gig?id=" + id : "browse-gigs");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer applicantId = Auth.require(request, response, "student");
        if (applicantId == null) return;

        int gigId;
        try {
            gigId = Integer.parseInt(request.getParameter("gigId"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String back = "gig?id=" + gigId + "&error=";
        String pitch = request.getParameter("pitchText");
        pitch = pitch == null ? "" : pitch.trim();
        if (pitch.isEmpty()) {
            response.sendRedirect(back + "pitch");
            return;
        }
        if (pitch.length() > MAX_PITCH) {
            response.sendRedirect(back + "long");
            return;
        }

        try {
            Optional<Gig> gig = GigStore.byId(gigId);
            if (!gig.isPresent()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (!"Open".equals(gig.get().getStatus())) {
                response.sendRedirect(back + "closed");
                return;
            }
            if (GigStore.application(gigId, applicantId).isPresent()) {
                response.sendRedirect(back + "already");
                return;
            }
        } catch (SQLException e) {
            throw new ServletException("Could not check the gig", e);
        }

        String portfolioPath = null;
        Part filePart = request.getPart("portfolioFile");
        if (filePart != null && filePart.getSize() > 0) {
            String maxStr = getServletContext().getInitParameter("max-file-size");
            long max = maxStr != null ? Long.parseLong(maxStr) : 5_242_880L;
            if (filePart.getSize() > max) {
                response.sendRedirect(back + "size");
                return;
            }
            String safeName = Uploads.storedName(filePart.getSubmittedFileName());
            if (safeName == null) {
                response.sendRedirect(back + "type");
                return;
            }
            File dir = new File(getServletContext().getInitParameter("portfolio-upload-dir"));
            if (!dir.exists() && !dir.mkdirs()) throw new ServletException("Upload folder cannot be created");
            portfolioPath = new File(dir, safeName).getPath();
            filePart.write(portfolioPath);
        }

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                     "INSERT INTO Applications (gig_id, applicant_id, pitch_text, portfolio_path) VALUES (?, ?, ?, ?)")) {
            stmt.setInt(1, gigId);
            stmt.setInt(2, applicantId);
            stmt.setString(3, pitch);
            stmt.setString(4, portfolioPath);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("Could not save the application", e);
        }
        response.sendRedirect("gig?id=" + gigId + "&applied=1");
    }
}
