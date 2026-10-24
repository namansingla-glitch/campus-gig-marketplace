<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    String pageTitle = "Log in · campus.gig";
    // Only fixed messages, picked by a short code. Text from the URL is never shown.
    String code = request.getParameter("error");
    String error = null, note = null;
    if ("invalid".equals(code)) error = "That email and password don't match. Check both and try again.";
    else if ("pending".equals(code)) error = "Your faculty account is waiting for approval. You can log in once an admin approves it.";
    else if ("rejected".equals(code)) error = "This faculty account was not approved. If that's a mistake, ask the campus.gig admin.";
    else if ("login".equals(code)) note = "Log in to continue.";
    else if ("out".equals(code)) note = "You're logged out.";
%>
<%@ include file="WEB-INF/jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/auth.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="light">
<div class="page auth">
  <header class="k-top">
    <a class="k-word" href="<%= ctx %>/">campus<span class="k-word__dot">.</span>gig</a>
  </header>

  <main class="k-card auth-note" style="--k-pin: var(--kit-color-category-1)">
    <span class="k-pin" aria-hidden="true"></span>
    <h1>Log in</h1>
    <p class="sub">Pick up a gig, or pin one if you teach.</p>

<% if (error != null) { %>
    <div class="k-card k-card--error" role="alert"><p class="k-card__body"><%= error %></p></div>
<% } %>
<% if (note != null) { %>
    <div class="k-card" role="status"><p class="k-card__body"><%= note %></p></div>
<% } %>

    <form class="auth-form" action="<%= ctx %>/login" method="post">
      <div class="k-field"><label class="k-field__label" for="email">University email</label><input class="k-input" id="email" type="email" name="email" autocomplete="email" required placeholder="you@woxsen.edu.in"></div>
      <div class="k-field"><label class="k-field__label" for="password">Password</label><input class="k-input" id="password" type="password" name="password" autocomplete="current-password" required></div>
      <button class="k-btn" type="submit">Log in</button>
    </form>

    <p class="switch">New here? <a href="<%= ctx %>/register">Join campus.gig</a></p>
  </main>

  <aside class="demo" aria-labelledby="demo-h">
    <p><strong id="demo-h">Demo accounts</strong> <span class="k-ex">demo only</span></p>
    <p>Student: <code>naman@woxsen.edu.in</code> · Faculty: <code>riddhi@faculty.woxsen.com</code> · Password: <code>password123</code></p>
  </aside>
</div>
</body>
</html>
