<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Auth, com.gigmarket.gigs.Categories, com.gigmarket.gigs.Dates, com.gigmarket.gigs.GigStore, com.gigmarket.gigs.Pay, com.gigmarket.gigs.Statuses, com.gigmarket.model.Gig, java.time.LocalDate" %>
<%
    // Shown by GigServlet (GET /gig?id=…). Public. One gig up close; what it offers depends on who looks.
    Gig gig = (Gig) request.getAttribute("gig");
    String pageTitle = gig.getTitle() + " · campus.gig";
    String navCurrent = "gigs";
    GigStore.Applied applied = (GigStore.Applied) request.getAttribute("applied");
    boolean owner = Boolean.TRUE.equals(request.getAttribute("owner"));
    Integer applicationCount = (Integer) request.getAttribute("applicationCount");
    String role = (String) session.getAttribute("userRole");
    boolean open = "Open".equals(gig.getStatus());
    LocalDate today = LocalDate.now();
    String cat = Categories.colour(gig.getCategory());
    String category = gig.getCategory() == null ? "Other" : gig.getCategory();
    // Only fixed messages, picked by a short code from the apply step. Text from the URL is never shown.
    String code = request.getParameter("error");
    String applyError = "pitch".equals(code) ? "Write a few lines about why you fit this gig."
            : "long".equals(code) ? "Keep your pitch under 2,000 characters."
            : "size".equals(code) ? "That file is over 5 MB. Send a smaller PDF or image."
            : "type".equals(code) ? "Send a PDF or an image (PNG, JPG or WebP)."
            : "closed".equals(code) ? "This gig stopped taking applications before yours arrived."
            : "already".equals(code) ? "You have already applied for this gig." : null;
    boolean justApplied = "1".equals(request.getParameter("applied")) && applied != null;
    String applyBy = Dates.day(gig.getDeadline(), today);
    String doneBy = Dates.day(gig.getCompletionDeadline(), today);
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="auto">
<div class="page page--app" data-kit-plate>
<%@ include file="../jspf/app-nav.jspf" %>
  <main class="app-main">
    <a class="k-back" href="<%= ctx %>/browse-gigs">← All gigs</a>
    <div class="k-detail">
      <div class="k-detail__note">
        <div class="k-gig" data-cat="<%= cat %>" style="--k-tilt:-0.8deg">
          <span class="k-pin" aria-hidden="true"></span>
<% if (open && Dates.dueToday(gig.getDeadline(), today)) { %>
          <span class="k-gig__scribble">due tonight!</span>
<% } %>
          <div class="k-gig__top"><span class="k-chip" data-cat="<%= cat %>"><%= Auth.esc(category) %></span><span class="k-gig__price"><%= Pay.format(gig.getBudget()) %></span></div>
          <p class="k-gig__title"><%= Auth.esc(gig.getTitle()) %></p>
          <dl class="k-gig__facts">
<% if (gig.getWhenText() != null) { %><div><dt>When</dt><dd><%= Auth.esc(gig.getWhenText()) %></dd></div><% } %>
<% if (gig.getWhereText() != null) { %><div><dt>Where</dt><dd><%= Auth.esc(gig.getWhereText()) %></dd></div><% } %>
<% if (applyBy != null) { %><div><dt>Apply by</dt><dd><%= applyBy %></dd></div><% } %>
          </dl>
          <p class="k-gig__by">Posted by <%= Auth.esc(gig.getPosterName()) %></p>
        </div>
<% if (owner) { %>
        <div class="k-acts"><a class="k-btn" href="<%= ctx %>/review-applications?gigId=<%= gig.getGigId() %>"><%= open ? "Review applicants" : "See applicants" %> (<%= applicationCount %>)</a></div>
<% } else if (role == null && open) { %>
        <div class="k-acts"><a class="k-btn" href="<%= ctx %>/login.jsp">Log in to apply</a></div>
<% } %>
      </div>

      <div class="k-detail__main">
        <div class="k-head">
          <h1 class="k-head__title"><%= Auth.esc(gig.getTitle()) %></h1>
          <p class="k-head__lede"><%= Auth.esc(category) %> · posted by <%= Auth.esc(gig.getPosterName()) %><%= gig.getCreatedAt() != null ? " on " + Dates.posted(gig.getCreatedAt()) : "" %><%= open ? "" : " · " + Statuses.gig(gig.getStatus())[1].toLowerCase() %></p>
        </div>

        <dl class="k-facts-list">
          <div><dt>Pay</dt><dd><%= Pay.format(gig.getBudget()) %></dd></div>
<% if (gig.getWhenText() != null) { %>          <div><dt>When</dt><dd><%= Auth.esc(gig.getWhenText()) %></dd></div>
<% } if (gig.getWhereText() != null) { %>          <div><dt>Where</dt><dd><%= Auth.esc(gig.getWhereText()) %></dd></div>
<% } if (applyBy != null) { %>          <div><dt>Apply by</dt><dd><%= applyBy %></dd></div>
<% } if (doneBy != null) { %>          <div><dt>Done by</dt><dd><%= doneBy %></dd></div>
<% } %>
        </dl>

        <div class="k-prose"><h2>What needs doing</h2><p><%= Auth.esc(gig.getDescription()) %></p></div>

<% if ("student".equals(role)) {
     if (applied != null) { %>
        <div class="k-card gig-status" role="status">
          <div class="gig-status__line"><%= Statuses.badge(Statuses.student(applied.status, gig.getStatus())) %><span><%= justApplied ? "Application sent." : "You applied" %><%= applied.at != null ? " on " + Dates.posted(applied.at) + "." : "." %></span></div>
          <p><a href="<%= ctx %>/my-applications">See all your applications</a></p>
        </div>
<%   } else if (!open) { %>
        <div class="k-card gig-status"><p>This gig is no longer taking applications. <a href="<%= ctx %>/browse-gigs">See open gigs</a></p></div>
<%   } else { %>
        <form class="k-card apply-form" action="<%= ctx %>/apply-gig" method="post" enctype="multipart/form-data" style="--k-pin: var(--kit-color-category-2)">
          <span class="k-pin" aria-hidden="true"></span>
          <h2>Apply for this gig</h2>
<%     if (applyError != null) { %>
          <div class="k-card k-card--error" role="alert"><p class="k-card__body"><%= applyError %></p></div>
<%     } %>
          <input type="hidden" name="csrf" value="<%= Auth.csrfToken(request) %>">
          <input type="hidden" name="gigId" value="<%= gig.getGigId() %>">
          <div class="k-field"><label class="k-field__label" for="pitch">Why you?</label><textarea class="k-input" id="pitch" name="pitchText" rows="4" maxlength="2000" required aria-describedby="pitch-hint"></textarea><span class="k-field__help" id="pitch-hint">Two or three lines: what you have done that fits.</span></div>
          <div class="k-field"><label class="k-field__label" for="portfolio">Portfolio (optional)</label><input class="k-input" id="portfolio" type="file" name="portfolioFile" accept=".pdf,.png,.jpg,.jpeg,.webp" aria-describedby="portfolio-hint"><span class="k-field__help" id="portfolio-hint">PDF or image, up to 5 MB.</span></div>
          <button class="k-btn" type="submit">Send application</button>
        </form>
<%   }
   } %>
      </div>
    </div>
  </main>
</div>
</body>
</html>
