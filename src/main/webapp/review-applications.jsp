<%@ page import="java.sql.*, com.gigmarket.util.DatabaseUtil, java.util.List, com.gigmarket.model.Application" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"poster".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String gigIdStr = (String) request.getAttribute("gigId");
    List<Application> applications = (List<Application>) request.getAttribute("applications");
    
    String title = "Applicant Management";
    String status = "OPEN";
    try (Connection conn = DatabaseUtil.getConnection()) {
        PreparedStatement stmt = conn.prepareStatement("SELECT title, status FROM Gigs WHERE gig_id = ?");
        stmt.setInt(1, Integer.parseInt(gigIdStr));
        ResultSet rs = stmt.executeQuery();
        if(rs.next()) {
            title = rs.getString("title");
            status = rs.getString("status");
        }
    } catch (Exception e) {}
%>
<jsp:include page="header.jsp" />

<div class="mb-6">
    <a href="poster-dashboard.jsp" class="inline-flex items-center text-sm font-semibold text-slate-500 hover:text-slate-800 transition-colors">
        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path></svg>
        Back to Dashboard
    </a>
</div>

<div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-10">
    <div>
        <div class="flex items-center gap-3 mb-2">
            <h1 class="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight"><%= title %></h1>
            <span class="px-3 py-1 bg-blue-50 text-blue-700 text-xs font-bold rounded-full uppercase tracking-wider border border-blue-200"><%= status %></span>
        </div>
        <p class="text-lg text-slate-500">Review applicants and select the best candidate.</p>
    </div>
</div>

<div class="space-y-6">
    <% if (applications != null && !applications.isEmpty()) { 
        for (Application app : applications) { 
    %>
    <div class="glass-card p-6 md:p-8 flex flex-col md:flex-row md:items-start gap-8">
        
        <!-- Applicant Info -->
        <div class="flex-1 space-y-6">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center font-bold text-lg shadow-sm border border-blue-200">
                    <%= app.getApplicantName().substring(0,1).toUpperCase() %>
                </div>
                <div>
                    <h3 class="text-xl font-bold text-slate-900"><%= app.getApplicantName() %></h3>
                    <p class="text-sm font-medium text-slate-500">Applied recently</p>
                </div>
                
                <% if ("Hired".equals(app.getStatus())) { %>
                    <span class="ml-auto px-3 py-1 bg-blue-50 text-blue-700 text-xs font-bold rounded-full border border-blue-200 flex items-center gap-1.5">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                        HIRED
                    </span>
                <% } else if ("Rejected".equals(app.getStatus())) { %>
                    <span class="ml-auto px-3 py-1 bg-slate-100 text-slate-500 text-xs font-bold rounded-full border border-slate-200">REJECTED</span>
                <% } %>
            </div>
            
            <div class="bg-slate-50/80 rounded-2xl p-5 border border-slate-100">
                <h4 class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Pitch</h4>
                <p class="text-sm text-slate-700 leading-relaxed"><%= app.getPitchText() %></p>
            </div>
            
            <% if(app.getPortfolioPath() != null && !app.getPortfolioPath().isEmpty()) { %>
            <div>
                <a href="#" class="inline-flex items-center gap-2 text-sm font-semibold text-blue-600 hover:text-blue-800 bg-blue-50 px-4 py-2 rounded-lg transition-colors border border-blue-100">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"></path></svg>
                    View File
                </a>
            </div>
            <% } %>
        </div>
        
        <!-- Actions -->
        <div class="w-full md:w-56 shrink-0 pt-6 md:pt-0 border-t md:border-t-0 md:border-l border-slate-100 md:pl-8 flex flex-col justify-center">
            <% if ("Pending".equals(app.getStatus())) { %>
                <form action="review-applications" method="post" class="mb-3" onsubmit="return confirm('Are you sure you want to hire this student? This will reject all other applicants and close the gig.');">
                    <input type="hidden" name="action" value="hire">
                    <input type="hidden" name="applicationId" value="<%= app.getApplicationId() %>">
                    <input type="hidden" name="gigId" value="<%= gigIdStr %>">
                    <button type="submit" class="w-full btn-primary py-3 rounded-xl font-bold shadow-md hover:shadow-lg transition-all flex items-center justify-center gap-2">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        Hire Student
                    </button>
                </form>
                <form action="review-applications" method="post" onsubmit="return confirm('Are you sure you want to reject this applicant?');">
                    <input type="hidden" name="action" value="reject">
                    <input type="hidden" name="applicationId" value="<%= app.getApplicationId() %>">
                    <input type="hidden" name="gigId" value="<%= gigIdStr %>">
                    <button type="submit" class="w-full btn-secondary py-3 rounded-xl font-semibold transition-all">Reject</button>
                </form>
            <% } else if ("Hired".equals(app.getStatus())) { %>
                <div class="text-center p-4 bg-emerald-50 rounded-xl border border-emerald-100">
                    <div class="w-12 h-12 bg-white rounded-full flex items-center justify-center mx-auto mb-3 shadow-sm">
                        <svg class="w-6 h-6 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                    </div>
                    <p class="text-emerald-700 font-bold mb-3">You hired this student!</p>
                    <% if("Open".equals(status)) { %>
                    <button onclick="confirm('Mark this gig as successfully completed?')" class="w-full bg-emerald-600 hover:bg-emerald-700 text-white py-2 rounded-lg text-sm font-bold shadow-md transition-colors">Mark Completed ✓</button>
                    <% } else { %>
                        <p class="text-xs font-semibold text-emerald-600 uppercase tracking-wider">Completed ✓</p>
                    <% } %>
                </div>
            <% } else { %>
                <div class="text-center p-4 bg-slate-50 rounded-xl border border-slate-100">
                    <p class="text-slate-500 font-medium">Application Rejected</p>
                </div>
            <% } %>
        </div>
        
    </div>
    <% 
        } 
    } else { 
    %>
        <div class="glass-card p-16 text-center flex flex-col items-center justify-center">
            <div class="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-6 shadow-inner">
                <svg class="w-10 h-10 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>
            </div>
            <h2 class="text-xl font-bold text-slate-900 mb-2">No applicants yet</h2>
            <p class="text-slate-500">Wait for students to apply to your gig.</p>
        </div>
    <% } %>
</div>

<jsp:include page="footer.jsp" />
