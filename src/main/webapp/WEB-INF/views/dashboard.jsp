<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Auth, com.gigmarket.gigs.Dates, com.gigmarket.gigs.Pay, com.gigmarket.gigs.Rewards, com.gigmarket.gigs.Statuses, com.gigmarket.gigs.Work, java.time.LocalTime, java.time.ZoneId, java.util.List" %>
<%
    // Shown by DashboardServlet (GET /dashboard). Students only. Every figure is counted from their own data.
    String pageTitle = "Your dashboard · campus.gig";
    String navCurrent = "";
    Work.StudentSummary sum = (Work.StudentSummary) request.getAttribute("summary");
    @SuppressWarnings("unchecked") List<Work.StudentRow> now = (List<Work.StudentRow>) request.getAttribute("now");
    Rewards.Tier tier = (Rewards.Tier) request.getAttribute("tier");
    String name = (String) session.getAttribute(Auth.USER_NAME);
    String first = name == null ? "" : name.trim().split("\\s+")[0];
    int hour = LocalTime.now(ZoneId.of("Asia/Kolkata")).getHour();
    String hello = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="auto">
<div class="page page--app" data-kit-plate>
<%@ include file="../jspf/app-nav.jspf" %>
  <main class="app-main">
    <div class="k-head"><h1 class="k-head__title"><%= hello %>, <%= Auth.esc(first) %>.</h1><p class="k-head__lede">Here is where your gigs stand.</p></div>

    <div class="k-stats">
      <div class="k-stat"><span class="k-stat__num"><%= sum.applied %></span><span class="k-stat__what">Applied</span><div class="k-stat__foot"><span>Since you joined</span></div></div>
      <div class="k-stat"><span class="k-stat__num"><%= sum.hired %></span><span class="k-stat__what">Hired</span><div class="k-stat__foot"><span>Picked by faculty</span></div></div>
      <div class="k-stat"><span class="k-stat__num"><%= sum.done %></span><span class="k-stat__what">Done</span><div class="k-stat__foot"><span>Marked done by faculty</span></div></div>
      <div class="k-stat"><span class="k-stat__num"><%= Pay.format(sum.earned) %></span><span class="k-stat__what">Earned</span><div class="k-stat__foot"><span>From done gigs</span></div></div>
    </div>

    <div class="k-two">
      <section class="k-section" aria-labelledby="now-h">
        <h2 class="k-section__title" id="now-h">Your gigs now</h2>
<% if (now.isEmpty()) { %>
        <div class="k-card k-card--empty"><p class="k-card__body">Nothing on the go. <a href="<%= ctx %>/browse-gigs">Find a gig</a> that fits your week.</p></div>
<% } else { %>
        <ul class="k-list">
<%   for (Work.StudentRow r : now) {
       String applyBy = Dates.day(r.applyBy);
       String doneBy = Dates.day(r.doneBy);
       boolean hired = "Hired".equals(r.applicationStatus); %>
          <li class="k-row">
            <div class="k-row__main"><h3 class="k-row__title"><a href="<%= ctx %>/gig?id=<%= r.gigId %>"><%= Auth.esc(r.title) %></a></h3>
              <div class="k-row__meta"><span><%= Pay.format(r.pay) %></span><% if (r.whenText != null) { %><span><%= Auth.esc(r.whenText) %></span><% } %><% if (hired && doneBy != null) { %><span>Done by <%= doneBy %></span><% } else if (!hired) { %><span>Applied <%= Dates.posted(r.appliedAt) %></span><% if (applyBy != null) { %><span>Apply by <%= applyBy %></span><% } } %></div></div>
            <div class="k-row__side"><%= Statuses.badge(Statuses.student(r.applicationStatus, r.gigStatus)) %></div>
          </li>
<%   } %>
        </ul>
<% } %>
        <p class="k-count"><a href="<%= ctx %>/my-applications">All your applications</a></p>
      </section>

      <aside class="k-section" aria-labelledby="tier-h">
        <h2 class="k-section__title" id="tier-h">Your rewards</h2>
<%@ include file="../jspf/tier.jspf" %>
          <a class="k-btn k-btn--ghost tier__link" href="<%= ctx %>/profile">Your profile</a>
        </div>
      </aside>
    </div>
  </main>
</div>
</body>
</html>
