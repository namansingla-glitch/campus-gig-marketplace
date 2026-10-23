<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Auth, com.gigmarket.gigs.Categories, com.gigmarket.gigs.Dates, com.gigmarket.gigs.Pay, com.gigmarket.model.Gig, java.time.LocalDate, java.util.List" %>
<%
    // Shown by BrowseGigsServlet (GET /browse-gigs). Public. No story layer: a repeat-use screen (GUIDELINES §1).
    String pageTitle = "Open gigs · campus.gig";
    String navCurrent = "gigs";
    @SuppressWarnings("unchecked") List<Gig> gigs = (List<Gig>) request.getAttribute("gigs");
    @SuppressWarnings("unchecked") List<String> chosen = (List<String>) request.getAttribute("chosen");
    String minPayTyped = (String) request.getAttribute("minPayTyped");
    String minPayError = (String) request.getAttribute("minPayError");
    boolean filtered = !chosen.isEmpty() || (minPayTyped != null && !minPayTyped.trim().isEmpty());
    LocalDate today = LocalDate.now();
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="auto">
<div class="page page--app" data-kit-plate>
<%@ include file="../jspf/app-nav.jspf" %>
  <main class="app-main">
    <div class="k-head"><h1 class="k-head__title">Open gigs</h1><p class="k-head__lede">Paid tasks from Woxsen faculty. Pick one that fits your week.</p></div>

    <form class="k-filters" action="<%= ctx %>/browse-gigs" method="get" aria-label="Filter gigs">
      <fieldset class="k-filters__group"><legend class="k-field__label">Category</legend><div class="k-filters__chips">
<% int ci = 0; for (String c : Categories.ALL) { %>
        <span class="k-filter"><input type="checkbox" id="fc-<%= ci %>" name="category" value="<%= c %>"<%= chosen.contains(c) ? " checked" : "" %>><label class="k-chip" data-cat="<%= Categories.colour(c) %>" for="fc-<%= ci %>"><%= c %></label></span>
<% ci++; } %>
      </div></fieldset>
      <div class="k-field<%= minPayError != null ? " k-field--error" : "" %>">
        <label class="k-field__label" for="fc-min">Pay at least</label>
        <div class="k-input-wrap"><span class="k-input-wrap__prefix" aria-hidden="true">₹</span><input class="k-input" id="fc-min" type="text" inputmode="numeric" name="minPay" value="<%= Auth.esc(minPayTyped) %>" aria-describedby="fc-min-hint"<%= minPayError != null ? " aria-invalid=\"true\"" : "" %>></div>
        <span class="k-field__help" id="fc-min-hint"><%= minPayError != null ? Auth.esc(minPayError) : "Leave empty for any pay." %></span>
      </div>
      <div class="k-filters__acts"><button class="k-btn" type="submit">Show gigs</button><a class="k-filters__clear" href="<%= ctx %>/browse-gigs">Clear</a></div>
    </form>

<% if (gigs.isEmpty()) { %>
    <div class="k-card k-card--empty">
      <h2 class="k-card__title"><%= filtered ? "No open gigs match" : "No open gigs yet" %></h2>
      <p class="k-card__body"><% if (filtered) { %>Try more categories or a lower pay. <a href="<%= ctx %>/browse-gigs">Show all open gigs</a><% } else { %>New gigs from faculty show up here.<% } %></p>
    </div>
<% } else { %>
    <h2 class="k-count">Showing <%= gigs.size() %> open gig<%= gigs.size() == 1 ? "" : "s" %></h2>
    <div class="k-gig-grid">
<%   int n = 0; for (Gig g : gigs) {
         String cat = Categories.colour(g.getCategory());
         String tilt = new String[] {"-1.2", "0.8", "-0.6", "0.9", "-0.9"}[n++ % 5];
         String applyBy = Dates.day(g.getDeadline(), today); %>
      <a class="k-gig" data-cat="<%= cat %>" href="<%= ctx %>/gig?id=<%= g.getGigId() %>" style="--k-tilt:<%= tilt %>deg">
        <span class="k-pin" aria-hidden="true"></span>
<%     if (Dates.dueToday(g.getDeadline(), today)) { %>
        <span class="k-gig__scribble">due tonight!</span>
<%     } %>
        <div class="k-gig__top"><span class="k-chip" data-cat="<%= cat %>"><%= Auth.esc(g.getCategory() == null ? "Other" : g.getCategory()) %></span><span class="k-gig__price"><%= Pay.format(g.getBudget()) %></span></div>
        <h3 class="k-gig__title"><%= Auth.esc(g.getTitle()) %></h3>
        <dl class="k-gig__facts">
<%     if (g.getWhenText() != null) { %><div><dt>When</dt><dd><%= Auth.esc(g.getWhenText()) %></dd></div><% } %>
<%     if (g.getWhereText() != null) { %><div><dt>Where</dt><dd><%= Auth.esc(g.getWhereText()) %></dd></div><% } %>
<%     if (applyBy != null) { %><div><dt>Apply by</dt><dd><%= applyBy %></dd></div><% } %>
        </dl>
        <p class="k-gig__by">Posted by <%= Auth.esc(g.getPosterName()) %><%= g.getCreatedAt() != null ? " · " + Dates.posted(g.getCreatedAt()) : "" %></p>
      </a>
<%   } %>
    </div>
<% } %>
  </main>
</div>
</body>
</html>
