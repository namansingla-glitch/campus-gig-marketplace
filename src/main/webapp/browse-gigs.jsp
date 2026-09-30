<%@ page import="java.sql.*, com.gigmarket.util.DatabaseUtil, java.util.List, com.gigmarket.model.Gig, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    String role = (String) session.getAttribute("userRole");
    List<Gig> gigs = (List<Gig>) request.getAttribute("gigs");
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM");
%>
<jsp:include page="header.jsp" />

<div class="mb-10 text-center">
    <h1 class="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight mb-2">Explore Gigs</h1>
    <p class="text-lg text-slate-500">Discover paid micro-tasks and projects across campus.</p>
</div>

<div class="flex flex-col lg:flex-row gap-8">
    
    <!-- Filters Sidebar -->
    <div class="w-full lg:w-72 shrink-0">
        <form action="browse-gigs" method="GET" class="glass-card p-6 sticky top-28">
            <h3 class="font-bold text-slate-900 mb-6">Filters</h3>
            
            <div class="mb-5">
                <label class="block text-sm font-semibold text-slate-700 mb-2">Category</label>
                <select name="category" class="w-full bg-white border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow shadow-sm">
                    <option value="">All Categories</option>
                    <option value="Tutoring" <%= "Tutoring".equals(request.getParameter("category")) ? "selected" : "" %>>Tutoring</option>
                    <option value="Design" <%= "Design".equals(request.getParameter("category")) ? "selected" : "" %>>Design</option>
                    <option value="Development" <%= "Development".equals(request.getParameter("category")) ? "selected" : "" %>>Development</option>
                    <option value="Writing" <%= "Writing".equals(request.getParameter("category")) ? "selected" : "" %>>Writing</option>
                    <option value="Event Support" <%= "Event Support".equals(request.getParameter("category")) ? "selected" : "" %>>Event Support</option>
                </select>
            </div>
            
            <div class="mb-6">
                <label class="block text-sm font-semibold text-slate-700 mb-2">Minimum Budget (&#8377;)</label>
                <input type="number" name="minBudget" value="<%= request.getParameter("minBudget") != null ? request.getParameter("minBudget").replace("\"", "&quot;") : "" %>" placeholder="e.g. 500" class="w-full bg-white border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow shadow-sm">
            </div>
            
            <button type="submit" class="w-full btn-primary py-2.5 rounded-xl font-semibold shadow-md">Apply Filters</button>
            <a href="browse-gigs" class="block text-center w-full mt-3 text-sm font-medium text-slate-500 hover:text-slate-800 transition-colors">Clear Filters</a>
        </form>
    </div>

    <!-- Gigs Grid -->
    <div class="flex-1">
        
        <!-- Search bar top (Dummy functionality for aesthetics) -->
        <div class="relative mb-6">
            <input type="text" placeholder="Search gigs, skills or categories..." class="w-full bg-white/80 backdrop-blur border border-slate-200 rounded-2xl pl-12 pr-4 py-3.5 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow shadow-sm">
            <svg class="w-5 h-5 text-slate-400 absolute left-4 top-1/2 -translate-y-1/2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
        </div>

        <% if (gigs != null && !gigs.isEmpty()) { %>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <% for (Gig gig : gigs) { 
                    double bdg = gig.getBudget().doubleValue();
                    String bdgStr = (bdg == Math.floor(bdg)) ? String.format("%,.0f", bdg) : String.format("%,.2f", bdg);
                %>
                <div class="glass-card p-6 flex flex-col justify-between group h-full">
                    <div>
                        <div class="flex justify-between items-start mb-4">
                            <span class="inline-block px-2.5 py-1 bg-slate-100 text-slate-600 text-[10px] font-bold rounded uppercase tracking-wider"><%= gig.getCategory() %></span>
                            <span class="text-xs font-semibold text-slate-400 flex items-center gap-1">
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                                Posted recently
                            </span>
                        </div>
                        <h2 class="text-xl font-bold text-slate-900 mb-2 group-hover:text-blue-600 transition-colors leading-tight"><%= gig.getTitle() %></h2>
                        <p class="text-sm text-slate-600 line-clamp-2 mb-6 leading-relaxed"><%= gig.getDescription() %></p>
                    </div>
                    
                    <div class="mt-auto border-t border-slate-100 pt-5">
                        <div class="flex items-center justify-between mb-5">
                            <div>
                                <span class="text-2xl font-extrabold text-slate-900 tracking-tight">&#8377;<%= bdgStr %></span>
                            </div>
                            <div class="text-right">
                                <p class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-0.5">Timeline</p>
                                <p class="text-sm font-bold text-slate-700">
                                    <% if(gig.getDeadline() != null) { %>
                                        <%= sdf.format(gig.getDeadline()) %>
                                    <% } else { %>
                                        Flexible
                                    <% } %>
                                </p>
                            </div>
                        </div>
                        
                        <% if ("student".equals(role)) { %>
                            <a href="apply-gig.jsp?gigId=<%= gig.getGigId() %>&title=<%= java.net.URLEncoder.encode(gig.getTitle(), "UTF-8") %>" class="btn-primary block w-full text-center py-2.5 rounded-xl font-semibold shadow-md">View Gig</a>
                        <% } else { %>
                            <button disabled class="w-full py-2.5 bg-slate-100 text-slate-400 rounded-xl text-sm font-semibold cursor-not-allowed border border-slate-200">Log in as Student to Apply</button>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="glass-card p-16 text-center flex flex-col items-center justify-center">
                <div class="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-6 shadow-inner">
                    <svg class="w-10 h-10 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                </div>
                <h2 class="text-xl font-bold text-slate-900 mb-2">No gigs found</h2>
                <p class="text-slate-500 mb-6">Try adjusting your filters or check back later.</p>
                <a href="browse-gigs" class="btn-secondary px-6 py-2.5 rounded-full font-semibold shadow-sm">Clear Filters</a>
            </div>
        <% } %>
    </div>
</div>

<jsp:include page="footer.jsp" />
