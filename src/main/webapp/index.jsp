<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    String pageTitle = "campus.gig: free hour? pick a gig";
    String role = (String) session.getAttribute("userRole");
    boolean signedIn = role != null;
    String home = "poster".equals(role) ? "poster-dashboard.jsp" : "student-dashboard.jsp";
%>
<%@ include file="WEB-INF/jspf/kit-head.jspf" %>
<link rel="stylesheet" href="css/landing.css">
</head>
<body class="k-board" data-skin="campus-board" data-theme="auto">
<div class="page" data-kit-plate>

  <header class="k-top">
    <a class="k-word" href="./">campus<span class="k-word__dot">.</span>gig</a>
    <nav class="k-top__links" aria-label="Main">
      <a href="browse-gigs">Open gigs</a>
      <a href="#how">How it works</a>
    </nav>
    <div class="top-acts">
<% if (signedIn) { %>
      <a class="k-btn" href="<%= home %>">Your dashboard</a>
<% } else { %>
      <a class="k-btn k-btn--ghost" href="login.jsp">Log in</a>
      <a class="k-btn" href="register.jsp">Join</a>
<% } %>
    </div>
  </header>

  <main>
    <!-- SCENE 1 · HERO · one moment: the headline rises, the stamp lands -->
    <section class="s-hero" id="top" aria-labelledby="hero-h">
      <h1 id="hero-h" class="mix" data-kit-rise><span class="big">Free hour?</span> <span class="small">then</span> <span class="big">pick a gig.</span></h1>
      <p class="lede">Faculty pin small paid tasks to one board. You pick the one that fits between classes.</p>
      <div class="acts">
        <a class="k-btn" href="browse-gigs">See open gigs</a>
        <a class="k-btn k-btn--ghost" href="#how">How it works</a>
      </div>
      <div class="hero-pins">
        <div class="k-card wanted" style="--r:-2deg; --k-pin: var(--kit-color-category-3)"><span class="k-pin" aria-hidden="true"></span>
          <span class="wanted__label">Wanted · Sat 9 am</span>
          <p class="wanted__line">Invigilator for the mock test. <span class="nowrap">₹800</span></p>
          <span class="k-ex">example</span>
        </div>
        <div class="stamp" role="img" aria-label="Post, pick, get paid">
          <svg viewBox="0 0 168 168" aria-hidden="true"><g class="turn">
            <defs><path id="ringPath" d="M84,84 m-62,0 a62,62 0 1,1 124,0 a62,62 0 1,1 -124,0"/></defs>
            <circle class="ring" cx="84" cy="84" r="80"/><circle class="ring" cx="84" cy="84" r="44"/>
            <text><textPath href="#ringPath" startOffset="0" textLength="384" lengthAdjust="spacing">post · pick · get paid · </textPath></text>
            <circle class="pinhead" cx="84" cy="84" r="13"/><circle class="shine" cx="80" cy="80" r="4"/></g></svg>
        </div>
        <div class="k-card wanted" style="--r:1.5deg; --k-pin: var(--kit-color-category-1)"><span class="k-pin" aria-hidden="true"></span>
          <span class="wanted__label">Wanted · Tue &amp; Thu</span>
          <p class="wanted__line">Tutor first-years in C pointers. <span class="nowrap">₹350/hr</span></p>
          <span class="k-ex">example</span>
        </div>
      </div>
    </section>

    <!-- SCENE 2 · THE BOARD · one moment: notes pin onto the board as they scroll in -->
    <section class="scene" id="board" aria-labelledby="board-h">
      <div class="scene-head">
        <span class="kicker">On the board</span>
        <h2 id="board-h" class="mix mix-2"><span class="big">Small gigs,</span> <span class="small">all</span> <span class="big">on campus.</span></h2>
        <p class="ex-note">These three are examples of what faculty pin. <a href="browse-gigs">See the real open gigs</a>.</p>
      </div>
      <ul class="cats" aria-label="Categories">
        <li><span class="k-chip" data-cat="1">Tutoring</span></li>
        <li><span class="k-chip" data-cat="2">Design</span></li>
        <li><span class="k-chip" data-cat="3">Events</span></li>
        <li><span class="k-chip" data-cat="4">Coding</span></li>
      </ul>
      <div class="pinboard">
        <a class="k-gig drop" data-cat="1" href="browse-gigs" style="--r:-1.4deg">
          <span class="k-pin" aria-hidden="true"></span>
          <div class="k-gig__top"><span class="k-chip" data-cat="1">Tutoring</span><span class="k-gig__price">₹350<span class="k-gig__per">/hr</span></span></div>
          <h3 class="k-gig__title"><mark>Tutor first-years</mark> in C pointers</h3>
          <dl class="k-gig__facts"><div><dt>When</dt><dd>Tue &amp; Thu, 4–5 pm</dd></div><div><dt>Where</dt><dd>Library, 2nd floor</dd></div><div><dt>Apply by</dt><dd>Fri, 6 pm</dd></div></dl>
          <p class="k-gig__by">CS department · <span class="k-ex">example</span></p>
        </a>
        <a class="k-gig drop" data-cat="3" href="browse-gigs" style="--r:0.8deg">
          <span class="k-pin" aria-hidden="true"></span>
          <span class="k-gig__scribble">due tonight!</span>
          <div class="k-gig__top"><span class="k-chip" data-cat="3">Events</span><span class="k-gig__price">₹800</span></div>
          <h3 class="k-gig__title"><mark>Invigilate</mark> the Saturday mock test</h3>
          <dl class="k-gig__facts"><div><dt>When</dt><dd>Sat, 9 am–12 pm</dd></div><div><dt>Where</dt><dd>Block C, room 204</dd></div><div><dt>Apply by</dt><dd>Tonight, 11 pm</dd></div></dl>
          <p class="k-gig__by">Exam cell · <span class="k-ex">example</span></p>
        </a>
        <a class="k-gig drop" data-cat="2" href="browse-gigs" style="--r:-0.6deg">
          <span class="k-pin" aria-hidden="true"></span>
          <div class="k-gig__top"><span class="k-chip" data-cat="2">Design</span><span class="k-gig__price">₹1,500</span></div>
          <h3 class="k-gig__title"><mark>Poster</mark> for the robotics expo</h3>
          <dl class="k-gig__facts"><div><dt>When</dt><dd>Your time, 3 days</dd></div><div><dt>Where</dt><dd>Remote</dd></div><div><dt>Apply by</dt><dd>Mon, 5 pm</dd></div></dl>
          <p class="k-gig__by">Robotics club advisor · <span class="k-ex">example</span></p>
        </a>
      </div>
      <a class="k-btn k-btn--ghost board-more" href="browse-gigs">See all open gigs</a>
    </section>

    <!-- SCENE 3 · HOW A GIG MOVES · the note stays pinned while the steps pass -->
    <section class="scene" id="how" aria-labelledby="how-h">
      <div class="how">
        <div class="how-pinned">
          <div class="k-card"><span class="k-pin" aria-hidden="true"></span>
            <span class="kicker">How a gig moves</span>
            <p class="big-line" id="how-h">From a faculty note to money in a student's pocket, in three steps.</p>
          </div>
        </div>
        <ol class="steps">
          <li class="step k-blur-in"><span class="n" aria-hidden="true">1</span><div>
            <h3>Faculty pin a gig.</h3>
            <p>What needs doing, the pay in rupees, when, where, and the last time to apply.</p>
            <div class="who"><span class="k-chip">Faculty</span></div></div></li>
          <li class="step k-blur-in"><span class="n" aria-hidden="true">2</span><div>
            <h3>A student picks it.</h3>
            <p>Students browse the board and apply for a gig that fits their free hours. The faculty member chooses who does it.</p>
            <div class="who"><span class="k-chip">Student</span></div></div></li>
          <li class="step k-blur-in"><span class="n" aria-hidden="true">3</span><div>
            <h3>Done, and paid.</h3>
            <p>The student does the work. The faculty member marks it done and pays the agreed amount.</p>
            <div class="who"><span class="k-chip">Faculty</span><span class="k-chip">Student</span></div></div></li>
        </ol>
      </div>
    </section>

    <!-- SCENE 4 · ONE GIG UP CLOSE · the gig's category colour tints the scene -->
    <section class="scene s-detail" id="detail" aria-labelledby="detail-h">
      <div class="scene-head">
        <span class="kicker">One gig, up close</span>
        <h2 id="detail-h" class="mix mix-2"><span class="big">Poster</span> <span class="small">for the</span> <span class="big">robotics expo</span></h2>
      </div>
      <div class="detail">
        <div class="detail-note">
          <div class="k-gig" data-cat="2">
            <span class="k-pin" aria-hidden="true"></span>
            <div class="k-gig__top"><span class="k-chip" data-cat="2">Design</span><span class="k-gig__price">₹1,500</span></div>
            <h3 class="k-gig__title"><mark>Poster</mark> for the robotics expo</h3>
            <p class="k-gig__by">Robotics club advisor · <span class="k-ex">example</span></p>
            <div class="row">
