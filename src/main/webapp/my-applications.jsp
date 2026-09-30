<%@ page import="java.sql.*, com.gigmarket.util.DatabaseUtil, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"student".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
%>
<jsp:include page="header.jsp" />

<div class="mb-10 text-center lg:text-left">
    <h1 class="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">My Applications</h1>
    <p class="text-lg text-slate-500 mt-2">Track the status of your micro-task applications.</p>
</div>

<div class="glass-card overflow-hidden max-w-5xl mx-auto">
    <%
        try (Connection conn = DatabaseUtil.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT a.application_id, a.status as app_status, a.applied_at, " +
                "g.gig_id, g.title, g.budget, g.deadline, g.completion_deadline, g.status as gig_status " +
                "FROM Applications a JOIN Gigs g ON a.gig_id = g.gig_id " +
                "WHERE a.applicant_id = ? ORDER BY a.applied_at DESC"
            );
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            boolean hasApps = false;
            
            if (rs.next()) {
                hasApps = true;
    %>
        <div class="divide-y divide-slate-100">
            <%
                do {
                    String appStatus = rs.getString("app_status");
                    String gigStatus = rs.getString("gig_status");
                    
                    // Logic to determine visual flow
                    String visualStatus = appStatus;
                    if ("Hired".equals(appStatus) && "Closed".equals(gigStatus)) {
                        visualStatus = "Completed";
                    }
                    
                    double bdg = rs.getDouble("budget");
                    String bdgStr = (bdg == Math.floor(bdg)) ? String.format("%,.0f", bdg) : String.format("%,.2f", bdg);
                    
                    Date compDeadline = rs.getDate("completion_deadline");
                    Timestamp appliedAt = rs.getTimestamp("applied_at");
            %>
            <div class="p-6 md:p-8 hover:bg-slate-50/50 transition-colors flex flex-col md:flex-row md:items-center justify-between gap-6">
                <!-- Left: Info -->
                <div class="flex-1">
                    <a href="apply-gig.jsp?gigId=<%= rs.getInt("gig_id") %>" class="text-lg font-bold text-slate-900 hover:text-blue-600 transition-colors leading-tight block mb-1">
                        <%= rs.getString("title") %>
                    </a>
                    
                    <div class="flex flex-wrap items-center gap-4 text-sm mt-3">
                        <div class="flex items-center gap-1.5 font-bold text-slate-700">
                            <span class="text-slate-400 font-normal">Budget:</span> &#8377;<%= bdgStr %>
                        </div>
                        <div class="w-1 h-1 rounded-full bg-slate-300"></div>
                        <div class="text-slate-500 font-medium">
                            <span class="text-slate-400 font-normal">Applied:</span> <%= appliedAt != null ? sdf.format(appliedAt) : "Recently" %>
                        </div>
                        <div class="w-1 h-1 rounded-full bg-slate-300 hidden sm:block"></div>
                        <div class="text-slate-500 font-medium hidden sm:block">
                            <span class="text-slate-400 font-normal">Timeline:</span> <%= compDeadline != null ? sdf.format(compDeadline) : "Flexible" %>
                        </div>
                    </div>
                </div>
                
                <!-- Right: Status Flow -->
                <div class="w-full md:w-64 shrink-0 bg-white border border-slate-100 rounded-xl p-4 shadow-sm">
                    <div class="flex justify-between items-center relative">
                        <!-- Connecting Line -->
                        <div class="absolute top-1/2 left-4 right-4 h-0.5 bg-slate-100 -z-0 -translate-y-1/2"></div>
                        
                        <!-- Step 1: Pending -->
                        <div class="flex flex-col items-center relative z-10 bg-white px-1 gap-1.5">
                            <% if("Pending".equals(visualStatus) || "Hired".equals(visualStatus) || "Completed".equals(visualStatus) || "Rejected".equals(visualStatus)) { %>
                                <div class="w-6 h-6 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"></path></svg>
                                </div>
                            <% } %>
                            <span class="text-[10px] font-bold text-slate-500 uppercase">Under Review</span>
                        </div>
                        
                        <!-- Step 2: Result -->
                        <div class="flex flex-col items-center relative z-10 bg-white px-1 gap-1.5">
                            <% if("Pending".equals(visualStatus)) { %>
                                <div class="w-6 h-6 rounded-full bg-slate-100 border-2 border-white flex items-center justify-center"></div>
                            <% } else if("Hired".equals(visualStatus) || "Completed".equals(visualStatus)) { %>
                                <div class="w-6 h-6 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"></path></svg>
                                </div>
                            <% } else if("Rejected".equals(visualStatus)) { %>
                                <div class="w-6 h-6 rounded-full bg-red-100 text-red-600 flex items-center justify-center">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M6 18L18 6M6 6l12 12"></path></svg>
                                </div>
                            <% } %>
                            
                            <% if("Rejected".equals(visualStatus)) { %>
                                <span class="text-[10px] font-bold text-red-500 uppercase">Not Selected</span>
                            <% } else { %>
                                <span class="text-[10px] font-bold <%= ("Hired".equals(visualStatus) || "Completed".equals(visualStatus)) ? "text-blue-600" : "text-slate-400" %> uppercase">Selected</span>
                            <% } %>
                        </div>
                        
                        <!-- Step 3: Completed (if selected) -->
                        <% if(!"Rejected".equals(visualStatus)) { %>
                        <div class="flex flex-col items-center relative z-10 bg-white px-1 gap-1.5">
                            <% if("Completed".equals(visualStatus)) { %>
                                <div class="w-6 h-6 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"></path></svg>
                                </div>
                            <% } else { %>
                                <div class="w-6 h-6 rounded-full bg-slate-100 border-2 border-white flex items-center justify-center"></div>
                            <% } %>
                            <span class="text-[10px] font-bold <%= "Completed".equals(visualStatus) ? "text-emerald-600" : "text-slate-400" %> uppercase">Completed</span>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                } while (rs.next());
            %>
        </div>
    <%
            } else {
    %>
        <div class="p-16 text-center flex flex-col items-center justify-center">
            <div class="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-6 shadow-inner">
                <svg class="w-10 h-10 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
            </div>
            <h2 class="text-xl font-bold text-slate-900 mb-2">No applications yet</h2>
            <p class="text-slate-500 mb-6">You haven't applied to any micro-tasks.</p>
            <a href="browse-gigs" class="btn-primary px-6 py-2.5 rounded-full font-semibold shadow-sm">Explore Gigs</a>
        </div>
    <%
            }
        } catch (Exception e) {}
    %>
</div>

<jsp:include page="footer.jsp" />
