<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    if (session.getAttribute("userId") == null || !"poster".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<jsp:include page="header.jsp" />

<div class="mb-10 text-center lg:text-left">
    <h1 class="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">Create a Gig</h1>
    <p class="text-lg text-slate-500 mt-2">Post a micro-task and find the perfect student for the job.</p>
</div>

<div class="flex flex-col lg:flex-row gap-10" x-data="{
    title: '',
    category: 'Development',
    budget: '',
    description: '',
    hasTimeline: false,
    appDeadline: '',
    compDeadline: ''
}">
    
    <!-- LEFT: Form -->
    <div class="flex-1 max-w-2xl">
        <form action="post-gig" method="post" class="glass-card p-8 space-y-6">
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-slate-800 mb-2">Gig Title</label>
                    <input type="text" name="title" required x-model="title" class="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow shadow-sm" placeholder="e.g. Build Student Portal">
                </div>
                
                <div>
                    <label class="block text-sm font-semibold text-slate-800 mb-2">Category</label>
                    <div class="relative">
                        <select name="category" required x-model="category" class="w-full bg-white border border-slate-200 rounded-xl pl-4 pr-10 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow shadow-sm appearance-none">
                            <option value="Tutoring">Tutoring</option>
                            <option value="Design">Design</option>
                            <option value="Development" selected>Development</option>
                            <option value="Writing">Writing</option>
                            <option value="Event Support">Event Support</option>
                        </select>
                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-slate-500">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                        </div>
                    </div>
                </div>
                
                <div>
                    <label class="block text-sm font-semibold text-slate-800 mb-2">Budget (&#8377;)</label>
                    <div class="relative">
                        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4">
                            <span class="text-slate-500 font-semibold">&#8377;</span>
                        </div>
                        <input type="number" name="budget" required min="1" step="0.01" x-model="budget" class="w-full bg-white border border-slate-200 rounded-xl pl-8 pr-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow shadow-sm" placeholder="0.00">
                    </div>
                </div>
            </div>
            
            <div>
                <label class="block text-sm font-semibold text-slate-800 mb-2">Description</label>
                <textarea name="description" required rows="4" x-model="description" class="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow shadow-sm resize-y" placeholder="Describe the task, requirements, and any specific skills needed..."></textarea>
            </div>
            
            <div class="bg-slate-50 border border-slate-100 rounded-xl p-5 mt-6">
                <label class="flex items-center gap-3 cursor-pointer group mb-4">
                    <input type="checkbox" name="hasTimeline" value="true" x-model="hasTimeline" class="w-5 h-5 rounded border-slate-300 text-blue-600 focus:ring-blue-500">
                    <span class="text-sm font-semibold text-slate-800 group-hover:text-blue-600 transition-colors">Set application & completion timeline</span>
                </label>
                
                <!-- Flexible Timeline Indicator -->
                <div x-show="!hasTimeline" class="flex items-center gap-2 text-sm font-medium text-slate-500 bg-white border border-slate-100 px-4 py-3 rounded-lg shadow-sm">
                    <svg class="w-4 h-4 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    Flexible Timeline (Discuss deadlines with the hired student later)
                </div>
                
                <!-- Timeline Inputs -->
                <div x-show="hasTimeline" style="display: none;" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Application Deadline</label>
                        <input type="date" name="deadline" x-model="appDeadline" :required="hasTimeline" class="w-full bg-white border border-slate-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow shadow-sm">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Completion Deadline</label>
                        <input type="date" name="completionDeadline" x-model="compDeadline" :required="hasTimeline" class="w-full bg-white border border-slate-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow shadow-sm">
                    </div>
                    
                    <!-- Inline Validation Error -->
                    <div class="md:col-span-2" x-show="hasTimeline && appDeadline && compDeadline && new Date(compDeadline) <= new Date(appDeadline)" style="display: none;">
                        <p class="text-xs font-bold text-red-500 flex items-center gap-1 mt-1 bg-red-50 p-2 rounded-lg border border-red-100">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
                            Completion deadline must be after the application deadline.
                        </p>
                    </div>
                </div>
            </div>
            
            <div class="pt-6 border-t border-slate-100 flex justify-end">
                <button type="submit" class="btn-primary px-8 py-3.5 rounded-xl font-bold shadow-lg shadow-blue-500/20 w-full md:w-auto" :disabled="hasTimeline && appDeadline && compDeadline && new Date(compDeadline) <= new Date(appDeadline)">Post Gig Now</button>
            </div>
        </form>
    </div>
    
    <!-- RIGHT: Live Preview (Desktop Only) -->
    <div class="hidden lg:block w-80 shrink-0">
        <div class="sticky top-28">
            <h3 class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-4 ml-2">Live Preview</h3>
            
            <div class="glass-card p-6 border-t-4 border-t-blue-500 shadow-xl shadow-slate-900/5">
                <div class="mb-4">
                    <span class="inline-block px-2.5 py-1 bg-blue-50 text-blue-700 text-[10px] font-bold rounded uppercase tracking-wider" x-text="category"></span>
                </div>
                
                <h3 class="text-lg font-bold text-slate-900 leading-tight mb-3" x-text="title || 'Gig Title'"></h3>
                
                <p class="text-sm text-slate-500 line-clamp-3 mb-6" x-text="description || 'Provide a detailed description of the micro-task here...'"></p>
                
                <div class="border-t border-slate-100 pt-5 pb-5">
                    <div class="text-3xl font-extrabold text-slate-900">
                        &#8377;<span x-text="budget || '0'"></span>
                    </div>
                </div>
                
                <div class="bg-slate-50 rounded-xl p-4 border border-slate-100 text-sm">
                    <div x-show="!hasTimeline" class="font-medium text-slate-600 flex items-center justify-center gap-2">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        Flexible Timeline
                    </div>
                    
                    <div x-show="hasTimeline" style="display: none;" class="space-y-3">
                        <div class="flex justify-between items-center pb-3 border-b border-slate-200">
                            <span class="text-slate-500 text-xs font-semibold uppercase">App Deadline</span>
                            <span class="font-bold text-slate-800" x-text="appDeadline ? new Date(appDeadline).toLocaleDateString('en-GB', {day: 'numeric', month: 'short', year: 'numeric'}) : '--'"></span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-slate-500 text-xs font-semibold uppercase">Completion</span>
                            <span class="font-bold text-slate-800" x-text="compDeadline ? new Date(compDeadline).toLocaleDateString('en-GB', {day: 'numeric', month: 'short', year: 'numeric'}) : '--'"></span>
                        </div>
                    </div>
                </div>
                
                <div class="mt-4 flex justify-between items-center px-1">
                    <span class="text-xs font-semibold text-emerald-600">OPEN</span>
                    <span class="text-xs font-medium text-slate-400">Just now</span>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
