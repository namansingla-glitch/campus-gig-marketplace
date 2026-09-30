<%@ page import="java.sql.*, com.gigmarket.util.DatabaseUtil" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"student".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userName = (String) session.getAttribute("userName");

    int completed = 0;
    double earnings = 0.0;

    try (Connection conn = DatabaseUtil.getConnection()) {
        PreparedStatement stmt = conn.prepareStatement(
            "SELECT COUNT(*), SUM(g.budget) FROM Applications a JOIN Gigs g ON a.gig_id = g.gig_id " +
            "WHERE a.applicant_id = ? AND a.status = 'Hired' AND g.status = 'Closed'"
        );
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();
        if(rs.next()) {
            completed = rs.getInt(1);
            earnings = rs.getDouble(2);
        }
    } catch (Exception e) {}
    
    // 100 points per completed gig, +10 points per ₹1000 earned
    int points = (completed * 100) + (int)((earnings / 1000) * 10);
    
    // Level logic (mock)
    String level = "Bronze";
    int nextLevelPoints = 500;
    if (points >= 2000) { level = "Gold"; nextLevelPoints = 5000; }
    else if (points >= 500) { level = "Silver"; nextLevelPoints = 2000; }
    
    int progressPercent = (int) (((double) points / nextLevelPoints) * 100);
    if(progressPercent > 100) progressPercent = 100;
    
    String earningsStr = (earnings == Math.floor(earnings)) ? 
        String.format("%,.0f", earnings) : String.format("%,.2f", earnings);
%>
<jsp:include page="header.jsp" />

<div class="mb-10">
    <h1 class="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">My Profile</h1>
    <p class="text-lg text-slate-500 mt-2">View your progress, rewards, and achievements.</p>
</div>

