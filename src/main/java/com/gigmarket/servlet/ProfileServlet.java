package com.gigmarket.servlet;

import com.gigmarket.auth.Auth;
import com.gigmarket.gigs.Rewards;
import com.gigmarket.gigs.Work;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * The student's profile (/profile): tier, achievements with the real day each was earned, and their own place
 * this month. No leaderboard of other students (decisions §20u, Q2 = c).
 */
@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer id = Auth.require(request, response, "student");
        if (id == null) return;
        try {
            List<Rewards.Done> done = Work.finished(id);
            request.setAttribute("person", Work.person(id));
            request.setAttribute("tier", Rewards.tier(Rewards.points(done)));
            request.setAttribute("achievements", Rewards.achievements(done));
            Map<Integer, Integer> month = Work.monthPoints(LocalDate.now());
            Integer mine = month.get(id);
            request.setAttribute("standing", Rewards.standing(mine == null ? 0 : mine, month.values()));
        } catch (SQLException e) {
            throw new ServletException("Could not load the profile", e);
        }
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }
}
