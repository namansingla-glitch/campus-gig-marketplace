package com.gigmarket.servlet;

import com.gigmarket.util.DatabaseUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String role = request.getParameter("role"); // "student" or "poster"

        if (email == null || email.trim().isEmpty() || role == null) {
            response.sendRedirect("login.jsp?error=Missing credentials");
            return;
        }

        try (Connection conn = DatabaseUtil.getConnection()) {
            String sql = "SELECT student_id, name FROM Students WHERE email = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, email.trim());
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("userId", rs.getInt("student_id"));
                session.setAttribute("userName", rs.getString("name"));
                session.setAttribute("userRole", role);

                if ("poster".equals(role)) {
                    response.sendRedirect("poster-dashboard.jsp");
                } else {
                    response.sendRedirect("student-dashboard.jsp");
                }
            } else {
                response.sendRedirect("login.jsp?error=Invalid email");
            }
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }
}