<% if (signedIn) { %>
              <a class="k-btn" href="browse-gigs">Find a gig like this</a>
<% } else { %>
              <a class="k-btn" href="login.jsp">Log in to pick gigs</a>
<% } %>
            </div>
          </div>
        </div>
        <dl class="facts">
          <div class="fact k-blur-in"><dt>Pay</dt><dd>₹1,500<small>One payment when the poster is approved.</small></dd></div>
          <div class="fact k-blur-in"><dt>When</dt><dd>Your own time, 3 days<small>Draft by Thursday, final by Saturday.</small></dd></div>
          <div class="fact k-blur-in"><dt>Where</dt><dd>Remote<small>Hand over the files by email or a shared drive.</small></dd></div>
          <div class="fact k-blur-in"><dt>Apply by</dt><dd>Monday, 5 pm</dd></div>
        </dl>
      </div>
    </section>

    <!-- SCENE 5 · NUMBERS · one moment: Count Up. Every figure is an example until real data exists. -->
    <section class="scene" aria-labelledby="num-h">
      <div class="scene-head">
        <span class="kicker">The board so far</span>
        <h2 id="num-h" class="mix mix-2"><span class="big">Small gigs</span> <span class="small">add</span> <span class="big">up.</span></h2>
      </div>
      <div class="stats">
        <div class="k-stat"><span class="k-stat__num" data-count="38">38</span><span class="k-stat__what">Open gigs this week</span><div class="k-stat__foot"><span>Across 9 departments</span><span class="k-ex">example</span></div></div>
        <div class="k-stat"><span class="k-stat__num" data-count="124500" data-rupee>₹1,24,500</span><span class="k-stat__what">Paid to students</span><div class="k-stat__foot"><span>Since 1 Aug</span><span class="k-ex">example</span></div></div>
        <div class="k-stat"><span class="k-stat__num" data-count="27">27</span><span class="k-stat__what">Faculty posting</span><div class="k-stat__foot"><span>This semester</span><span class="k-ex">example</span></div></div>
      </div>
    </section>
  </main>

  <footer class="foot">
    <div class="foot-line"><span>Faculty post. Students pick.</span><span><% if (signedIn) { %><a href="logout">Log out</a><% } else { %><a href="login.jsp">Log in</a> · <a href="register.jsp">Join</a><% } %></span></div>
    <p class="giant">campus<span>.</span>gig</p>
  </footer>
</div>
</body>
</html>
