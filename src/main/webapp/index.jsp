<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<jsp:include page="header.jsp" />

<div class="flex flex-col items-center justify-center min-h-[75vh] text-center w-full relative" x-data="{ loaded: false }" x-init="setTimeout(() => loaded = true, 100)">
    
    <!-- Decorative background elements -->
    <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-blue-400/10 rounded-full blur-3xl -z-10 pointer-events-none"></div>
    <div class="absolute bottom-1/4 right-1/4 w-[30rem] h-[30rem] bg-pink-400/10 rounded-full blur-3xl -z-10 pointer-events-none"></div>

    <!-- Announcement Pill -->
    <div class="mb-8 transition-all duration-700 transform" :class="loaded ? 'translate-y-0 opacity-100' : '-translate-y-4 opacity-0'">
        <span class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-blue-50 border border-blue-200 text-blue-700 text-sm font-semibold shadow-sm">
            <span class="w-2 h-2 rounded-full bg-blue-600 animate-pulse"></span>
            CampusGig 2.0 is live
        </span>
    </div>

    <!-- Headline -->
    <h1 class="text-6xl md:text-7xl font-extrabold text-slate-900 tracking-tight mb-6 transition-all duration-700 delay-100 transform" :class="loaded ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'">
        Find. <span class="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-indigo-600">Work.</span> Grow.
    </h1>
    
    <!-- Description -->
    <p class="text-xl text-slate-500 max-w-2xl mx-auto mb-10 transition-all duration-700 delay-200 transform leading-relaxed" :class="loaded ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'">
        The premium marketplace for university students. Discover paid micro-tasks, build your portfolio, and collaborate on campus.
    </p>

    <!-- CTAs -->
    <div class="flex flex-col sm:flex-row gap-4 mb-20 transition-all duration-700 delay-300 transform" :class="loaded ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'">
        <a href="browse-gigs" class="btn-primary px-8 py-3.5 rounded-full text-base font-semibold shadow-lg shadow-blue-500/20">Explore Gigs</a>
        <a href="post-gig.jsp" class="btn-secondary px-8 py-3.5 rounded-full text-base font-semibold">Post a Gig</a>
    </div>

    <!-- Floating Cards -->
    <div class="w-full max-w-5xl grid grid-cols-1 md:grid-cols-3 gap-6 transition-all duration-1000 delay-500 transform relative z-10" :class="loaded ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'">
        
        <div class="glass-card p-6 text-left animate-[bounce_6s_ease-in-out_infinite] hover:pause" style="animation-delay: 0s;">
            <div class="text-[10px] font-bold tracking-wider text-pink-600 mb-2 uppercase">Design</div>
            <h3 class="text-lg font-bold text-slate-900 leading-tight mb-4">Campus Event Poster</h3>
            <div class="flex justify-between items-end">
                <div class="text-xl font-extrabold text-slate-800">&#8377;900</div>
                <div class="text-xs font-medium text-slate-500">2 days left</div>
            </div>
        </div>

        <div class="glass-card p-6 text-left animate-[bounce_7s_ease-in-out_infinite] hover:pause" style="animation-delay: 1s;">
            <div class="text-[10px] font-bold tracking-wider text-blue-600 mb-2 uppercase">Development</div>
            <h3 class="text-lg font-bold text-slate-900 leading-tight mb-4">Build Student Portal</h3>
            <div class="flex justify-between items-end">
                <div class="text-xl font-extrabold text-slate-800">&#8377;3,000</div>
                <div class="text-xs font-medium text-slate-500">5 applications</div>
            </div>
        </div>

        <div class="glass-card p-6 text-left animate-[bounce_8s_ease-in-out_infinite] hover:pause" style="animation-delay: 2s;">
            <div class="text-[10px] font-bold tracking-wider text-emerald-600 mb-2 uppercase">Tutoring</div>
            <h3 class="text-lg font-bold text-slate-900 leading-tight mb-4">Python Tutor</h3>
            <div class="flex justify-between items-end">
                <div class="text-xl font-extrabold text-slate-800">&#8377;1,500</div>
                <div class="text-xs font-medium text-slate-500">Flexible timeline</div>
            </div>
        </div>

    </div>
</div>

<style>
    @keyframes bounce {
        0%, 100% { transform: translateY(0); }
        50% { transform: translateY(-8px); }
    }
    .hover\:pause:hover {
        animation-play-state: paused;
    }
</style>

<jsp:include page="footer.jsp" />
