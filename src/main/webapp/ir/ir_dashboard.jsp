<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>IR Dashboard</title>

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    body {
        margin: 0;
        font-family: times new roman 'Poppins', sans-serif;
        background: #f0f3f9;
    }

    /* NAVBAR */
    .navbar {
        background: #002F6C;
        padding: 15px 40px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        position: sticky;
        top: 0;
        z-index: 10;
        box-shadow: 0 3px 7px rgba(0,0,0,0.25);
    }

    .navbar .title {
        color: white;
        font-size: 25px;
        font-weight: 600;
    }

    .nav-links a {
        color: white;
        text-decoration: none;
        margin-left: 25px;
        font-size: 20px;
        font-weight: 500;
        transition: 0.3s;
    }

    .nav-links a:hover {
        opacity: 0.7;
    }

    .logout-btn {
        background: #c62828;
        padding: 7px 12px;
        border-radius: 6px;
    }

    .logout-btn:hover {
        background: #9e1c1c;
    }

    /* HEADER */
    .header {
        text-align: center;
        padding: 40px 20px;
        background: white;
        animation: fadeSlide 1s ease;
        border-bottom: 2px solid #ddd;
    }

    @keyframes fadeSlide {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .header h1 {
        margin: 0;
        font-size: 70px;
        color: #002F6C;
        font-weight: 700;
    }

    .header p {
        margin-top: 100px;
        font-size: 40px;
        color: #555;
    }

    /* CARDS SECTION */
    .card-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
        gap: 25px;
        padding: 40px 50px;
    }

    .card {
        background: white;
        border-radius: 18px;
        padding: 25px;
        box-shadow: 0 6px 12px rgba(0,0,0,0.1);
        text-align: center;
        cursor: pointer;
        transition: 0.4s;
        transform: translateY(0);
    }

    .card:hover {
        transform: translateY(-8px) scale(1.03);
        box-shadow: 0 10px 20px rgba(0,0,0,0.2);
    }

    .card h3 {
        font-size: 27px;
        margin-bottom: 12px;
        color: #003f80;
    }

    .card p {
        color: #666;
        font-size: 17px;
    }

    /* FOOTER */
    .footer {
        text-align: center;
        padding: 20px;
        margin-top: 40px;
        background: #002F6C;
        color: white;
        font-size: 14px;
    }
</style>

</head>
<body>

<!-- NAVBAR -->
<div class="navbar">
    <div class="title">IR Section</div>

    <div class="nav-links">
        <a href="../homepage.jsp">Home</a>
        <a href="members.jsp">Members</a>
        <a href="forum.jsp">Forum</a>
        <a href="../login.jsp" class="logout-btn">Logout</a>
    </div>
</div>

<!-- HEADER -->
<div class="header">
	
    <h1>HUMAN RESOURCE MANAGEMENT 👋</h1>
    <p>BHEL — BAP Ranipet | Industrial Relations</p>
</div>

<!-- DASHBOARD CARDS -->
<div class="card-container">

    <div class="card" onclick="window.location='public_members.jsp'">
        <h3>Members Directory</h3>
        <p>Forum Members</p>
    </div>

    <div class="card" onclick="window.location='public_forum.jsp'">
        <h3>Forum Minutes</h3>
        <p>Minutes Of Meetings</p>
    </div>

    <div class="card" onclick="window.location='upload_minutes.jsp'">
        <h3>Upload Minutes (PDF)</h3>
        <p>Upload IR meeting minutes with year/month.</p>
    </div>

    <div class="card" onclick="window.location='homepage.jsp'">
        <h3>HRM - IR</h3>
        <p>Manage your login information & activity.</p>
    </div>

</div>

<div class="footer">
    © 2025 BHEL – Industrial Relations, Ranipet | All Rights Reserved
</div>

</body>
</html>
