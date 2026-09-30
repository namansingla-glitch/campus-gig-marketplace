<%@ page import="java.sql.*, com.gigmarket.util.DatabaseUtil, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"student".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String gigIdStr = request.getParameter("gigId");
    if (gigIdStr == null || gigIdStr.trim().isEmpty()) {
        response.sendRedirect("browse-gigs");
        return;
    }

    String title = "", category = "", description = "", status = "OPEN";
    double budget = 0;
    Date appDeadline = null;
    Date compDeadline = null;
    Timestamp createdAt = null;

    try (Connection conn = DatabaseUtil.getConnection()) {
        PreparedStatement stmt = conn.prepareStatement("SELECT * FROM Gigs WHERE gig_id = ?");
        stmt.setInt(1, Integer.parseInt(gigIdStr));
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            title = rs.getString("title");
            category = rs.getString("category");
            description = rs.getString("description");
            budget = rs.getDouble("budget");
            status = rs.getString("status");
            appDeadline = rs.getDate("deadline");
            compDeadline = rs.getDate("completion_deadline");
            createdAt = rs.getTimestamp("created_at");
        }
    } catch (Exception e) {}

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat timeFmt = new SimpleDateFormat("dd MMM yyyy, h:mm a");
    
    String bdgStr = (budget == Math.floor(budget)) ? String.format("%,.0f", budget) : String.format("%,.2f", budget);
%>
<jsp:include page="header.jsp" />

<div class="mb-6">
    <a href="browse-gigs" class="inline-flex items-center text-sm font-semibold text-slate-500 hover:text-slate-800 transition-colors">
        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path></svg>
        Back to Explore
    </a>
</div>

