<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.gigmarket.auth.Auth, com.gigmarket.gigs.Categories, com.gigmarket.gigs.GigForm, java.time.LocalDate, java.util.Map" %>
<%!
    // One kit text field. Every value and message is escaped; the error replaces the help text and is linked by aria-describedby.
    static String field(GigForm f, String id, String label, String help, String type, String extra) {
        String err = f.errors.get(id);
        String hint = err != null ? err : help;
        StringBuilder b = new StringBuilder("<div class=\"k-field").append(err != null ? " k-field--error" : "").append("\">");
        b.append("<label class=\"k-field__label\" for=\"").append(id).append("\">").append(label).append("</label>");
        boolean rupees = "pay".equals(id);
        if (rupees) b.append("<div class=\"k-input-wrap\"><span class=\"k-input-wrap__prefix\" aria-hidden=\"true\">₹</span>");
        b.append("<input class=\"k-input\" id=\"").append(id).append("\" name=\"").append(id).append("\" type=\"").append(type).append("\"")
         .append(" value=\"").append(Auth.esc(f.typed.get(id))).append("\"").append(extra);
        if (hint != null) b.append(" aria-describedby=\"").append(id).append("-hint\"");
        if (err != null) b.append(" aria-invalid=\"true\"");
        b.append(">");
        if (rupees) b.append("</div>");
        if (hint != null) b.append("<span class=\"k-field__help\" id=\"").append(id).append("-hint\">").append(Auth.esc(hint)).append("</span>");
        return b.append("</div>").toString();
    }
%>
<%
    // Shown by PostGigServlet (GET /post-gig, and again with problems after a POST). Faculty only.
    String pageTitle = "Post a gig · campus.gig";
    String navCurrent = "post";
    GigForm form = (GigForm) request.getAttribute("form");
    String today = LocalDate.now().toString();
    String catErr = form.errors.get("category");
    String descErr = form.errors.get("description");
%>
<%@ include file="../jspf/kit-head.jspf" %>
<link rel="stylesheet" href="<%= ctx %>/css/app.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="auto">
<div class="page page--app" data-kit-plate>
<%@ include file="../jspf/app-nav.jspf" %>
  <main class="app-main">
    <a class="k-back" href="<%= ctx %>/your-gigs">← Your gigs</a>
    <div class="k-head"><h1 class="k-head__title">Post a gig</h1><p class="k-head__lede">Students see it on the board right away.</p></div>

    <form class="k-form" action="<%= ctx %>/post-gig" method="post" novalidate>
<% if (!form.errors.isEmpty()) { %>
      <div class="k-form__summary" role="alert" tabindex="-1" id="problems"><h2><%= GigForm.summaryTitle(form.errors.size()) %></h2><ul>
<%   for (Map.Entry<String, String> e : form.errors.entrySet()) { %>
        <li><a href="#<%= e.getKey() %>"><%= Auth.esc(e.getValue()) %></a></li>
<%   } %>
      </ul></div>
<% } %>
      <input type="hidden" name="csrf" value="<%= Auth.csrfToken(request) %>">
      <fieldset class="k-form__group"><legend>The gig</legend>
        <%= field(form, "title", "Title", "One line. Say what you need done.", "text", " maxlength=\"200\" required") %>
        <div class="k-field<%= catErr != null ? " k-field--error" : "" %>"><label class="k-field__label" for="category">Category</label><select class="k-input" id="category" name="category" required<%= catErr != null ? " aria-invalid=\"true\" aria-describedby=\"category-hint\"" : "" %>>
          <option value=""<%= form.typed.get("category").isEmpty() ? " selected" : "" %>>Choose one</option>
<% for (String c : Categories.ALL) { %>
          <option value="<%= c %>"<%= c.equals(form.typed.get("category")) ? " selected" : "" %>><%= c %></option>
<% } %>
        </select><% if (catErr != null) { %><span class="k-field__help" id="category-hint"><%= Auth.esc(catErr) %></span><% } %></div>
        <div class="k-field<%= descErr != null ? " k-field--error" : "" %>"><label class="k-field__label" for="description">What needs doing</label><textarea class="k-input" id="description" name="description" rows="5" maxlength="4000" required aria-describedby="description-hint"<%= descErr != null ? " aria-invalid=\"true\"" : "" %>><%= Auth.esc(form.typed.get("description")) %></textarea><span class="k-field__help" id="description-hint"><%= descErr != null ? Auth.esc(descErr) : "What the student will do, and anything they should bring or know." %></span></div>
      </fieldset>
      <fieldset class="k-form__group"><legend>Pay and time</legend>
        <div class="k-form__cols">
          <%= field(form, "pay", "Pay", "The whole amount, in rupees.", "text", " inputmode=\"numeric\" required") %>
          <%= field(form, "when", "When", "For example “Sat, 9 am–12 pm”.", "text", " maxlength=\"120\" required") %>
          <%= field(form, "where", "Where", "A room, or “Remote”.", "text", " maxlength=\"120\" required") %>
          <%= field(form, "applyBy", "Apply by (optional)", null, "date", " min=\"" + today + "\"") %>
          <%= field(form, "doneBy", "Done by (optional)", null, "date", " min=\"" + today + "\"") %>
        </div>
      </fieldset>
      <div class="k-form__acts"><button class="k-btn" type="submit">Pin the gig</button><a class="k-btn k-btn--ghost" href="<%= ctx %>/your-gigs">Cancel</a></div>
    </form>
  </main>
</div>
</body>
</html>
