package com.gigmarket.servlet;

import com.gigmarket.auth.Auth;
import com.gigmarket.auth.GigAccess;
import com.gigmarket.gigs.GigStore;
import com.gigmarket.gigs.Work;
import com.gigmarket.model.Gig;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Applicants on one of the faculty member's own gigs (/review-applications?gigId=…).
 * POST action=hire | reject, with the form token. Hire: that applicant Hired, other pending ones Not picked, gig In progress.
 * Reject: only a pending applicant. Results come back as short codes (?done=hired | rejected | none).
 */
@WebServlet("/review-applications")
public class ReviewApplicationsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer facultyId = Auth.require(request, response, "poster");
        if (facultyId == null) return;
        int gigId;
        try {
            gigId = Integer.parseInt(request.getParameter("gigId"));
        } catch (NumberFormatException e) {
            response.sendRedirect("your-gigs");
            return;
        }
        try {
            Optional<Gig> gig = GigStore.byId(gigId);
            if (!gig.isPresent()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (gig.get().getPosterId() != facultyId) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            request.setAttribute("gig", gig.get());
            request.setAttribute("applicants", Work.applicants(gigId));
        } catch (SQLException e) {
            throw new ServletException("Could not load the applicants", e);
        }
        request.getRequestDispatcher("/WEB-INF/views/review.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer facultyId = Auth.require(request, response, "poster");
        if (facultyId == null) return;
        if (!Auth.requireCsrf(request, response)) return;
        int gigId;
        int applicationId;
        try {
            gigId = Integer.parseInt(request.getParameter("gigId"));
            applicationId = Integer.parseInt(request.getParameter("applicationId"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        String action = request.getParameter("action");
        try {
            if (!GigAccess.postedBy(gigId, facultyId) || !GigAccess.applicationOnGig(applicationId, gigId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            String done;
            if ("hire".equals(action)) done = Work.hire(gigId, applicationId) ? "hired" : "none";
            else if ("reject".equals(action)) done = Work.reject(gigId, applicationId) ? "rejected" : "none";
            else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            response.sendRedirect("review-applications?gigId=" + gigId + "&done=" + done);
        } catch (SQLException e) {
            throw new ServletException("Could not save the decision", e);
        }
    }
}
