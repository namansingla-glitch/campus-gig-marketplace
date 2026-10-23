<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%!
    private static String esc(String s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String pageTitle = "Log in · campus.gig";
    String err = request.getParameter("error");
    String msg = request.getParameter("message");
%>
<%@ include file="WEB-INF/jspf/kit-head.jspf" %>
<link rel="stylesheet" href="css/auth.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="auto">
<div class="page auth">
  <header class="k-top">
    <a class="k-word" href="./">campus<span class="k-word__dot">.</span>gig</a>
  </header>

  <main class="k-card auth-note" style="--k-pin: var(--kit-color-category-1)">
    <span class="k-pin" aria-hidden="true"></span>
    <h1>Log in</h1>
    <p class="sub">Pick up a gig, or pin one if you teach.</p>

<% if (err != null) { %>
    <div class="k-card k-card--error" role="alert"><p class="k-card__body"><%= esc(err) %></p></div>
<% } %>
<% if (msg != null) { %>
    <div class="k-card" role="status"><p class="k-card__body"><%= esc(msg) %></p></div>
<% } %>

    <form class="auth-form" action="login" method="post">
      <div class="k-field"><label class="k-field__label" for="email">College email</label><input class="k-input" id="email" type="email" name="email" autocomplete="email" required placeholder="you@campus.edu"></div>
      <div class="k-field"><label class="k-field__label" for="password">Password</label><input class="k-input" id="password" type="password" name="password" autocomplete="current-password" required></div>
      <fieldset class="choice">
        <legend class="k-field__label">I am</legend>
        <div class="choice__row">
          <span class="k-filter"><input type="radio" id="role-student" name="role" value="student" checked><label class="k-chip" data-cat="1" for="role-student">A student</label></span>
          <span class="k-filter"><input type="radio" id="role-faculty" name="role" value="poster"><label class="k-chip" data-cat="3" for="role-faculty">Faculty</label></span>
        </div>
      </fieldset>
      <button class="k-btn" type="submit">Log in</button>
    </form>

    <p class="switch">New here? <a href="register.jsp">Join campus.gig</a></p>
  </main>

  <aside class="demo" aria-labelledby="demo-h">
    <p><strong id="demo-h">Demo accounts</strong> <span class="k-ex">demo only</span></p>
    <p>Student: <code>naman@campus.edu</code> · Faculty: <code>riddhi@campus.edu</code> · Password: <code>password123</code></p>
  </aside>
</div>
</body>
</html>
