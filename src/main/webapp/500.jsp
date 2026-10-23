<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" isErrorPage="true" %>
<%
    // Shown for 500 (web.xml error-page). Fixed text only.
    String pageTitle = "Something broke on our side · campus.gig";
    String errCode = "500";
    String errTitle = "Something broke on our side";
    String errBody = "Try again in a minute. If it keeps happening, tell the person who runs the site.";
    String errRole = (String) (session == null ? null : session.getAttribute("userRole"));
    String errHome = request.getContextPath() + "/" + (errRole == null ? "" : com.gigmarket.auth.Auth.home(errRole));
    String errActions = "<a class=\"k-btn\" href=\"" + errHome + "\">Home</a><a class=\"k-btn k-btn--ghost\" href=\"" + request.getContextPath() + "/browse-gigs\">See open gigs</a>";
%>
<%@ include file="WEB-INF/jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
<%@ include file="WEB-INF/jspf/errpage.jspf" %>
