<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%-- Old address (Tailwind page, removed in 9b). Applicants are at /review-applications?gigId=… --%>
<%
    String id = request.getParameter("gigId");
    response.sendRedirect(id != null && id.matches("\\d{1,9}") ? "review-applications?gigId=" + id : "your-gigs");
%>
