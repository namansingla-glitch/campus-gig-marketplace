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

/** Every gig the student applied for, newest first, with where it stands (/my-applications). Students only. */
@WebServlet("/my-applications")
public class TrackApplicationStatusServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer id = Auth.require(request, response, "student");
        if (id == null) return;
        try {
            request.setAttribute("rows", Work.studentRows(id));
        } catch (SQLException e) {
            throw new ServletException("Could not load your applications", e);
        }
        request.getRequestDispatcher("/WEB-INF/views/my-applications.jsp").forward(request, response);
    }
}
