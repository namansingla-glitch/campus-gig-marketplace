package com.gigmarket.servlet;

import com.gigmarket.auth.Auth;
import com.gigmarket.gigs.Rewards;
import com.gigmarket.gigs.Statuses;
import com.gigmarket.gigs.Work;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** The student's home (/dashboard): counts, gigs still in play, and rewards. Every figure is counted from their own data. */
@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    static final int NOW_ROWS = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer id = Auth.require(request, response, "student");
        if (id == null) return;
        try {
            request.setAttribute("summary", Work.studentSummary(id));
            List<Work.StudentRow> now = new ArrayList<>();
            for (Work.StudentRow r : Work.studentRows(id)) {
                if (Statuses.active(r.applicationStatus, r.gigStatus) && now.size() < NOW_ROWS) now.add(r);
            }
            request.setAttribute("now", now);
            request.setAttribute("tier", Rewards.tier(Rewards.points(Work.finished(id))));
        } catch (SQLException e) {
            throw new ServletException("Could not load the dashboard", e);
        }
        request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);
    }
}
