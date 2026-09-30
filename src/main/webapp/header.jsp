<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    String role = (String) session.getAttribute("userRole");
    String userName = (String) session.getAttribute("userName");
    String uri = request.getRequestURI();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CampusGig</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #fafafa;
            background-image: 
                radial-gradient(circle at 0% 0%, rgba(59, 130, 246, 0.08), transparent 40%),
                radial-gradient(circle at 100% 100%, rgba(59, 130, 246, 0.05), transparent 40%);
            background-attachment: fixed;
            color: #334155;
            margin: 0;
            padding: 0;
            min-height: 100vh;
        }
        
        .floating-nav {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(226, 232, 240, 0.8);
            border-radius: 20px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
            transition: all 0.3s ease;
        }
        
        .nav-item {
            color: #64748b;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .nav-item:hover {
            color: #0f172a;
        }
        
        .nav-item.active {
            color: #1d4ed8;
            background: #eff6ff;
            border-radius: 9999px;
            font-weight: 600;
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(15, 23, 42, 0.06);
            border-radius: 20px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.02);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .glass-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 30px -5px rgba(0, 0, 0, 0.04);
            border-color: rgba(59, 130, 246, 0.1);
        }

        .btn-primary {
            background-color: #2563eb;
            color: white;
            transition: all 0.2s ease;
        }
        
        .btn-primary:hover {
            background-color: #1d4ed8;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
        }

        .btn-secondary {
            background: rgba(255,255,255,0.9);
            color: #334155;
            border: 1px solid #e2e8f0;
            transition: all 0.2s ease;
        }
        
        .btn-secondary:hover {
            background: white;
            color: #0f172a;
            border-color: #cbd5e1;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }
    </style>
</head>
<body class="antialiased flex flex-col items-center">

<!-- Top Navigation -->
<header class="w-full max-w-6xl mx-auto px-4 mt-6 z-50 sticky top-6">
    <div class="floating-nav px-6 py-3 flex items-center justify-between">
        <div class="flex items-center gap-8">
            <a href="index.jsp" class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center shadow-sm">
                    <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                </div>
                <span class="text-xl font-bold text-slate-900 tracking-tight">CampusGig</span>
            </a>
            
            <% if (role != null) { %>
            <nav class="hidden md:flex items-center gap-1">
                <% if ("student".equals(role)) { %>
                    <a href="student-dashboard.jsp" class="nav-item px-4 py-2 text-sm <%= uri.contains("student-dashboard") ? "active" : "" %>">Dashboard</a>
                    <a href="browse-gigs" class="nav-item px-4 py-2 text-sm <%= uri.contains("browse") ? "active" : "" %>">Explore Gigs</a>
                    <a href="my-applications" class="nav-item px-4 py-2 text-sm <%= uri.contains("my-app") ? "active" : "" %>">My Applications</a>
                    <a href="student-profile.jsp" class="nav-item px-4 py-2 text-sm <%= uri.contains("profile") ? "active" : "" %>">My Profile</a>
                <% } else { %>
                    <a href="poster-dashboard.jsp" class="nav-item px-4 py-2 text-sm <%= uri.contains("poster-dashboard") ? "active" : "" %>">Dashboard</a>
                    <a href="post-gig.jsp" class="nav-item px-4 py-2 text-sm <%= uri.contains("post-gig") ? "active" : "" %>">Create Gig</a>
                    <a href="poster-dashboard.jsp" class="nav-item px-4 py-2 text-sm">My Gigs</a>
                <% } %>
            </nav>
            <% } %>
        </div>

        <div class="flex items-center gap-4">
            <% if (role == null) { %>
                <a href="login.jsp" class="text-sm font-medium text-slate-600 hover:text-slate-900 transition-colors hidden sm:block">Log in</a>
                <a href="login.jsp" class="btn-primary px-4 py-2 rounded-full text-sm font-semibold">Sign Up</a>
            <% } else { %>
                <button class="relative p-2 text-slate-400 hover:text-slate-600 transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path></svg>
                    <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full border-2 border-white"></span>
                </button>
                
                <div class="h-8 w-px bg-slate-200 hidden sm:block"></div>
                
                <div class="hidden sm:flex items-center gap-3">
                    <div class="text-right">
                        <div class="text-sm font-semibold text-slate-900 leading-none"><%= userName %></div>
                        <div class="text-xs text-slate-500 mt-0.5 capitalize"><%= role %></div>
                    </div>
                    <div class="w-9 h-9 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center font-bold shadow-sm">
                        <%= userName.substring(0,1).toUpperCase() %>
                    </div>
                </div>
                
                <a href="logout" class="text-xs font-semibold text-slate-500 hover:text-red-600 transition-colors ml-2 hidden sm:block">Logout</a>
                
                <!-- Mobile Menu Button -->
                <button class="md:hidden p-2 text-slate-600">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
                </button>
            <% } %>
        </div>
    </div>
</header>

<!-- Main Container -->
<main class="w-full max-w-6xl mx-auto px-4 mt-12 mb-20 flex-1">
    
    <% String msg = request.getParameter("message"); String err = request.getParameter("error"); %>
    <% if(msg != null) { %>
        <div class="mb-8 p-4 rounded-xl bg-emerald-50 border border-emerald-100 text-emerald-700 text-sm font-medium flex items-center gap-2 max-w-2xl mx-auto shadow-sm">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
            <%= msg.replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;") %>
        </div>
    <% } %>
    <% if(err != null) { %>
        <div class="mb-8 p-4 rounded-xl bg-red-50 border border-red-100 text-red-700 text-sm font-medium flex items-center gap-2 max-w-2xl mx-auto shadow-sm">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            <%= err.replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;") %>
        </div>
    <% } %>
