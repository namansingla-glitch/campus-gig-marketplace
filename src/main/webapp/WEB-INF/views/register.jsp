<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Auth, com.gigmarket.auth.University, java.util.List" %>
<%
    // Shown by RegisterServlet (GET /register, and POST /register with an error).
    String pageTitle = "Join · campus.gig";
    @SuppressWarnings("unchecked")
    List<University> unis = (List<University>) request.getAttribute("universities");
    String errField = (String) request.getAttribute("errorField");
    String errMsg = (String) request.getAttribute("errorMessage");
    String vName = (String) request.getAttribute("valueName");
    String vEmail = (String) request.getAttribute("valueEmail");
    String vUni = (String) request.getAttribute("valueUniversity");
    boolean oneUni = unis != null && unis.size() == 1;
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/auth.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="light">
<div class="page auth">
  <header class="k-top">
    <a class="k-word" href="<%= ctx %>/">campus<span class="k-word__dot">.</span>gig</a>
  </header>

  <main class="k-card auth-note" style="--k-pin: var(--kit-color-category-2)">
    <span class="k-pin" aria-hidden="true"></span>
    <h1>Join campus.gig</h1>
    <p class="sub">Students pick paid gigs. Faculty pin them.</p>

    <form class="auth-form" action="<%= ctx %>/register" method="post" novalidate>
      <div class="k-field<%= "university".equals(errField) ? " k-field--error" : "" %>">
        <label class="k-field__label" for="university">University</label>
        <select class="k-input" id="university" name="university" required aria-describedby="university-hint"<%= "university".equals(errField) ? " aria-invalid=\"true\"" : "" %>>
<% if (!oneUni) { %>
          <option value="">Choose your university</option>
<% } %>
<% if (unis != null) for (University u : unis) {
       boolean sel = oneUni || String.valueOf(u.getId()).equals(vUni); %>
          <option value="<%= u.getId() %>"<%= sel ? " selected" : "" %>><%= Auth.esc(u.getName()) %></option>
<% } %>
        </select>
        <span class="k-field__help" id="university-hint"><%= "university".equals(errField) ? Auth.esc(errMsg) : (oneUni ? "More universities soon." : "Pick the one whose email you use.") %></span>
      </div>

      <div class="k-field<%= "name".equals(errField) ? " k-field--error" : "" %>">
        <label class="k-field__label" for="name">Full name</label>
        <input class="k-input" id="name" type="text" name="name" autocomplete="name" required maxlength="100" value="<%= Auth.esc(vName) %>"<%= "name".equals(errField) ? " aria-invalid=\"true\" aria-describedby=\"name-hint\"" : "" %>>
<% if ("name".equals(errField)) { %>
        <span class="k-field__help" id="name-hint"><%= Auth.esc(errMsg) %></span>
<% } %>
      </div>

      <div class="k-field<%= "email".equals(errField) ? " k-field--error" : "" %>">
        <label class="k-field__label" for="email">University email</label>
        <input class="k-input" id="email" type="email" name="email" autocomplete="email" required maxlength="100" placeholder="you@woxsen.edu.in" value="<%= Auth.esc(vEmail) %>" aria-describedby="email-hint"<%= "email".equals(errField) ? " aria-invalid=\"true\"" : "" %>>
        <span class="k-field__help" id="email-hint"><%= "email".equals(errField) ? Auth.esc(errMsg) : "Students: @woxsen.edu.in · Faculty: @faculty.woxsen.com" %></span>
      </div>

      <div class="k-field<%= "password".equals(errField) ? " k-field--error" : "" %>">
        <label class="k-field__label" for="password">Password</label>
        <input class="k-input" id="password" type="password" name="password" autocomplete="new-password" required minlength="6" aria-describedby="password-hint"<%= "password".equals(errField) ? " aria-invalid=\"true\"" : "" %>>
        <span class="k-field__help" id="password-hint"><%= "password".equals(errField) ? Auth.esc(errMsg) : "At least 6 characters." %></span>
      </div>

      <button class="k-btn" type="submit">Create account</button>
    </form>

    <p class="switch">Already joined? <a href="<%= ctx %>/login.jsp">Log in</a></p>
  </main>
</div>
</body>
</html>
