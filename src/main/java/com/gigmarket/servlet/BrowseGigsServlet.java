package com.gigmarket.servlet;

import com.gigmarket.gigs.Categories;
import com.gigmarket.gigs.GigStore;
import com.gigmarket.gigs.Pay;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * The feed: open gigs, newest first. Public (visitors can browse). Filters come from a plain GET form:
 * any number of "category" values and an optional "minPay". A pay value that is not a number shows a
 * message on that field instead of a server error, and the list is shown without that filter.
 */
@WebServlet("/browse-gigs")
public class BrowseGigsServlet extends HttpServlet {
    static final String VIEW = "/WEB-INF/views/feed.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<String> chosen = new ArrayList<>();
        String[] cats = request.getParameterValues("category");
        if (cats != null) {
            for (String c : cats) {
                if (Categories.known(c) && !chosen.contains(c)) chosen.add(c);
            }
        }
        String minPayTyped = request.getParameter("minPay");
        BigDecimal minPay = null;
        String minPayError = null;
        try {
            minPay = Pay.parse(minPayTyped);
        } catch (IllegalArgumentException e) {
            minPayError = e.getMessage();
        }
        try {
            request.setAttribute("gigs", GigStore.open(chosen, minPay));
        } catch (SQLException e) {
            throw new ServletException("Could not load gigs", e);
        }
        request.setAttribute("chosen", chosen);
        request.setAttribute("minPayTyped", minPayTyped == null ? "" : minPayTyped);
        request.setAttribute("minPayError", minPayError);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
