<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>IR Portal — Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    
      <style>
        :root{
            --primary:#0b63a8;
            --primary-dark:#084b78;
            --muted:#7b8aa3;
            --card:#ffffff;
            --radius:14px;
            --glass: rgba(255,255,255,0.75);
        }

        *{box-sizing:border-box}
        body{
            margin:0;
            font-family: 'Poppins', system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
            background:
                linear-gradient(180deg, rgba(6,35,78,0.06), rgba(6,35,78,0.02)),
                url('images/bg.jpg') center/cover no-repeat;
            min-height:100vh;
            display:flex;
            align-items:center;
            justify-content:center;
            padding:30px;
        }

        /* centered layout */
        .login-wrap{
            width:100%;
            max-width:980px;
            display:grid;
            grid-template-columns: 1fr 420px;
            gap:30px;
            align-items:center;
        }

        /* left promotional area (matches your site look) */
        .promo {
            background: linear-gradient(180deg,var(--glass), rgba(255,255,255,0.9));
            border-radius: var(--radius);
            padding: 36px;
            box-shadow: 0 8px 30px rgba(5,24,60,0.12);
            display:flex;
            flex-direction:column;
            gap:18px;
            min-height:360px;
            justify-content:center;
        }
        .brand {
            display:flex;
            gap:14px;
            align-items:center;
        }
        .brand img{
            width:72px;
            height:72px;
            object-fit:contain;
            border-radius:10px;
            background:white;
            padding:6px;
            box-shadow:0 6px 18px rgba(6,35,78,0.08);
        }
        .brand h1{
            font-size:25px;
            margin:0;
            color:var(--primary-dark);
            letter-spacing:1px;
        }
        .promo h2{
            margin:6px 0 0;
            font-size:35px;
            color:var(--primary);
            text-align:center;
        }
        .promo p{
            margin:0;
            color:var(--muted);
            line-height:1.5;
            font-size:14px;
        }

        /* login card */
        .card {
            background: linear-gradient(180deg, #fff, #fcfcff);
            border-radius: var(--radius);
            padding:28px;
            box-shadow: 0 10px 30px rgba(6,35,78,0.12);
        }

        .card h3{
            margin:0 0 12px 0;
            color:var(--primary-dark);
            font-size:20px;
        }

        .field {
            margin-bottom:14px;
        }
        label{
            display:block;
            font-size:13px;
            color:#31415a;
            margin-bottom:6px;
            font-weight:600;
        }
        input[type="text"], input[type="password"]{
            width:100%;
            padding:12px 14px;
            border-radius:10px;
            border:1px solid #d6dcef;
            font-size:15px;
            background: #fbfdff;
            outline:none;
            transition: box-shadow .15s, border-color .15s;
        }
        input[type="text"]:focus, input[type="password"]:focus{
            border-color:var(--primary);
            box-shadow:0 6px 18px rgba(11,99,168,0.12);
        }

        .actions {
            display:flex;
            gap:12px;
            align-items:center;
            justify-content:space-between;
            margin-top:10px;
        }
        .btn {
            background:var(--primary);
            color:white;
            border:none;
            padding:11px 16px;
            font-weight:700;
            border-radius:10px;
            cursor:pointer;
            font-size:15px;
            transition: transform .08s ease, background .12s;
        }
        .btn:hover{ transform: translateY(-2px); background: var(--primary-dark); }
        .btn.secondary{
            background:transparent;
            color:var(--primary);
            border:1px solid #cfe6fb;
            font-weight:600;
        }

        .small {
            font-size:13px;
            color:#5b6b84;
        }

        .error {
            background:#fff3f3;
            color:#8b1e1e;
            padding:10px 12px;
            border-radius:8px;
            border:1px solid #f2c6c6;
            margin-bottom:12px;
            font-size:13px;
        }

        .forgot {
            text-decoration:none;
            color:var(--primary);
            font-size:13px;
        }

        .footer-links {
            margin-top:18px;
            text-align:center;
            font-size:13px;
            color:var(--muted);
        }
        .footer-links a{ color:var(--primary); text-decoration:none; font-weight:600; }

        /* responsive */
        @media (max-width:920px){
            .login-wrap{ grid-template-columns: 1fr; }
            .promo{ order:2; }
        }
    </style>

</head>

<body>

<div class="login-wrap">

    <!-- LEFT PROMO AREA -->
    <div class="promo" aria-hidden="false">
        <div class="brand">
            <img src="images/Logo.png" alt="Company Logo">
            <div>
                <h1>BAP – Industrial Relations</h1>
                <div class="small">Boiler Auxiliaries Plant – Ranipet</div>
            </div>
        </div>

        <h2>Welcome to IR Portal</h2>
        <p></p>
    </div>

    <!-- RIGHT LOGIN CARD -->
    <div class="card" role="main" aria-labelledby="loginTitle">
        <h3 id="loginTitle">Sign in to IR Section</h3>

        <!-- show error -->
        <%
            String err = request.getParameter("error");
            if (err != null) {
        %>
            <div class="error" role="alert">Invalid username or password. Please try again.</div>
        <% } %>

        <form action="LoginServlet" method="post" autocomplete="on" novalidate>

            <div class="field">
                <label for="username">Username</label>
                <input id="username" name="username" type="text" required maxlength="60"
                       placeholder="Enter username">
            </div>

            <div class="field">
                <label for="password">Password</label>
                <input id="password" name="password" type="password" required maxlength="64"
                       placeholder="Enter password">
            </div>

            <div style="display:flex; justify-content:space-between; margin-top:6px;">
                <label style="display:flex; gap:8px;">
                    <input type="checkbox" name="remember"> Remember me
                </label>

                <a class="forgot" href="#">Forgot?</a>
            </div>

            <div class="actions">
                <button type="submit" class="btn">Login</button>
                <a href="homepage.jsp" class="btn secondary" role="button">Back to Home</a>
            </div>

            <div class="footer-links">
                <p class="small">Need help? Contact <a href="mailto:hr@company.com">hr@company.com</a></p>
            </div>

        </form>
    </div>
</div>

</body>
</html>
