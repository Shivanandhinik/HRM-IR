package com.hrm.controller;

import com.hrm.util.DBConnection;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            String sql =
                "SELECT username, role FROM ir_users " +
                "WHERE username=? AND password=? AND status='A'";

            ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);

            rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("username", rs.getString("username"));
                session.setAttribute("role", rs.getString("role"));

                response.sendRedirect(
                    request.getContextPath() + "/ir/ir_dashboard.jsp"
                );
            } else {
                response.sendRedirect(
                    request.getContextPath() + "/login.jsp?error=1"
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                request.getContextPath() + "/login.jsp?error=1"
            );
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/login.jsp")
               .forward(request, response);
    }
}
