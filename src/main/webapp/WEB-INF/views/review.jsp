<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Auth, com.gigmarket.gigs.Dates, com.gigmarket.gigs.Pay, com.gigmarket.gigs.Statuses, com.gigmarket.gigs.Work, com.gigmarket.model.Gig, java.util.List" %>
<%
    // Shown by ReviewApplicationsServlet (GET /review-applications?gigId=…). The gig's owner only.
    Gig gig = (Gig) request.getAttribute("gig");
    @SuppressWarnings("unchecked") List<Work.Applicant> applicants = (List<Work.Applicant>) request.getAttribute("applicants");
    String pageTitle = "Applicants: " + gig.getTitle() + " · campus.gig";
    String navCurrent = "mine";
    String csrf = Auth.csrfToken(request);
    boolean open = "Open".equals(gig.getStatus());
    String applyBy = Dates.day(gig.getDeadline());
    String done = request.getParameter("done");
    String note = "hired".equals(done) ? "Hired. The others were told “Not picked”, and the gig is now in progress."
            : "rejected".equals(done) ? "Marked “Not picked”."
            : "none".equals(done) ? "That applicant was no longer pending, so nothing changed." : null;
    int n = applicants.size();
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="light">
<div class="page page--app" data-kit-plate>
<%@ include file="../jspf/app-nav.jspf" %>
  <main class="app-main">
    <a class="k-back" href="<%= ctx %>/your-gigs">← Your gigs</a>
    <div class="k-head k-head__row">
      <div><h1 class="k-head__title"><%= Auth.esc(gig.getTitle()) %></h1><p class="k-head__lede"><%= n %> applicant<%= n == 1 ? "" : "s" %> · <%= Pay.format(gig.getBudget()) %><%= open && applyBy != null ? " · apply by " + applyBy : "" %></p></div>
      <%= Statuses.badge(Statuses.gig(gig.getStatus())) %>
    </div>
<% if (note != null) { %>
    <div class="k-card notice" role="status"><p class="k-card__body"><%= note %></p></div>
<% } %>
<% if (applicants.isEmpty()) { %>
    <div class="k-card k-card--empty"><h2 class="k-card__title">No applicants yet</h2><p class="k-card__body">Students who apply show up here.</p></div>
<% } else { %>
    <ul class="k-list">
<%   for (Work.Applicant a : applicants) {
       boolean pending = "Pending".equals(a.status); %>
      <li class="k-row">
        <div class="k-row__main"><h2 class="k-row__title"><%= Auth.esc(a.name) %></h2><div class="k-row__meta"><span><%= Auth.esc(a.email) %></span><span>Applied <%= Dates.posted(a.appliedAt) %></span></div></div>
        <div class="k-row__side"><%= Statuses.badge(Statuses.applicant(a.status)) %></div>
        <p class="k-row__body"><%= Auth.esc(a.pitch) %></p>
<%     if (a.hasPortfolio || (open && pending)) { %>
        <div class="k-row__acts">
<%       if (a.hasPortfolio) { %>
          <a class="k-btn k-btn--ghost" href="<%= ctx %>/portfolio?application=<%= a.applicationId %>" download>Download portfolio (<%= a.portfolioType == null ? "file" : a.portfolioType.toUpperCase() %>)</a>
<%       } if (open && pending) { %>
          <form action="<%= ctx %>/review-applications" method="post"><input type="hidden" name="csrf" value="<%= csrf %>"><input type="hidden" name="gigId" value="<%= gig.getGigId() %>"><input type="hidden" name="applicationId" value="<%= a.applicationId %>"><button class="k-btn" type="submit" name="action" value="hire">Hire <%= Auth.esc(a.name.trim().split("\\s+")[0]) %></button><button class="k-btn k-btn--danger" type="submit" name="action" value="reject">Not this time</button></form>
<%       } %>
        </div>
<%     } %>
      </li>
<%   } %>
    </ul>
<% } %>
<% if (open) { %>
    <p class="k-count">Hiring one applicant marks the others “Not picked” and moves the gig to In progress. You mark it done on <a href="<%= ctx %>/your-gigs">Your gigs</a> when the work is in.</p>
<% } else if ("In progress".equals(gig.getStatus())) { %>
    <form class="k-acts" action="<%= ctx %>/your-gigs" method="post"><input type="hidden" name="csrf" value="<%= csrf %>"><input type="hidden" name="action" value="done"><input type="hidden" name="gigId" value="<%= gig.getGigId() %>"><button class="k-btn" type="submit">Mark done</button></form>
<% } %>
  </main>
</div>
</body>
</html>
