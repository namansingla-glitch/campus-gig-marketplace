<%@ page import="java.sql.*, com.gigmarket.util.DatabaseUtil" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"poster".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userName = (String) session.getAttribute("userName");

    int activeGigs = 0, totalApps = 0, hired = 0, completed = 0;

    try (Connection conn = DatabaseUtil.getConnection()) {
        PreparedStatement p1 = conn.prepareStatement("SELECT COUNT(*) FROM Gigs WHERE poster_id = ? AND status = 'Open'");
        p1.setInt(1, userId);
        ResultSet r1 = p1.executeQuery();
        if(r1.next()) activeGigs = r1.getInt(1);

        PreparedStatement p2 = conn.prepareStatement("SELECT COUNT(*) FROM Applications a JOIN Gigs g ON a.gig_id = g.gig_id WHERE g.poster_id = ?");
        p2.setInt(1, userId);
        ResultSet r2 = p2.executeQuery();
        if(r2.next()) totalApps = r2.getInt(1);

        PreparedStatement p3 = conn.prepareStatement("SELECT COUNT(*) FROM Applications a JOIN Gigs g ON a.gig_id = g.gig_id WHERE g.poster_id = ? AND a.status = 'Hired' AND g.status != 'Closed'");
        p3.setInt(1, userId);
        ResultSet r3 = p3.executeQuery();
        if(r3.next()) hired = r3.getInt(1);
        
        PreparedStatement p4 = conn.prepareStatement("SELECT COUNT(*) FROM Gigs WHERE poster_id = ? AND status = 'Closed'");
        p4.setInt(1, userId);
        ResultSet r4 = p4.executeQuery();
        if(r4.next()) completed = r4.getInt(1);
    } catch (Exception e) {}
%>
<jsp:include page="header.jsp" />

<div class="mb-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
    <div>
        <h1 class="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">Poster Dashboard</h1>
        <p class="text-slate-500 mt-2 text-lg">Manage your campus gigs and applicants.</p>
    </div>
    <a href="post-gig.jsp" class="btn-primary px-6 py-3 rounded-full text-sm font-semibold shadow-md flex items-center gap-2 shrink-0 hover:shadow-lg transition-all">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
        Create New Gig
    </a>
</div>

