package com.hrm.servlet;

import com.hrm.model.Member;
import com.hrm.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths; 
import java.nio.file.StandardCopyOption;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/membersManage")
@MultipartConfig
public class MembersManageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            
            request.getRequestDispatcher("/ir/members.jsp").forward(request, response);
            return;
        }

        switch (action) {
            case "list":
                listMembers(request, response);
                break;
            case "new":
                showForm(request, response, false);
                break;
            case "edit":
                showForm(request, response, true);
                break;
            case "delete":
                deleteMember(request, response);
                break;
            default:
                request.getRequestDispatcher("/ir/members.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        saveMember(request, response);
    }

    /* ---------------- LIST MEMBERS ---------------- */

    private void listMembers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String committeeIdStr = request.getParameter("committeeId");
        int committeeId = 0;
        try {
            committeeId = Integer.parseInt(committeeIdStr);
        } catch (Exception ignored) {}

        List<Member> members = new ArrayList<>();
        String committeeName = "";

        String sqlMembers =
                "SELECT member_id, member_name, role_title, staff_no, " +
                "       designation, department, office_no, phone_no, photo_path " +
                "FROM committee_member " +
                "WHERE committee_id = ? " +
                "ORDER BY display_order NULLS LAST, member_name";

        String sqlCommittee =
                "SELECT committee_name FROM member_committee WHERE committee_id = ?";

        try (Connection con = DBConnection.getConnection()) {

            // committee name
            try (PreparedStatement psC = con.prepareStatement(sqlCommittee)) {
                psC.setInt(1, committeeId);
                try (ResultSet rsC = psC.executeQuery()) {
                    if (rsC.next()) {
                        committeeName = rsC.getString("committee_name");
                    }
                }
            }

            // members
            try (PreparedStatement ps = con.prepareStatement(sqlMembers)) {
                ps.setInt(1, committeeId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Member m = new Member();
                        m.setId(rs.getInt("member_id"));
                        m.setCommitteeId(committeeId);
                        m.setName(rs.getString("member_name"));
                        m.setRoleTitle(rs.getString("role_title"));
                        m.setStaffNo(rs.getString("staff_no"));
                        m.setDesignation(rs.getString("designation"));
                        m.setDepartment(rs.getString("department"));
                        m.setOfficeNo(rs.getString("office_no"));
                        m.setPhone(rs.getString("phone_no"));
                        m.setPhotoPath(rs.getString("photo_path"));
                        members.add(m);
                    }
                }
            }

        } catch (Exception e) {
            throw new ServletException("Error loading members", e);
        }

        request.setAttribute("committeeId", committeeId);
        request.setAttribute("committeeName", committeeName);
        request.setAttribute("members", members);
        request.setAttribute("pageMode", "list");   

        request.getRequestDispatcher("/ir/members.jsp").forward(request, response);
    }

    /* ---------------- SHOW ADD/EDIT FORM ---------------- */

    private void showForm(HttpServletRequest request, HttpServletResponse response, boolean isEdit)
            throws ServletException, IOException {

        String committeeIdStr = request.getParameter("committeeId");
        int committeeId = 0;
        try { committeeId = Integer.parseInt(committeeIdStr); } catch (Exception ignored) {}

        String committeeName = "";
        Member member = new Member();
        member.setCommitteeId(committeeId);

        try (Connection con = DBConnection.getConnection()) {

            // load committee name
            try (PreparedStatement psC = con.prepareStatement(
                    "SELECT committee_name FROM member_committee WHERE committee_id = ?")) {
                psC.setInt(1, committeeId);
                try (ResultSet rsC = psC.executeQuery()) {
                    if (rsC.next()) {
                        committeeName = rsC.getString("committee_name");
                    }
                }
            }

            if (isEdit) {
                String idStr = request.getParameter("id");
                int id = Integer.parseInt(idStr);

                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT member_id, committee_id, member_name, role_title, staff_no," +
                        "       designation, department, office_no, phone_no, photo_path " +
                        "FROM committee_member WHERE member_id = ?")) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            member.setId(rs.getInt("member_id"));
                            member.setCommitteeId(rs.getInt("committee_id"));
                            member.setName(rs.getString("member_name"));
                            member.setRoleTitle(rs.getString("role_title"));
                            member.setStaffNo(rs.getString("staff_no"));
                            member.setDesignation(rs.getString("designation"));
                            member.setDepartment(rs.getString("department"));
                            member.setOfficeNo(rs.getString("office_no"));
                            member.setPhone(rs.getString("phone_no"));
                            member.setPhotoPath(rs.getString("photo_path"));
                            committeeId = member.getCommitteeId();
                        }
                    }
                }
            }

        } catch (Exception e) {
            throw new ServletException("Error loading member form", e);
        }

        request.setAttribute("committeeId", committeeId);
        request.setAttribute("committeeName", committeeName);
        request.setAttribute("member", member);
        request.setAttribute("pageMode", "form");   

        request.getRequestDispatcher("/ir/members.jsp").forward(request, response);
    }

    /* ---------------- SAVE (INSERT / UPDATE) ---------------- */

    private void saveMember(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        int committeeId = Integer.parseInt(request.getParameter("committeeId"));
        String idStr = request.getParameter("id");

        String name        = request.getParameter("name");
        String roleTitle   = request.getParameter("roleTitle");
        String staffNo     = request.getParameter("staffNo");
        String designation = request.getParameter("designation");
        String department  = request.getParameter("department");
        String officeNo    = request.getParameter("officeNo");
        String phone       = request.getParameter("phone");
        String existingPhotoPath = request.getParameter("existingPhotoPath");

        // ----- handle photo upload -----
        String photoUrl = request.getParameter("photoUrl");  

        String photoPath = existingPhotoPath;
        Part photoPart = request.getPart("photoFile");

        if (photoPart != null && photoPart.getSize() > 0) {

            String fileName = System.currentTimeMillis() + "_" +
                    Paths.get(photoPart.getSubmittedFileName()).getFileName().toString();

            String uploadDir = getServletContext().getRealPath("/member_photos");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            File outFile = new File(dir, fileName);
            try (InputStream in = photoPart.getInputStream()) {
                Files.copy(in, outFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }

            photoPath = "member_photos/" + fileName;

        } else if (photoUrl != null && !photoUrl.trim().isEmpty()) {
            photoPath = photoUrl.trim();  // URL stored directly
        }
        
        try (Connection con = DBConnection.getConnection()) {

            if (idStr == null || idStr.isEmpty()) {
                // ---------- INSERT ----------
                String sql =
                        "INSERT INTO committee_member " +
                        " (committee_id, member_name, role_title, staff_no, " +
                        "  designation, department, office_no, phone_no, photo_path, display_order) " +
                        "VALUES (?,?,?,?,?,?,?,?,?, " +
                        " (SELECT NVL(MAX(display_order),0)+1 FROM committee_member WHERE committee_id = ?))";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, committeeId);
                    ps.setString(2, name);
                    ps.setString(3, roleTitle);
                    ps.setString(4, staffNo);
                    ps.setString(5, designation);
                    ps.setString(6, department);
                    ps.setString(7, officeNo);
                    ps.setString(8, phone);
                    ps.setString(9, photoPath);
                    ps.setInt(10, committeeId);
                    ps.executeUpdate();
                }

            } else {
                // ---------- UPDATE ----------
                int id = Integer.parseInt(idStr);
                String sql =
                        "UPDATE committee_member SET " +
                        " committee_id = ?, member_name = ?, role_title = ?, staff_no = ?, " +
                        " designation = ?, department = ?, office_no = ?, phone_no = ?, " +
                        " photo_path = ? " +
                        "WHERE member_id = ?";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, committeeId);
                    ps.setString(2, name);
                    ps.setString(3, roleTitle);
                    ps.setString(4, staffNo);
                    ps.setString(5, designation);
                    ps.setString(6, department);
                    ps.setString(7, officeNo);
                    ps.setString(8, phone);
                    ps.setString(9, photoPath);
                    ps.setInt(10, id);
                    ps.executeUpdate();
                }
            }

        } catch (Exception e) {
            throw new ServletException("Error saving member", e);
        }

        // back to list
        response.sendRedirect(
                request.getContextPath() + "/membersManage?action=list&committeeId=" + committeeId);
    }

    /* ---------------- DELETE ---------------- */

    private void deleteMember(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String idStr = request.getParameter("id");
        String committeeIdStr = request.getParameter("committeeId");
        int committeeId = 0;
        try { committeeId = Integer.parseInt(committeeIdStr); } catch (Exception ignored) {}

        if (idStr != null && !idStr.isEmpty()) {
            int id = Integer.parseInt(idStr);
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                         "DELETE FROM committee_member WHERE member_id = ?")) {
                ps.setInt(1, id);
                ps.executeUpdate();
            } catch (Exception e) {
                throw new ServletException("Error deleting member", e);
            }
        }

        response.sendRedirect(
                request.getContextPath() + "/membersManage?action=list&committeeId=" + committeeId);
    }
}
