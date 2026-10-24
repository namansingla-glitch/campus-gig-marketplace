<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Auth, com.gigmarket.gigs.Rewards, com.gigmarket.gigs.Work, java.util.List" %>
<%
    // Shown by ProfileServlet (GET /profile). Students only. Real achievements and only the student's own standing.
    Work.Person person = (Work.Person) request.getAttribute("person");
    String pageTitle = "Your profile · campus.gig";
    String navCurrent = "profile";
    Rewards.Tier tier = (Rewards.Tier) request.getAttribute("tier");
    @SuppressWarnings("unchecked") List<Rewards.Achievement> achievements = (List<Rewards.Achievement>) request.getAttribute("achievements");
    int[] standing = (int[]) request.getAttribute("standing");
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="light">
<div class="page page--app" data-kit-plate>
<%@ include file="../jspf/app-nav.jspf" %>
  <main class="app-main">
    <div class="k-head"><h1 class="k-head__title"><%= Auth.esc(person.name) %></h1><p class="k-head__lede"><%= Auth.esc(person.email) %><%= person.university != null ? " · " + Auth.esc(person.university) : "" %></p></div>
    <div class="k-two">
      <section class="k-section" aria-labelledby="tier-h">
        <h2 class="k-section__title" id="tier-h">Your tier</h2>
<%@ include file="../jspf/tier.jspf" %>
        </div>
        <p class="k-count"><%= standing == null ? "Finish a gig this month to get a place in this month’s standings." : "You are #" + standing[0] + " of " + standing[1] + " students by points this month." %></p>
      </section>
      <section class="k-section" aria-labelledby="ach-h">
        <h2 class="k-section__title" id="ach-h">Achievements</h2>
<% for (Rewards.Achievement a : achievements) { %>
        <div class="k-achv" data-earned="<%= a.earned() %>"><span class="k-achv__mark" aria-hidden="true"><%= a.mark %></span><div><h3 class="k-achv__title"><%= a.title %></h3><p class="k-achv__note"><%= a.earned() ? "" : "Not yet. " %><%= a.note() %></p></div></div>
<% } %>
      </section>
    </div>
  </main>
</div>
</body>
</html>
