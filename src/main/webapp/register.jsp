<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - CampusGig</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #fafafa;
            background-image: radial-gradient(circle at 50% 0%, rgba(59, 130, 246, 0.05), transparent 50%);
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(15, 23, 42, 0.06);
            border-radius: 24px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.02);
        }
    </style>
</head>
<body class="antialiased min-h-screen flex items-center justify-center p-4">

<div class="w-full max-w-md">
    <!-- Logo -->
    <div class="text-center mb-8">
        <a href="index.jsp" class="inline-flex items-center gap-2">
            <div class="w-10 h-10 rounded-full bg-blue-600 flex items-center justify-center shadow-md">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
            </div>
            <span class="text-2xl font-bold text-slate-900 tracking-tight">CampusGig</span>
        </a>
    </div>

    <!-- Register Card -->
    <div class="glass-card p-8">
        <h2 class="text-2xl font-extrabold text-slate-900 text-center mb-2 tracking-tight">Create an account</h2>
        <p class="text-slate-500 text-center text-sm mb-8">Join the premium campus marketplace.</p>

        <% String err = request.getParameter("error"); %>
        <% if(err != null) { %>
            <div class="mb-6 p-3 rounded-xl bg-red-50 border border-red-100 text-red-600 text-sm font-semibold text-center">
                <%= err.replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;") %>
            </div>
        <% } %>

        <form action="register" method="post" class="space-y-4">
            <div>
                <label class="block text-sm font-semibold text-slate-800 mb-1.5">Full Name</label>
                <input type="text" name="name" required class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow" placeholder="John Doe">
            </div>
            
            <div>
                <label class="block text-sm font-semibold text-slate-800 mb-1.5">Email Address</label>
                <input type="email" name="email" required class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow" placeholder="you@university.edu">
            </div>
            
            <div>
                <label class="block text-sm font-semibold text-slate-800 mb-1.5">Password</label>
                <input type="password" name="password" required class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow" placeholder="••••••••">
            </div>
            
            <div>
                <label class="block text-sm font-semibold text-slate-800 mb-1.5">I want to...</label>
                <div class="grid grid-cols-2 gap-3 mt-1">
                    <label class="relative flex items-center justify-center p-3 border border-slate-200 rounded-xl cursor-pointer hover:bg-slate-50 transition-colors has-[:checked]:bg-blue-50 has-[:checked]:border-blue-500 has-[:checked]:text-blue-700">
                        <input type="radio" name="role" value="student" checked class="absolute opacity-0">
                        <span class="text-sm font-bold">Find Work</span>
                    </label>
                    <label class="relative flex items-center justify-center p-3 border border-slate-200 rounded-xl cursor-pointer hover:bg-slate-50 transition-colors has-[:checked]:bg-blue-50 has-[:checked]:border-blue-500 has-[:checked]:text-blue-700">
                        <input type="radio" name="role" value="poster" class="absolute opacity-0">
                        <span class="text-sm font-bold">Post Gigs</span>
                    </label>
                </div>
            </div>
            
            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white py-3 rounded-xl font-bold shadow-md hover:shadow-lg transition-all mt-4">
                Sign Up
            </button>
        </form>
        
        <p class="text-center text-sm text-slate-500 mt-8 font-medium">
            Already have an account? <a href="login.jsp" class="text-blue-600 font-bold hover:underline">Log in</a>
        </p>
    </div>
</div>

</body>
</html>
