<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    // Shown for 403 (web.xml error-page). Fixed text only.
    String pageTitle = "This page is not yours to open · campus.gig";
    String errCode = "403";
    String errTitle = "This page is not yours to open";
    String errBody = "It belongs to another account or another role. Go back to your home, or log in with the right account.";
    String errRole = (String) (session == null ? null : session.getAttribute("userRole"));
    String errHome = request.getContextPath() + "/" + (errRole == null ? "" : com.gigmarket.auth.Auth.home(errRole));
    String errActions = errRole == null ? "<a class=\"k-btn\" href=\"" + request.getContextPath() + "/login.jsp\">Log in</a>" : "<a class=\"k-btn\" href=\"" + errHome + "\">Go to your home</a><a class=\"k-btn k-btn--ghost\" href=\"" + request.getContextPath() + "/logout\">Log out</a>";
%>
<%@ include file="WEB-INF/jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
<%@ include file="WEB-INF/jspf/errpage.jspf" %>
