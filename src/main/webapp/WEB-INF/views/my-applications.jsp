<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Auth, com.gigmarket.gigs.Dates, com.gigmarket.gigs.Pay, com.gigmarket.gigs.Statuses, com.gigmarket.gigs.Work, java.util.List" %>
<%
    // Shown by TrackApplicationStatusServlet (GET /my-applications). Students only.
    String pageTitle = "My gigs · campus.gig";
    String navCurrent = "mine";
    @SuppressWarnings("unchecked") List<Work.StudentRow> rows = (List<Work.StudentRow>) request.getAttribute("rows");
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="auto">
<div class="page page--app" data-kit-plate>
<%@ include file="../jspf/app-nav.jspf" %>
  <main class="app-main">
    <div class="k-head"><h1 class="k-head__title">My gigs</h1><p class="k-head__lede">Every gig you applied for, newest first.</p></div>
<% if (rows.isEmpty()) { %>
    <div class="k-card k-card--empty">
      <h2 class="k-card__title">No applications yet</h2>
      <p class="k-card__body">Gigs you apply for appear here. <a href="<%= ctx %>/browse-gigs">See open gigs</a></p>
    </div>
<% } else { %>
    <ul class="k-list">
<%   for (Work.StudentRow r : rows) {
       boolean hired = "Hired".equals(r.applicationStatus);
       String doneBy = Dates.day(r.doneBy); %>
      <li class="k-row">
        <div class="k-row__main"><h2 class="k-row__title"><a href="<%= ctx %>/gig?id=<%= r.gigId %>"><%= Auth.esc(r.title) %></a></h2>
          <div class="k-row__meta"><span><%= Pay.format(r.pay) %></span><% if (hired && "Done".equals(r.gigStatus) && r.doneAt != null) { %><span>Finished <%= Dates.posted(r.doneAt) %></span><% } else { %><span>Applied <%= Dates.posted(r.appliedAt) %></span><% if (hired && doneBy != null) { %><span>Done by <%= doneBy %></span><% } } %></div></div>
        <div class="k-row__side"><%= Statuses.badge(Statuses.student(r.applicationStatus, r.gigStatus)) %></div>
      </li>
<%   } %>
    </ul>
<% } %>
  </main>
</div>
</body>
</html>
