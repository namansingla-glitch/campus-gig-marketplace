<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Auth, com.gigmarket.gigs.Dates, com.gigmarket.gigs.Pay, com.gigmarket.gigs.Statuses, com.gigmarket.gigs.Work, java.util.List" %>
<%
    // Shown by YourGigsServlet (GET /your-gigs). Faculty only. Counts are real; nothing here is a sample.
    String pageTitle = "Your gigs · campus.gig";
    String navCurrent = "mine";
    Work.FacultySummary sum = (Work.FacultySummary) request.getAttribute("summary");
    @SuppressWarnings("unchecked") List<Work.FacultyRow> rows = (List<Work.FacultyRow>) request.getAttribute("rows");
    String csrf = Auth.csrfToken(request);
    String done = request.getParameter("done");
    String note = "1".equals(request.getParameter("posted")) ? "Your gig is on the board."
            : "1".equals(done) ? "Marked done. The student sees it as done."
            : "none".equals(done) ? "That gig was not in progress, so nothing changed." : null;
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="light">
<div class="page page--app" data-kit-plate>
<%@ include file="../jspf/app-nav.jspf" %>
  <main class="app-main">
    <div class="k-head"><h1 class="k-head__title">Your gigs</h1><p class="k-head__lede">Everything you have pinned, newest first.</p></div>
<% if (note != null) { %>
    <div class="k-card notice" role="status"><p class="k-card__body"><%= note %></p></div>
<% } %>
    <div class="k-stats">
      <div class="k-stat"><span class="k-stat__num"><%= sum.open %></span><span class="k-stat__what">Open</span><div class="k-stat__foot"><span>Taking applications</span></div></div>
      <div class="k-stat"><span class="k-stat__num"><%= sum.waiting %></span><span class="k-stat__what">Applicants</span><div class="k-stat__foot"><span>Waiting for you</span></div></div>
      <div class="k-stat"><span class="k-stat__num"><%= sum.inProgress %></span><span class="k-stat__what">In progress</span><div class="k-stat__foot"><span>A student is on it</span></div></div>
      <div class="k-stat"><span class="k-stat__num"><%= sum.done %></span><span class="k-stat__what">Done</span><div class="k-stat__foot"><span>Marked done</span></div></div>
    </div>
<% if (rows.isEmpty()) { %>
    <div class="k-card k-card--empty">
      <h2 class="k-card__title">No gigs yet</h2>
      <p class="k-card__body">Pin a small paid task and students see it right away.</p>
      <div class="k-acts"><a class="k-btn" href="<%= ctx %>/post-gig">Post a gig</a></div>
    </div>
<% } else { %>
    <ul class="k-list">
<%   for (Work.FacultyRow r : rows) {
       String applyBy = Dates.day(r.applyBy);
       String doneBy = Dates.day(r.doneBy);
       String review = ctx + "/review-applications?gigId=" + r.gigId; %>
      <li class="k-row">
        <div class="k-row__main"><h2 class="k-row__title"><a href="<%= ctx %>/gig?id=<%= r.gigId %>"><%= Auth.esc(r.title) %></a></h2>
          <div class="k-row__meta"><span><%= Pay.format(r.pay) %></span><%
       if ("Open".equals(r.status)) { %><% if (applyBy != null) { %><span>Apply by <%= applyBy %></span><% } %><span>Posted <%= Dates.posted(r.createdAt) %></span><%
       } else { %><% if (r.hiredName != null) { %><span>Hired: <%= Auth.esc(r.hiredName) %></span><% } %><% if ("Done".equals(r.status) && r.doneAt != null) { %><span>Finished <%= Dates.posted(r.doneAt) %></span><% } else if (doneBy != null) { %><span>Done by <%= doneBy %></span><% } } %></div></div>
        <div class="k-row__side"><%= Statuses.badge(Statuses.gig(r.status)) %></div>
        <div class="k-row__acts">
<%     if ("Open".equals(r.status)) { %>
          <a class="k-btn" href="<%= review %>">Review applicants (<%= r.applicants %>)</a>
<%     } else if ("In progress".equals(r.status)) { %>
          <form action="<%= ctx %>/your-gigs" method="post"><input type="hidden" name="csrf" value="<%= csrf %>"><input type="hidden" name="action" value="done"><input type="hidden" name="gigId" value="<%= r.gigId %>"><button class="k-btn" type="submit">Mark done</button></form>
          <a class="k-btn k-btn--ghost" href="<%= review %>">See applicants</a>
<%     } else { %>
          <a class="k-btn k-btn--ghost" href="<%= review %>">See applicants</a>
<%     } %>
        </div>
      </li>
<%   } %>
    </ul>
<% } %>
  </main>
</div>
</body>
</html>
