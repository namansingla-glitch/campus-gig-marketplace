<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    // Old address. The gig page (/gig?id=…) now shows the gig and the apply form.
    String id = request.getParameter("gigId");
    response.sendRedirect(id != null && id.matches("\\d{1,9}") ? "gig?id=" + id : "browse-gigs");
%>
