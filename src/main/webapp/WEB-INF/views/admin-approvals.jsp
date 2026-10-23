<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Account, com.gigmarket.auth.Auth, java.time.format.DateTimeFormatter, java.util.List" %>
<%
    // Shown by AdminApprovalsServlet (admin only). Each decision is a POST with the session's form token.
    String pageTitle = "Approvals · campus.gig";
    @SuppressWarnings("unchecked")
    List<Account> pending = (List<Account>) request.getAttribute("pending");
    String csrf = (String) request.getAttribute("csrf");
    String done = (String) request.getAttribute("done");
    String doneText = "approved".equals(done) ? "Approved. They can log in now."
            : "rejected".equals(done) ? "Rejected. They can't log in."
            : "none".equals(done) ? "That account was already decided." : null;
    DateTimeFormatter when = DateTimeFormatter.ofPattern("d MMM yyyy, HH:mm");
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/admin.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="auto">
<div class="page adm">
  <header class="k-top">
    <a class="k-word" href="<%= ctx %>/">campus<span class="k-word__dot">.</span>gig</a>
    <nav class="k-top__links" aria-label="Admin"><a href="<%= ctx %>/admin/approvals" aria-current="page">Approvals</a></nav>
    <div class="adm-top"><a class="k-btn k-btn--ghost" href="<%= ctx %>/logout">Log out</a></div>
  </header>

  <main class="adm-main">
    <div class="adm-head">
      <h1>Faculty waiting for approval</h1>
      <p class="sub">Check each name against the Woxsen staff list before approving. Approved faculty can post gigs.</p>
    </div>
<% if (doneText != null) { %>
    <div class="k-card" role="status"><p class="k-card__body"><%= doneText %></p></div>
<% } %>
<% if (pending == null || pending.isEmpty()) { %>
    <div class="k-card k-card--empty"><h2 class="k-card__title">Nobody waiting</h2><p class="k-card__body">New faculty sign-ups appear here.</p></div>
<% } else { %>
    <ul class="adm-list">
<%   for (Account a : pending) { %>
      <li class="k-card adm-row">
        <div class="adm-who"><strong><%= Auth.esc(a.getName()) %></strong><span><%= Auth.esc(a.getEmail()) %></span>
          <span class="adm-meta">Joined <%= a.getCreatedAt() == null ? "" : a.getCreatedAt().format(when) %></span></div>
        <form class="adm-acts" action="<%= ctx %>/admin/approvals" method="post">
          <input type="hidden" name="csrf" value="<%= Auth.esc(csrf) %>">
          <input type="hidden" name="accountId" value="<%= a.getId() %>">
          <button class="k-btn" type="submit" name="action" value="approve">Approve <span class="k-sr"><%= Auth.esc(a.getName()) %></span></button>
          <button class="k-btn k-btn--danger" type="submit" name="action" value="reject">Reject <span class="k-sr"><%= Auth.esc(a.getName()) %></span></button>
        </form>
      </li>
<%   } %>
    </ul>
<% } %>
  </main>
</div>
</body>
</html>
