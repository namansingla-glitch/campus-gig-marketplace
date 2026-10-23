<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    // Shown for 404 (web.xml error-page). Fixed text only.
    String pageTitle = "This page is not on the board · campus.gig";
    String errCode = "404";
    String errTitle = "This page is not on the board";
    String errBody = "The link may be old, or the gig was taken down.";
    String errRole = (String) (session == null ? null : session.getAttribute("userRole"));
    String errHome = request.getContextPath() + "/" + (errRole == null ? "" : com.gigmarket.auth.Auth.home(errRole));
    String errActions = "<a class=\"k-btn\" href=\"" + request.getContextPath() + "/browse-gigs\">See open gigs</a><a class=\"k-btn k-btn--ghost\" href=\"" + errHome + "\">Home</a>";
%>
<%@ include file="WEB-INF/jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
<%@ include file="WEB-INF/jspf/errpage.jspf" %>
