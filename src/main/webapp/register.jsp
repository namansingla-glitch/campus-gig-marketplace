<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%!
    private static String esc(String s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String pageTitle = "Join · campus.gig";
    String err = request.getParameter("error");
%>
<%@ include file="WEB-INF/jspf/kit-head.jspf" %>
<link rel="stylesheet" href="css/auth.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="auto">
<div class="page auth">
  <header class="k-top">
    <a class="k-word" href="./">campus<span class="k-word__dot">.</span>gig</a>
  </header>

  <main class="k-card auth-note" style="--k-pin: var(--kit-color-category-2)">
    <span class="k-pin" aria-hidden="true"></span>
    <h1>Join campus.gig</h1>
    <p class="sub">Students pick paid gigs. Faculty pin them.</p>

<% if (err != null) { %>
    <div class="k-card k-card--error" role="alert"><p class="k-card__body"><%= esc(err) %></p></div>
<% } %>

    <form class="auth-form" action="register" method="post">
      <div class="k-field"><label class="k-field__label" for="name">Full name</label><input class="k-input" id="name" type="text" name="name" autocomplete="name" required></div>
      <div class="k-field"><label class="k-field__label" for="email">College email</label><input class="k-input" id="email" type="email" name="email" autocomplete="email" required placeholder="you@campus.edu"></div>
      <div class="k-field"><label class="k-field__label" for="password">Password</label><input class="k-input" id="password" type="password" name="password" autocomplete="new-password" required></div>
      <fieldset class="choice">
        <legend class="k-field__label">I want to</legend>
        <div class="choice__row">
          <span class="k-filter"><input type="radio" id="role-student" name="role" value="student" checked><label class="k-chip" data-cat="1" for="role-student">Pick gigs</label></span>
          <span class="k-filter"><input type="radio" id="role-faculty" name="role" value="poster"><label class="k-chip" data-cat="3" for="role-faculty">Pin gigs (faculty)</label></span>
        </div>
      </fieldset>
      <button class="k-btn" type="submit">Create account</button>
    </form>

    <p class="switch">Already joined? <a href="login.jsp">Log in</a></p>
  </main>
</div>
</body>
</html>