<!-- Top Metrics -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
    <!-- Active Gigs -->
    <div class="glass-card p-6">
        <div class="flex items-start justify-between">
            <div>
                <p class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Active Gigs</p>
                <div class="text-4xl font-extrabold text-slate-900"><%= activeGigs %></div>
            </div>
            <div class="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg>
            </div>
        </div>
        <p class="text-sm font-medium text-slate-500 mt-4">&uarr; 2 this week</p>
    </div>
    
    <!-- Total Applications -->
    <div class="glass-card p-6">
        <div class="flex items-start justify-between">
            <div>
                <p class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Total Applications</p>
                <div class="text-4xl font-extrabold text-slate-900"><%= totalApps %></div>
            </div>
            <div class="w-12 h-12 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
            </div>
        </div>
        <p class="text-sm font-medium text-slate-500 mt-4">Across all your gigs</p>
    </div>
    
    <!-- Hired Students -->
    <div class="glass-card p-6">
        <div class="flex items-start justify-between">
            <div>
                <p class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Hired Students</p>
                <div class="text-4xl font-extrabold text-slate-900"><%= hired %></div>
            </div>
            <div class="w-12 h-12 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>
            </div>
        </div>
        <p class="text-sm font-medium text-slate-500 mt-4">Currently working</p>
    </div>
    
    <!-- Completed Gigs -->
    <div class="glass-card p-6 bg-gradient-to-br from-blue-600 to-indigo-600 border-none shadow-blue-500/20 text-white relative overflow-hidden">
        <div class="absolute -right-8 -top-8 w-32 h-32 bg-white/10 rounded-full blur-2xl"></div>
        <div class="relative z-10 flex items-start justify-between">
            <div>
                <p class="text-xs font-bold text-white/70 uppercase tracking-wider mb-2">Completed</p>
                <div class="text-4xl font-extrabold"><%= completed %></div>
            </div>
            <div class="w-12 h-12 rounded-xl bg-white/20 text-white flex items-center justify-center backdrop-blur-sm">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
            </div>
        </div>
        <p class="text-sm font-medium text-white/80 mt-4 relative z-10">Successfully delivered</p>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
    <div class="lg:col-span-2 space-y-8">
        <div class="glass-card overflow-hidden">
            <div class="p-6 border-b border-slate-100 flex justify-between items-center bg-white/50">
                <h2 class="text-lg font-bold text-slate-900 tracking-tight">Recent Gigs Overview</h2>
                <a href="#" class="text-sm font-semibold text-blue-600 hover:text-blue-800">View All</a>
            </div>
            <%
                try (Connection conn = DatabaseUtil.getConnection()) {
                    PreparedStatement stmt = conn.prepareStatement("SELECT * FROM Gigs WHERE poster_id = ? ORDER BY created_at DESC LIMIT 5");
                    stmt.setInt(1, userId);
                    ResultSet rs = stmt.executeQuery();
                    boolean hasGigs = false;
            %>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="bg-slate-50/80 text-slate-500 font-semibold border-b border-slate-100">
                        <tr>
                            <th class="px-6 py-4">Gig Title</th>
                            <th class="px-6 py-4">Budget</th>
                            <th class="px-6 py-4">Status</th>
                            <th class="px-6 py-4 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50">
                <%
                        while(rs.next()) {
                            hasGigs = true;
                            String status = rs.getString("status");
                            String statusColor = "Open".equals(status) ? "bg-blue-50 text-blue-700 border-blue-200" : "bg-slate-100 text-slate-700 border-slate-200";
                            double bdg = rs.getDouble("budget");
                            String bdgStr = (bdg == Math.floor(bdg)) ? String.format("%,.0f", bdg) : String.format("%,.2f", bdg);
                %>
                        <tr class="hover:bg-slate-50/50 transition-colors">
                            <td class="px-6 py-5">
                                <div class="font-bold text-slate-900"><%= rs.getString("title") %></div>
                                <div class="text-xs font-medium text-slate-500 mt-1"><%= rs.getString("category") %></div>
                            </td>
                            <td class="px-6 py-5 font-semibold text-slate-700">&#8377;<%= bdgStr %></td>
                            <td class="px-6 py-5">
                                <span class="inline-flex items-center rounded-full px-2.5 py-1 text-xs font-bold border <%= statusColor %> tracking-wide uppercase"><%= status %></span>
                            </td>
                            <td class="px-6 py-5 text-right">
                                <a href="review-applications?gigId=<%= rs.getInt("gig_id") %>" class="inline-flex items-center gap-1.5 text-blue-700 hover:text-white font-semibold bg-blue-50 hover:bg-blue-600 px-4 py-2 rounded-full transition-colors shadow-sm">
                                    Review <span class="hidden sm:inline">Applicants</span>
                                </a>
                            </td>
                        </tr>
                <%
                        }
                        if(!hasGigs) {
                %>
                        <tr>
                            <td colspan="4" class="px-6 py-16 text-center text-slate-500">
                                <div class="flex flex-col items-center justify-center">
                                    <div class="w-16 h-16 rounded-full bg-slate-100 flex items-center justify-center mb-4">
                                        <svg class="w-8 h-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path></svg>
                                    </div>
                                    <p class="font-medium text-slate-600 mb-2">No active gigs yet.</p>
                                    <a href="post-gig.jsp" class="text-blue-600 font-semibold hover:underline">Post your first gig &rarr;</a>
                                </div>
                            </td>
                        </tr>
                <%
                        }
                %>
                    </tbody>
                </table>
            </div>
            <% } catch (Exception e) {} %>
        </div>
    </div>
    
    <div class="space-y-8">
        <!-- AI Insights (Dummy) -->
        <div class="glass-card p-6 border-t-4 border-t-indigo-500">
            <div class="flex items-center gap-3 mb-5">
                <div class="w-8 h-8 rounded-full bg-indigo-50 text-indigo-600 flex items-center justify-center">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                </div>
                <h3 class="font-bold text-slate-900 tracking-tight">Insights</h3>
            </div>
            <p class="text-sm font-bold text-slate-800 mb-2">Your gigs are performing well!</p>
            <p class="text-sm text-slate-600 mb-6 leading-relaxed">On average, you receive <strong class="text-slate-900 bg-slate-100 px-1 rounded">4.2 applications</strong> per gig within the first 48 hours.</p>
            <button class="w-full bg-slate-50 hover:bg-slate-100 border border-slate-200 text-slate-700 font-semibold py-2.5 rounded-xl text-sm transition-colors shadow-sm">View Full Report</button>
        </div>
        
        <!-- Top Categories (Dummy) -->
        <div class="glass-card p-6">
            <h3 class="font-bold text-slate-900 tracking-tight mb-6">Top Hired Categories</h3>
            <div class="space-y-5">
                <div>
                    <div class="flex justify-between text-xs font-bold text-slate-700 mb-2">
                        <span>Development</span>
                        <span>45%</span>
                    </div>
                    <div class="w-full bg-slate-100 rounded-full h-2"><div class="bg-blue-500 h-2 rounded-full" style="width: 45%"></div></div>
                </div>
                <div>
                    <div class="flex justify-between text-xs font-bold text-slate-700 mb-2">
                        <span>Design</span>
                        <span>30%</span>
                    </div>
                    <div class="w-full bg-slate-100 rounded-full h-2"><div class="bg-indigo-500 h-2 rounded-full" style="width: 30%"></div></div>
                </div>
                <div>
                    <div class="flex justify-between text-xs font-bold text-slate-700 mb-2">
                        <span>Writing</span>
                        <span>15%</span>
                    </div>
                    <div class="w-full bg-slate-100 rounded-full h-2"><div class="bg-emerald-500 h-2 rounded-full" style="width: 15%"></div></div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
