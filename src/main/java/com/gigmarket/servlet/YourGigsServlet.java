package com.gigmarket.servlet;

import com.gigmarket.auth.Auth;
import com.gigmarket.gigs.Work;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * The faculty member's home (/your-gigs): every gig they posted, newest first, with real counts.
 * POST action=done marks one of their in-progress gigs done (owner only, with the form token).
 */
@WebServlet("/your-gigs")
public class YourGigsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer id = Auth.require(request, response, "poster");
        if (id == null) return;
        try {
            request.setAttribute("summary", Work.facultySummary(id));
            request.setAttribute("rows", Work.facultyRows(id));
        } catch (SQLException e) {
            throw new ServletException("Could not load your gigs", e);
        }
        request.getRequestDispatcher("/WEB-INF/views/your-gigs.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer id = Auth.require(request, response, "poster");
        if (id == null) return;
        if (!Auth.requireCsrf(request, response)) return;
        int gigId;
        try {
            gigId = Integer.parseInt(request.getParameter("gigId"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        if (!"done".equals(request.getParameter("action"))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            if (!com.gigmarket.auth.GigAccess.postedBy(gigId, id)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            response.sendRedirect("your-gigs?done=" + (Work.markDone(gigId, id) ? "1" : "none"));
        } catch (SQLException e) {
            throw new ServletException("Could not mark the gig done", e);
        }
    }
}