<div class="flex flex-col lg:flex-row gap-8 relative items-start">
    
    <!-- LEFT: Gig Details & Application Form -->
    <div class="flex-1 w-full space-y-8">
        
        <!-- Gig Detail Info -->
        <div class="glass-card p-8">
            <span class="inline-block px-3 py-1.5 bg-blue-50 text-blue-700 text-[10px] font-bold rounded-full uppercase tracking-wider mb-4"><%= category != null ? category : "General" %></span>
            <h1 class="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight mb-4 leading-tight"><%= title %></h1>
            
            <div class="flex items-center gap-2 text-sm font-medium text-slate-500 mb-8 border-b border-slate-100 pb-6">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                Posted: <%= createdAt != null ? timeFmt.format(createdAt) : "Recently" %>
            </div>
            
            <h3 class="text-lg font-bold text-slate-900 mb-3">Project Description</h3>
            <div class="prose prose-slate max-w-none mb-8 text-slate-600 leading-relaxed">
                <p><%= description != null ? description.replace("\n", "<br>") : "" %></p>
            </div>
            
            <h3 class="text-lg font-bold text-slate-900 mb-4">Timeline</h3>
            <div class="bg-slate-50 border border-slate-100 rounded-2xl p-6 mb-2">
                <% if(appDeadline != null) { %>
                    <div class="flex items-center justify-between relative">
                        <!-- Horizontal Timeline (Desktop) -->
                        <div class="hidden sm:block absolute top-1/2 left-0 right-0 h-0.5 bg-blue-200 -z-0 -translate-y-1/2"></div>
                        
                        <div class="flex flex-col items-center relative z-10 bg-slate-50 px-2">
                            <div class="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center mb-2 shadow-sm font-bold text-xs">1</div>
                            <span class="text-xs font-bold text-slate-800 uppercase tracking-wider">Posted</span>
                            <span class="text-xs font-medium text-slate-500"><%= createdAt != null ? sdf.format(createdAt) : "" %></span>
                        </div>
                        
                        <div class="flex flex-col items-center relative z-10 bg-slate-50 px-2">
                            <div class="w-8 h-8 rounded-full bg-blue-600 text-white flex items-center justify-center mb-2 shadow-sm font-bold text-xs">2</div>
                            <span class="text-xs font-bold text-slate-800 uppercase tracking-wider text-center">App<br>Deadline</span>
                            <span class="text-xs font-medium text-slate-500"><%= sdf.format(appDeadline) %></span>
                        </div>
                        
                        <% if(compDeadline != null) { %>
                        <div class="flex flex-col items-center relative z-10 bg-slate-50 px-2">
                            <div class="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center mb-2 shadow-sm font-bold text-xs">3</div>
                            <span class="text-xs font-bold text-slate-800 uppercase tracking-wider text-center">Completion</span>
                            <span class="text-xs font-medium text-slate-500"><%= sdf.format(compDeadline) %></span>
                        </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        </div>
                        <div>
                            <span class="text-sm font-bold text-slate-800">Flexible Timeline</span>
                            <p class="text-xs text-slate-500 mt-1">Discuss deadlines with the poster after hiring.</p>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
        
        <!-- Application Form -->
        <div class="glass-card p-8 border-t-4 border-t-blue-600 shadow-xl shadow-blue-900/5" id="apply-section">
            <h2 class="text-2xl font-bold text-slate-900 mb-6 tracking-tight">Submit your application</h2>
            
            <form action="apply-gig" method="post" enctype="multipart/form-data" class="space-y-6">
                <input type="hidden" name="gigId" value="<%= gigIdStr %>">
                
                <div>
                    <label class="block text-sm font-semibold text-slate-800 mb-2">Your Pitch <span class="text-blue-500">*</span></label>
                    <p class="text-xs text-slate-500 mb-3">Explain why you're the best fit for this micro-task.</p>
                    <textarea name="pitchText" required rows="4" class="w-full bg-slate-50 border border-slate-200 rounded-xl p-4 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow shadow-sm resize-y" placeholder="Hi! I have experience with..."></textarea>
                </div>

                <div>
                    <label class="block text-sm font-semibold text-slate-800 mb-2">Upload Portfolio / Resume <span class="text-blue-500">*</span></label>
                    <p class="text-xs text-slate-500 mb-3">Attach relevant work samples as a single document.</p>
                    
                    <div x-data="{ fileName: '' }" class="mt-1 flex justify-center px-6 pt-8 pb-8 border-2 border-slate-200 border-dashed rounded-2xl bg-slate-50/50 hover:bg-slate-50 transition-colors relative group cursor-pointer" @dragover.prevent="$el.classList.add('border-blue-400')" @dragleave.prevent="$el.classList.remove('border-blue-400')" @drop.prevent="$el.classList.remove('border-blue-400'); fileName = $event.dataTransfer.files[0].name; $refs.fileInput.files = $event.dataTransfer.files">
                        <div class="space-y-2 text-center pointer-events-none">
                            <div class="w-16 h-16 bg-white rounded-full shadow-sm flex items-center justify-center mx-auto mb-4 group-hover:scale-105 transition-transform">
                                <svg class="h-8 w-8 text-blue-500" stroke="currentColor" fill="none" viewBox="0 0 48 48" aria-hidden="true">
                                    <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                                </svg>
                            </div>
                            <div class="flex text-sm text-slate-600 justify-center items-center pointer-events-auto">
                                <label class="relative cursor-pointer bg-white border border-slate-200 shadow-sm rounded-lg font-semibold text-slate-700 hover:text-blue-600 transition-colors px-4 py-2">
                                    <span x-text="fileName === '' ? 'Select a file' : 'Change file'"></span>
                                    <input x-ref="fileInput" type="file" name="portfolioFile" required class="sr-only" @change="fileName = $event.target.files[0].name">
                                </label>
                                <p class="pl-3" x-show="fileName === ''">or drag and drop</p>
                            </div>
                            <div class="mt-4" x-show="fileName !== ''" style="display: none;">
                                <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-md bg-blue-50 border border-blue-100 text-blue-700 text-sm font-bold">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                                    <span x-text="fileName"></span>
                                </span>
                            </div>
                            <p class="text-xs font-medium text-slate-400 mt-2" x-show="fileName === ''">PDF, DOC, DOCX up to 5MB</p>
                        </div>
                    </div>
                </div>

                <div class="pt-4 border-t border-slate-100">
                    <button type="submit" class="w-full btn-primary py-3.5 rounded-xl text-base font-bold shadow-lg shadow-blue-500/20 flex justify-center items-center gap-2">
                        Submit Application
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg>
                    </button>
                </div>
            </form>
        </div>
        
    </div>
    
    <!-- RIGHT: Sticky Summary Card -->
    <div class="w-full lg:w-80 shrink-0 lg:sticky lg:top-28">
        <div class="glass-card p-6 shadow-xl shadow-slate-900/5 border-t-4 border-t-blue-600">
            <div class="text-center pb-6 border-b border-slate-100 mb-6">
                <p class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Budget</p>
                <div class="text-4xl font-extrabold text-slate-900">&#8377;<%= bdgStr %></div>
            </div>
            
            <div class="space-y-4 mb-8">
                <div class="flex justify-between items-center text-sm">
                    <span class="font-medium text-slate-500">Status</span>
                    <span class="inline-block px-2.5 py-1 bg-emerald-50 text-emerald-700 text-xs font-bold rounded-full uppercase tracking-wider border border-emerald-200"><%= status %></span>
                </div>
                
                <% if(appDeadline != null) { %>
                <div class="flex justify-between items-center text-sm">
                    <span class="font-medium text-slate-500">App Deadline</span>
                    <span class="font-bold text-slate-800"><%= sdf.format(appDeadline) %></span>
                </div>
                <% } %>
                
                <% if(compDeadline != null) { %>
                <div class="flex justify-between items-center text-sm">
                    <span class="font-medium text-slate-500">Comp Deadline</span>
                    <span class="font-bold text-slate-800"><%= sdf.format(compDeadline) %></span>
                </div>
                <% } %>
                
                <% if(appDeadline == null && compDeadline == null) { %>
                <div class="flex justify-between items-center text-sm">
                    <span class="font-medium text-slate-500">Timeline</span>
                    <span class="font-bold text-slate-800">Flexible</span>
                </div>
                <% } %>
            </div>
            
            <a href="#apply-section" class="btn-primary block w-full text-center py-3 rounded-xl font-bold shadow-md hover:shadow-lg transition-all">Apply Now</a>
            <p class="text-[10px] font-medium text-slate-400 text-center mt-3 uppercase tracking-wider">Secure Payment via CampusGig</p>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
