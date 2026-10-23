package com.gigmarket.servlet;

import com.gigmarket.auth.AccountService;
import com.gigmarket.auth.Auth;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Join. GET shows the form with the universities from the database; POST creates the account.
 * Students are logged in at once; faculty see "Almost there" and wait for an admin.
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    static final String VIEW = "/WEB-INF/views/register.jsp";
    static final String PENDING_VIEW = "/WEB-INF/views/register-pending.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        show(request, response, null);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        AccountService.JoinResult r = Auth.accounts().join(
                request.getParameter("university"), request.getParameter("name"),
                request.getParameter("email"), request.getParameter("password"));
        switch (r.getKind()) {
            case ACTIVE:
                Auth.logIn(request, r.getAccount());
                response.sendRedirect(Auth.home(r.getAccount().sessionRole()));
                return;
            case PENDING:
                request.setAttribute("pendingEmail", r.getAccount().getEmail());
                request.getRequestDispatcher(PENDING_VIEW).forward(request, response);
                return;
            default:
                show(request, response, r);
        }
    }

    private void show(HttpServletRequest request, HttpServletResponse response, AccountService.JoinResult error)
            throws ServletException, IOException {
        request.setAttribute("universities", Auth.accounts().universities());
        if (error != null) {
            request.setAttribute("errorField", error.getField());
            request.setAttribute("errorMessage", error.getMessage());
            // Keep what was typed (never the password).
            request.setAttribute("valueName", request.getParameter("name"));
            request.setAttribute("valueEmail", request.getParameter("email"));
            request.setAttribute("valueUniversity", request.getParameter("university"));
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
