package com.hrm.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.hrm.util.DBConnection;

@WebServlet("/UploadMinutesServlet")
@MultipartConfig(maxFileSize = 1024 * 1024 * 20) // 20 MB
public class UploadMinutesServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            // --------- 1. Read form fields ---------
            int categoryId    = Integer.parseInt(request.getParameter("category"));   
            int subcategoryId = Integer.parseInt(request.getParameter("subcategory"));
            String title      = request.getParameter("meetingTitle");
            int day           = Integer.parseInt(request.getParameter("day"));
            int month         = Integer.parseInt(request.getParameter("month"));
            int year          = Integer.parseInt(request.getParameter("year"));

            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                throw new ServletException("No file uploaded");
            }

            // --------- 2. Save PDF to /ir/minutes/<year>/ ---------
            String originalName = filePart.getSubmittedFileName();
            String cleanName = (originalName == null ? "minutes.pdf"
                    : originalName.replaceAll("\\s+", "_"));

            // 2025
            String folderPath = getServletContext().getRealPath("/ir/minutes/" + year);
            File folder = new File(folderPath);
            if (!folder.exists()) {
                folder.mkdirs();
            }

            String storedFileName = System.currentTimeMillis() + "_" + cleanName;
            File savedFile = new File(folder, storedFileName);

            try (InputStream in = filePart.getInputStream();
                 FileOutputStream out = new FileOutputStream(savedFile)) {

                byte[] buffer = new byte[4096];
                int len;
                while ((len = in.read(buffer)) != -1) {
                    out.write(buffer, 0, len);
                }
            }

            
            String relativePath = "minutes/" + year + "/" + storedFileName;

            // --------- 3. Insert into FORUM_MINUTES (Oracle) ---------
            try (Connection con = DBConnection.getConnection()) {

                String sql = "INSERT INTO forum_minutes "
                        + "(subcategory_id, year, month_no, day, pdf_path, meeting_title) "
                        + "VALUES (?, ?, ?, ?, ?, ?)";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, subcategoryId);
                    ps.setInt(2, year);
                    ps.setInt(3, month);
                    ps.setString(4, String.format("%02d", day));
                    ps.setString(5, relativePath);
                    ps.setString(6, title);

                    ps.executeUpdate();
                }
            }

            // --------- 4. Redirect back to forum.jsp (view mode) ---------
            
            String ctx = request.getContextPath();
            response.sendRedirect(ctx + "/ir/forum.jsp?year=" + year);

        } catch (Exception e) {
         
            throw new ServletException("Error uploading minutes", e);
        }
    }
}
