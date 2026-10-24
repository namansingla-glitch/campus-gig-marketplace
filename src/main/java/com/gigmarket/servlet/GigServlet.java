package com.gigmarket.servlet;

import com.gigmarket.gigs.GigStore;
import com.gigmarket.model.Gig;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * One gig up close (/gig?id=…). Public. What the page offers depends on who looks:
 * a student can apply (or sees their application), the faculty member who posted it can review
 * applicants, anyone else just reads. A missing or malformed id is a 404.
 */
@WebServlet("/gig")
public class GigServlet extends HttpServlet {
    static final String VIEW = "/WEB-INF/views/gig.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        HttpSession session = request.getSession(false);
        Integer userId = session == null ? null : (Integer) session.getAttribute("userId");
        String role = session == null ? null : (String) session.getAttribute("userRole");
        try {
            Optional<Gig> found = GigStore.byId(id);
            if (!found.isPresent()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            Gig gig = found.get();
            request.setAttribute("gig", gig);
            if ("student".equals(role) && userId != null) {
                request.setAttribute("applied", GigStore.application(id, userId).orElse(null));
            }
            boolean owner = "poster".equals(role) && userId != null && userId == gig.getPosterId();
            request.setAttribute("owner", owner);
            if (owner) request.setAttribute("applicationCount", GigStore.applicationCount(id));
        } catch (SQLException e) {
            throw new ServletException("Could not load the gig", e);
        }
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
