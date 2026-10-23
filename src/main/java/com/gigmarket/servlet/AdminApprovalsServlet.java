package com.gigmarket.servlet;

import com.gigmarket.auth.Auth;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Admin only: faculty waiting for approval, with Approve / Reject. */
@WebServlet("/admin/approvals")
public class AdminApprovalsServlet extends HttpServlet {
    static final String VIEW = "/WEB-INF/views/admin-approvals.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (Auth.require(request, response, "admin") == null) return;
        request.setAttribute("pending", Auth.accounts().pendingFaculty());
        request.setAttribute("csrf", Auth.csrfToken(request));
        request.setAttribute("done", request.getParameter("done"));
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer adminId = Auth.require(request, response, "admin");
        if (adminId == null) return;
        if (!Auth.csrfOk(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String action = request.getParameter("action");
        int accountId;
        try {
            accountId = Integer.parseInt(request.getParameter("accountId"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        boolean approve = "approve".equals(action);
        if (!approve && !"reject".equals(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        boolean changed = Auth.accounts().decide(adminId, accountId, approve);
        response.sendRedirect("approvals?done=" + (changed ? (approve ? "approved" : "rejected") : "none"));
    }
}
