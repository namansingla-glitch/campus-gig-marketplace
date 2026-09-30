<%@ page import="java.sql.*, com.gigmarket.util.DatabaseUtil" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"student".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userName = (String) session.getAttribute("userName");

    int applied = 0, selected = 0, completed = 0;
    double earnings = 0.0;

    try (Connection conn = DatabaseUtil.getConnection()) {
        PreparedStatement p1 = conn.prepareStatement("SELECT COUNT(*) FROM Applications WHERE applicant_id = ?");
        p1.setInt(1, userId);
        ResultSet r1 = p1.executeQuery();
        if(r1.next()) applied = r1.getInt(1);

        PreparedStatement p2 = conn.prepareStatement("SELECT COUNT(*) FROM Applications WHERE applicant_id = ? AND status = 'Hired'");
        p2.setInt(1, userId);
        ResultSet r2 = p2.executeQuery();
        if(r2.next()) selected = r2.getInt(1);

        PreparedStatement p3 = conn.prepareStatement(
            "SELECT COUNT(*), SUM(g.budget) FROM Applications a JOIN Gigs g ON a.gig_id = g.gig_id " +
            "WHERE a.applicant_id = ? AND a.status = 'Hired' AND g.status = 'Closed'"
        );
        p3.setInt(1, userId);
        ResultSet r3 = p3.executeQuery();
        if(r3.next()) {
            completed = r3.getInt(1);
            earnings = r3.getDouble(2);
        }
    } catch (Exception e) {}
    
    int points = (completed * 100) + (int)((earnings / 1000) * 10);
    
    // Greeting logic
    java.util.Calendar c = java.util.Calendar.getInstance();
    int timeOfDay = c.get(java.util.Calendar.HOUR_OF_DAY);
    String greeting = "Good evening";
    if(timeOfDay < 12) greeting = "Good morning";
    else if(timeOfDay < 17) greeting = "Good afternoon";
    
    // Earnings formatting
    String earningsStr = (earnings == Math.floor(earnings)) ? 
        String.format("%,.0f", earnings) : String.format("%,.2f", earnings);
%>
<jsp:include page="header.jsp" />

<div class="mb-10 text-center sm:text-left">
    <h1 class="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight"><%= greeting %>, <%= userName %>.</h1>
    <p class="text-slate-500 mt-2 text-lg">Find opportunities that match your skills.</p>
</div>