<div class="flex flex-col lg:flex-row gap-8">
    
    <!-- LEFT: Profile & Rewards Progress -->
    <div class="w-full lg:w-1/3 flex flex-col gap-8">
        
        <!-- User Card -->
        <div class="glass-card p-8 text-center relative overflow-hidden">
            <div class="absolute top-0 left-0 w-full h-24 bg-gradient-to-r from-blue-100 to-indigo-100 -z-10"></div>
            
            <div class="w-24 h-24 mx-auto rounded-full bg-white p-1 shadow-sm mb-4">
                <div class="w-full h-full rounded-full bg-blue-600 text-white flex items-center justify-center text-4xl font-bold">
                    <%= userName.substring(0,1).toUpperCase() %>
                </div>
            </div>
            
            <h2 class="text-2xl font-bold text-slate-900"><%= userName %></h2>
            <p class="text-sm font-medium text-slate-500 mb-6">Computer Science &middot; Year 3</p>
            
            <div class="flex justify-center gap-6 border-t border-slate-100 pt-6">
                <div>
                    <div class="text-2xl font-bold text-slate-900"><%= completed %></div>
                    <div class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Completed</div>
                </div>
                <div>
                    <div class="text-2xl font-bold text-slate-900">&#8377;<%= earningsStr %></div>
                    <div class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Earned</div>
                </div>
            </div>
        </div>
        
        <!-- Rewards Progress -->
        <div class="glass-card p-8 bg-gradient-to-br from-slate-900 to-slate-800 text-white border-none shadow-xl relative overflow-hidden">
            <div class="absolute top-0 right-0 -mt-10 -mr-10 w-40 h-40 bg-white/5 rounded-full blur-2xl"></div>
            
            <div class="flex justify-between items-start mb-8 relative z-10">
                <div>
                    <h3 class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-1">Current Tier</h3>
                    <div class="text-2xl font-bold text-white flex items-center gap-2">
                        <%= level %> Member
                        <% if(level.equals("Bronze")) { %> 🥉 <% } else if(level.equals("Silver")) { %> 🥈 <% } else { %> 🥇 <% } %>
                    </div>
                </div>
                <div class="text-right">
                    <div class="text-3xl font-extrabold text-blue-400"><%= points %></div>
                    <div class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Total Points</div>
                </div>
            </div>
            
            <div class="relative z-10">
                <div class="flex justify-between text-xs font-semibold text-slate-300 mb-2">
                    <span><%= points %> pts</span>
                    <span><%= nextLevelPoints %> pts to next tier</span>
                </div>
                <div class="w-full bg-slate-700/50 rounded-full h-2.5 backdrop-blur-sm p-0.5">
                    <div class="bg-gradient-to-r from-blue-500 to-indigo-400 h-1.5 rounded-full" style="width: <%= progressPercent %>%"></div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- RIGHT: Achievements & Leaderboard -->
    <div class="w-full lg:w-2/3 flex flex-col gap-8">
        
        <!-- Achievements -->
        <div class="glass-card p-8">
            <div class="flex items-center justify-between mb-6 border-b border-slate-100 pb-4">
                <h3 class="text-xl font-bold text-slate-900 tracking-tight">Achievements</h3>
                <span class="text-sm font-semibold text-blue-600 bg-blue-50 px-3 py-1 rounded-full">3 Unlocked</span>
            </div>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <!-- Unlocked -->
                <div class="flex items-center gap-4 p-4 rounded-xl border border-blue-100 bg-blue-50/50 hover:bg-blue-50 transition-colors">
                    <div class="w-12 h-12 rounded-full bg-white shadow-sm flex items-center justify-center text-blue-600 border border-blue-100 shrink-0">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                    </div>
                    <div>
                        <h4 class="font-bold text-slate-900 text-sm">First Gig</h4>
                        <p class="text-xs text-slate-500 mt-0.5">Completed your first micro-task.</p>
                    </div>
                </div>
                
                <div class="flex items-center gap-4 p-4 rounded-xl border border-indigo-100 bg-indigo-50/50 hover:bg-indigo-50 transition-colors">
                    <div class="w-12 h-12 rounded-full bg-white shadow-sm flex items-center justify-center text-indigo-600 border border-indigo-100 shrink-0">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </div>
                    <div>
                        <h4 class="font-bold text-slate-900 text-sm">Top Earner</h4>
                        <p class="text-xs text-slate-500 mt-0.5">Earned over &#8377;1,000.</p>
                    </div>
                </div>
                
                <!-- Locked -->
                <div class="flex items-center gap-4 p-4 rounded-xl border border-slate-100 bg-slate-50 opacity-60 grayscale hover:grayscale-0 hover:opacity-100 transition-all cursor-not-allowed">
                    <div class="w-12 h-12 rounded-full bg-white shadow-sm flex items-center justify-center text-slate-400 border border-slate-200 shrink-0">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </div>
                    <div>
                        <h4 class="font-bold text-slate-900 text-sm">Perfect 10</h4>
                        <p class="text-xs text-slate-500 mt-0.5">Complete 10 gigs successfully.</p>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Leaderboard (Dummy as requested) -->
        <div class="glass-card overflow-hidden">
            <div class="p-6 border-b border-slate-100 bg-white/50 flex items-center justify-between">
                <h3 class="text-lg font-bold text-slate-900 tracking-tight">Campus Leaderboard</h3>
                <span class="text-xs font-semibold text-slate-500 uppercase tracking-wider">This Month</span>
            </div>
            
            <div class="divide-y divide-slate-50">
                <!-- 1 -->
                <div class="flex items-center justify-between p-4 hover:bg-slate-50/50 transition-colors">
                    <div class="flex items-center gap-4">
                        <div class="w-8 font-bold text-slate-400 text-center">1</div>
                        <div class="w-10 h-10 rounded-full bg-amber-100 text-amber-700 font-bold flex items-center justify-center text-sm shadow-sm">N</div>
                        <div class="font-bold text-slate-900">Naman</div>
                    </div>
                    <div class="font-extrabold text-blue-600">3,450 pts</div>
                </div>
                <!-- 2 -->
                <div class="flex items-center justify-between p-4 hover:bg-slate-50/50 transition-colors">
                    <div class="flex items-center gap-4">
                        <div class="w-8 font-bold text-slate-400 text-center">2</div>
                        <div class="w-10 h-10 rounded-full bg-slate-200 text-slate-700 font-bold flex items-center justify-center text-sm shadow-sm">R</div>
                        <div class="font-bold text-slate-900">Riddhi</div>
                    </div>
                    <div class="font-extrabold text-slate-600">2,900 pts</div>
                </div>
                <!-- 3 -->
                <div class="flex items-center justify-between p-4 hover:bg-slate-50/50 transition-colors">
                    <div class="flex items-center gap-4">
                        <div class="w-8 font-bold text-slate-400 text-center">3</div>
                        <div class="w-10 h-10 rounded-full bg-orange-100 text-orange-700 font-bold flex items-center justify-center text-sm shadow-sm">S</div>
                        <div class="font-bold text-slate-900">Shreyash</div>
                    </div>
                    <div class="font-extrabold text-slate-600">2,150 pts</div>
                </div>
                <!-- 4 -->
                <div class="flex items-center justify-between p-4 hover:bg-slate-50/50 transition-colors">
                    <div class="flex items-center gap-4">
                        <div class="w-8 font-bold text-slate-400 text-center">4</div>
                        <div class="w-10 h-10 rounded-full bg-blue-100 text-blue-700 font-bold flex items-center justify-center text-sm shadow-sm">S</div>
                        <div class="font-bold text-slate-900">Shivam</div>
                    </div>
                    <div class="font-extrabold text-slate-600">1,800 pts</div>
                </div>
                <!-- 5 -->
                <div class="flex items-center justify-between p-4 hover:bg-slate-50/50 transition-colors">
                    <div class="flex items-center gap-4">
                        <div class="w-8 font-bold text-slate-400 text-center">5</div>
                        <div class="w-10 h-10 rounded-full bg-indigo-100 text-indigo-700 font-bold flex items-center justify-center text-sm shadow-sm">M</div>
                        <div class="font-bold text-slate-900">Mohak</div>
                    </div>
                    <div class="font-extrabold text-slate-600">1,200 pts</div>
                </div>
            </div>
        </div>
        
    </div>
</div>

<jsp:include page="footer.jsp" />
