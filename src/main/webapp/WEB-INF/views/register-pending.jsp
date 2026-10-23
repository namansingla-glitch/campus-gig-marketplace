<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Auth" %>
<%
    // Shown by RegisterServlet after a faculty sign-up. The account waits for an admin.
    String pageTitle = "Almost there · campus.gig";
    String email = (String) request.getAttribute("pendingEmail");
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/auth.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="auto">
<div class="page auth">
  <header class="k-top">
    <a class="k-word" href="<%= ctx %>/">campus<span class="k-word__dot">.</span>gig</a>
  </header>

  <main class="k-card auth-note" style="--k-pin: var(--kit-color-category-3)">
    <span class="k-pin" aria-hidden="true"></span>
    <h1>Almost there</h1>
    <p class="sub">Your faculty account for <strong><%= Auth.esc(email) %></strong> is waiting for approval. You can log in once an admin approves it.</p>
    <a class="k-btn k-btn--ghost auth-back" href="<%= ctx %>/">Back to campus.gig</a>
  </main>
</div>
</body>
</html>