<!-- Top Metrics -->
<div class="grid grid-cols-2 md:grid-cols-5 gap-4 md:gap-6 mb-10">
    <!-- Applied -->
    <div class="glass-card p-5 relative overflow-hidden group">
        <div class="flex flex-col h-full">
            <div class="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
            </div>
            <div class="text-4xl font-extrabold text-slate-900 tracking-tight mb-1"><%= applied %></div>
            <div class="text-sm font-semibold text-slate-500">Gigs Applied</div>
        </div>
    </div>
    
    <!-- Selected -->
    <div class="glass-card p-5 relative overflow-hidden group">
        <div class="flex flex-col h-full">
            <div class="w-10 h-10 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            </div>
            <div class="text-4xl font-extrabold text-slate-900 tracking-tight mb-1"><%= selected %></div>
            <div class="text-sm font-semibold text-slate-500">Selected</div>
        </div>
    </div>

    <!-- Completed -->
    <div class="glass-card p-5 relative overflow-hidden group">
        <div class="flex flex-col h-full">
            <div class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
            </div>
            <div class="text-4xl font-extrabold text-slate-900 tracking-tight mb-1"><%= completed %></div>
            <div class="text-sm font-semibold text-slate-500">Completed</div>
        </div>
    </div>
    
    <!-- Earnings -->
    <div class="glass-card p-5 relative overflow-hidden group">
        <div class="flex flex-col h-full">
            <div class="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                <span class="font-bold text-lg leading-none">&#8377;</span>
            </div>
            <div class="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight mb-1 truncate">&#8377;<%= earningsStr %></div>
            <div class="text-sm font-semibold text-slate-500">Total Earnings</div>
        </div>
    </div>
    
    <!-- Points -->
    <div class="glass-card p-5 relative overflow-hidden group bg-gradient-to-br from-blue-600 to-indigo-600 text-white border-none shadow-blue-500/20">
        <div class="flex flex-col h-full relative z-10">
            <div class="w-10 h-10 rounded-xl bg-white/20 text-white flex items-center justify-center mb-4 backdrop-blur-sm group-hover:scale-110 transition-transform">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"></path></svg>
            </div>
            <div class="text-4xl font-extrabold tracking-tight mb-1"><%= points %></div>
            <div class="text-sm font-medium text-white/80">Reward Points</div>
        </div>
        <div class="absolute -right-8 -top-8 w-32 h-32 bg-white/10 rounded-full blur-2xl"></div>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
    <div class="lg:col-span-2 space-y-8">
        <div class="glass-card p-8">
            <div class="flex justify-between items-center mb-8">
                <h3 class="font-bold text-lg text-slate-900 tracking-tight">Earnings Distribution</h3>
                <span class="text-xs font-semibold text-slate-500 bg-slate-100 px-3 py-1.5 rounded-full">This Semester</span>
            </div>
            <div class="h-48 flex items-end justify-between gap-3 px-2">
                <!-- Dummy Bars matching SaaS look -->
                <div class="w-full flex flex-col items-center gap-3"><div class="w-full bg-blue-100 hover:bg-blue-200 transition-colors rounded-t-lg h-12 relative group"><div class="absolute -top-10 left-1/2 -translate-x-1/2 bg-slate-900 text-white text-xs py-1.5 px-2.5 rounded shadow-lg hidden group-hover:block whitespace-nowrap">&#8377;500</div></div><span class="text-xs text-slate-400 font-semibold">Aug</span></div>
                <div class="w-full flex flex-col items-center gap-3"><div class="w-full bg-blue-300 hover:bg-blue-400 transition-colors rounded-t-lg h-24 relative group"><div class="absolute -top-10 left-1/2 -translate-x-1/2 bg-slate-900 text-white text-xs py-1.5 px-2.5 rounded shadow-lg hidden group-hover:block whitespace-nowrap">&#8377;1,200</div></div><span class="text-xs text-slate-400 font-semibold">Sep</span></div>
                <div class="w-full flex flex-col items-center gap-3"><div class="w-full bg-blue-600 hover:bg-blue-700 transition-colors rounded-t-lg h-32 relative group"><div class="absolute -top-10 left-1/2 -translate-x-1/2 bg-slate-900 text-white text-xs py-1.5 px-2.5 rounded shadow-lg hidden group-hover:block whitespace-nowrap">&#8377;2,000</div></div><span class="text-xs text-slate-400 font-semibold">Oct</span></div>
                <div class="w-full flex flex-col items-center gap-3"><div class="w-full bg-blue-200 hover:bg-blue-300 transition-colors rounded-t-lg h-16 relative group"><div class="absolute -top-10 left-1/2 -translate-x-1/2 bg-slate-900 text-white text-xs py-1.5 px-2.5 rounded shadow-lg hidden group-hover:block whitespace-nowrap">&#8377;800</div></div><span class="text-xs text-slate-400 font-semibold">Nov</span></div>
                <div class="w-full flex flex-col items-center gap-3"><div class="w-full bg-blue-400 hover:bg-blue-500 transition-colors rounded-t-lg h-28 relative group"><div class="absolute -top-10 left-1/2 -translate-x-1/2 bg-slate-900 text-white text-xs py-1.5 px-2.5 rounded shadow-lg hidden group-hover:block whitespace-nowrap">&#8377;1,500</div></div><span class="text-xs text-slate-400 font-semibold">Dec</span></div>
            </div>
        </div>
    </div>

    <div class="space-y-8">
        <div class="glass-card p-8">
            <h3 class="font-bold text-lg text-slate-900 tracking-tight mb-6">Upcoming Deadlines</h3>
            <div class="space-y-4">
                <label class="flex items-start gap-3 p-4 bg-white border border-slate-100 rounded-xl cursor-pointer hover:shadow-md transition-shadow group">
                    <input type="checkbox" class="mt-1 rounded text-blue-600 focus:ring-blue-500 border-slate-300 w-4 h-4 cursor-pointer">
                    <div>
                        <p class="text-sm font-semibold text-slate-900 group-hover:text-blue-600 transition-colors">Submit Python Script</p>
                        <p class="text-xs text-slate-500 mt-1">Tomorrow, 11:59 PM</p>
                    </div>
                </label>
                <label class="flex items-start gap-3 p-4 bg-slate-50 border border-slate-100 rounded-xl cursor-pointer opacity-70">
                    <input type="checkbox" checked class="mt-1 rounded text-blue-600 focus:ring-blue-500 border-slate-300 w-4 h-4 cursor-pointer">
                    <div>
                        <p class="text-sm font-semibold text-slate-500 line-through">Review Figma Drafts</p>
                        <p class="text-xs text-slate-400 mt-1">Oct 24</p>
                    </div>
                </label>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
