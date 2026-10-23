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
 * Log in with email + password. The role comes from the database, never from the form.
 * Errors go back to login.jsp as short codes, so the page never shows text taken from the URL.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        AccountService.LoginResult r = Auth.accounts().login(request.getParameter("email"), request.getParameter("password"));
        switch (r.getOutcome()) {
            case OK:
                Auth.logIn(request, r.getAccount());
                response.sendRedirect(Auth.home(r.getAccount().sessionRole()));
                return;
            case PENDING:
                response.sendRedirect("login.jsp?error=pending");
                return;
            case REJECTED:
                response.sendRedirect("login.jsp?error=rejected");
                return;
            default:
                response.sendRedirect("login.jsp?error=invalid");
        }
    }
}
