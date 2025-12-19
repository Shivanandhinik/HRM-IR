<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.hrm.util.DBConnection" %>
<%@ page import="com.hrm.model.Member" %>

<%
    
    String pageMode = (String) request.getAttribute("pageMode");

    boolean showDashboard = (pageMode == null);     
    boolean showList      = "list".equals(pageMode);
    boolean showForm      = "form".equals(pageMode);

    // --- committee info from servlet (for list / form modes) ---
    Integer committeeIdObj = (Integer) request.getAttribute("committeeId");
    if (committeeIdObj == null && request.getParameter("committeeId") != null) {
        try { committeeIdObj = Integer.parseInt(request.getParameter("committeeId")); }
        catch (NumberFormatException e) { committeeIdObj = 0; }
    }
    int committeeId = (committeeIdObj == null) ? 0 : committeeIdObj;

    String committeeName = (String) request.getAttribute("committeeName");
    if (committeeName == null) committeeName = "";

    List<Member> members = (List<Member>) request.getAttribute("members");

    Member member = (Member) request.getAttribute("member");
    if (member == null) {
        member = new Member();   // empty when Add
        member.setCommitteeId(committeeId);
    }
    boolean isEdit = (member.getId() != 0);
%>

<!DOCTYPE html>
<html>
<head>
    <title>HR – Forum Members</title>

    <style>
        body {
            margin: 0;
            font-family: "Times New Roman", Arial, sans-serif;
            background: #d7ecff;
        }

        /* ===== HEADER + NAV ===== */
        .header-bar {
    background: #0077c7;
    padding: 15px 40px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
       .header-title {
    color: white;
      font-size: 2rem;
      font-weight: 600;
      letter-spacing: 1px;
      transition: transform 0.3s;
}
.header-title:hover {
      transform: scale(1.05);
    }

        .navbar {
    display: flex;
    gap: 25px;
}
        .navbar a {
   text-decoration: none;
      color: white;
      font-size: 20px;
      position: relative;
      padding: 5px 0;
      transition: color 0.3s;
}
      .navbar a::after {
      content: '';
      display: block;
      height: 2px;
      width: 0;
      background: white;
      transition: width 0.3s ease-in-out;
      position: absolute;
      bottom: 0;
      left: 0;
    }

    .navbar a:hover {
      color: white;
    }

    .navbar a:hover::after {
      width: 100%;
    }

        .page-wrapper {
            padding: 25px 50px 60px;
        }

        /* ===== DASHBOARD TITLE & CARDS ===== */
        .big-title {
            font-size: 30px;
            font-weight: bold;
            color: #c5004f;
            margin-bottom: 25px;
        }

        .cards-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(260px, 1fr));
            gap: 25px;
            position:center;
        }
       
        .card {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.06);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            padding: 20px 22px;
            min-height: 230px;
            display: flex;
            flex-direction: column;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 25px rgba(0, 0, 0, 0.1);
        }
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 14px;
        }
        .card-title {
            font-weight: bold;
            color: #c5004f;
            font-size: 22px;
        }
        .card-toggle {
            font-size: 18px;
            color: #c5004f;
        }
        .card-body {
            font-size: 18px;
            line-height: 1.6;
        }
        .card-body a {
            display: block;
            text-decoration: none;
            color: #1a0dab;
            margin-bottom: 6px;
        }
        .card-body a:hover {
            text-decoration: underline;
        }

        /* ===== COMMITTEE MEMBERS HEADER ===== */
        .top-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
        }
        .page-title {
            font-size: 35px;
            color: #444;
        }
        .page-subtitle {
            font-size: 40px;
            color: #c5004f;
            font-weight: bold;
        }
        .top-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .search-box input {
            padding: 6px 10px;
            border-radius: 6px;
            border: 1px solid #ccc;
            min-width: 220px;
        }
        .btn-add {
            padding: 7px 14px;
            border-radius: 6px;
            background: #102e81;
            color: #fff;
            border: none;
            text-decoration: none;
            font-size: 14px;
        }
        .btn-add:hover { opacity: 0.9;
         background: #2101d6;
    transform: translateY(-3px);
    box-shadow: 0 8px 20px rgba(0,0,0,0.25) }

       .back-btn {
    position: fixed;
    bottom: 25px;
    right: 25px;
    background: #102e81;
    color: #fff;
    padding: 12px 18px;
    border-radius: 25px;
    text-decoration: none;
    font-size: 15px;
    font-weight: bold;
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    transition: 0.3s ease;
    z-index: 999;
}

.back-btn:hover {
    background: #2101d6;
    transform: translateY(-3px);
    box-shadow: 0 8px 20px rgba(0,0,0,0.25);
}

        /* ===== MEMBER LIST CARDS ===== */
       .member-card {
    background: #ffffff;
    border-radius: 12px;
    box-shadow: 0 3px 10px rgba(0,0,0,0.06);
    padding: 15px;
    display: flex;
    gap: 20px;
    align-items: flex-start;
    border-left: 5px solid #d4145a;   /* left highlight same as union cards */
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.member-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 12px 25px rgba(0, 0, 0, 0.1);
}


        .member-photo {
	    width: 90px;
	    height: 105px;
	    border-radius: 8px;
	    overflow: hidden;
	    flex-shrink: 0;
	    border: 1px solid #ddd;
	    background: #f0f0f0;
	    display: flex;
	    align-items: center;
	    justify-content: center;
	}

.member-photo img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}
       .member-details {
    flex: 1;
    font-size: 17px;
    line-height: 1.5;
}

.member-name {
    font-weight: bold;
    font-size: 25px;
    color: #1223b8;
}
       .member-role {
    font-size: 20px;
    color: #d4145a;
}

 .member-meta {
    margin-top: 6px;
} 

 .member-meta div {
    margin-bottom: 2px;
} 

       .member-actions {
    text-align: right;
    font-size: 12px;
    margin-top: 5px;
}

.member-actions a {
    text-decoration: none;
    margin-left: 8px;
    color: #1a0dab;
}

.member-actions a.delete {
    color: #c5004f;
}

        .no-data {
            margin-top: 25px;
            font-size: 14px;
            color: #555;
        }

        /* ===== FORM CARD ===== */
        .form-wrapper {
            display: flex;
            justify-content: center;
            align-items: flex-start;
        }
        .form-card {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.10);
            padding: 22px 26px 26px;
            max-width: 650px;
            width: 100%;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .form-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 26px rgba(0,0,0,0.16);
        }
        h2.form-title {
            margin-top: 0;
            margin-bottom: 14px;
            color: #c5004f;
        }
        .form-row { margin-bottom: 12px; }
        .form-row label {
            display: block;
            font-size: 13px;
            margin-bottom: 3px;
            color: #333;
        }
        .form-row input[type="text"],
        .form-row input[type="file"] {
            width: 100%;
            padding: 7px 9px;
            border-radius: 8px;
            border: 1px solid #c4c4c4;
            font-size: 13px;
            box-sizing: border-box;
            transition: border-color 0.15s ease, box-shadow 0.15s ease;
            background-color: #fafafa;
        }
        .form-row input[type="text"]:focus,
        .form-row input[type="file"]:focus {
            outline: none;
            border-color: #ff007a;
            box-shadow: 0 0 0 2px rgba(255,0,122,0.15);
            background-color: #ffffff;
        }
        .current-photo {
            font-size: 12px;
            color: #555;
            margin-top: 4px;
        }
        .btn-row {
            margin-top: 18px;
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        .btn {
            padding: 8px 18px;
            border-radius: 20px;
            border: none;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 0.3px;
            transition: transform 0.15s ease, box-shadow 0.15s ease, opacity 0.15s ease;
        }
        .btn-save {
            background: linear-gradient(135deg, #c5004f);
            color: #fff;
            box-shadow: 0 4px 10px rgba(255,0,122,0.35);
        }
        .btn-save:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(255,0,122,0.45);
        }
        .btn-cancel {
            background: #e0e0e0;
            color: #333;
        }
        .btn-cancel:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }

        @media (max-width: 992px) {
            .cards-grid { grid-template-columns: repeat(2, minmax(260px, 1fr)); }
        }
        @media (max-width: 768px) {
            .cards-grid { grid-template-columns: 1fr; }
            .page-wrapper { padding: 20px 15px 40px; }
        }
    </style>

    <script>
        // filter for MEMBERS LIST
        function filterMembers() {
            var input = document.getElementById("searchInput");
            if (!input) return;
            var filter = input.value.toLowerCase();
            var cards = document.getElementsByClassName("member-card");

            for (var i = 0; i < cards.length; i++) {
                var text = cards[i].innerText.toLowerCase();
                cards[i].style.display = text.indexOf(filter) > -1 ? "" : "none";
            }
        }
    </script>
</head>
<body>

<div class="header-bar">
    <div class="header-title">HUMAN RESOURCE MANAGEMENT</div>

    <div class="navbar">
        <a href="<%=request.getContextPath()%>/homepage.jsp">Home</a>
        <a href="<%=request.getContextPath()%>/ir/members.jsp" class="active">Members</a>
        <a href="<%=request.getContextPath()%>/ir/forum.jsp">Forum</a>
        <a href="<%=request.getContextPath()%>/login.jsp">Logout</a>
    </div>
</div>

<div class="page-wrapper">

<%-- ===================== DASHBOARD MODE ===================== --%>
<% if (showDashboard) { %>

    <div class="big-title">FORUM MEMBERS</div>

    <div class="cards-grid">
    <%
        Connection con = null;
        PreparedStatement psCat = null;
        PreparedStatement psComm = null;
        ResultSet rsCat = null;
        ResultSet rsComm = null;

        try {
            con = DBConnection.getConnection();

            psCat = con.prepareStatement(
                "SELECT category_id, category_name " +
                "FROM member_committee_category " +
                "ORDER BY display_order"
            );
            rsCat = psCat.executeQuery();

            while (rsCat.next()) {
                int catId = rsCat.getInt("category_id");
                String catName = rsCat.getString("category_name");
    %>
        <div class="card">
            <div class="card-header">
                <div class="card-title"><%= catName %></div>
                <div class="card-toggle">&#9660;</div>
            </div>
            <div class="card-body">
                <%
                    psComm = con.prepareStatement(
                        "SELECT committee_id, committee_name " +
                        "FROM member_committee " +
                        "WHERE category_id = ? " +
                        "ORDER BY display_order"
                    );
                    psComm.setInt(1, catId);
                    rsComm = psComm.executeQuery();

                    while (rsComm.next()) {
                        int commId = rsComm.getInt("committee_id");
                        String commName = rsComm.getString("committee_name");
                %>
                    <a href="<%=request.getContextPath()%>/membersManage?action=list&committeeId=<%=commId%>">
                        <%= commName %>
                    </a>
                <%
                    }
                    rsComm.close();
                    psComm.close();
                %>
            </div>
           
        </div>
    <%
            } // end while rsCat
        } catch(Exception e) {
    %>
        <p style="color:red;">
            Error loading categories: <%= e.getMessage() %>
        </p>
    <%
        } finally {
            if (rsComm != null) try { rsComm.close(); } catch(Exception ex) {}
            if (psComm != null) try { psComm.close(); } catch(Exception ex) {}
            if (rsCat != null) try { rsCat.close(); } catch(Exception ex) {}
            if (psCat != null) try { psCat.close(); } catch(Exception ex) {}
            if (con != null)    try { con.close(); }    catch(Exception ex) {}
        }
    %>
    </div> <!-- .cards-grid -->

<%-- ===================== MANAGE (LIST / FORM) MODE ===================== --%>
<% } else { %>

    <a class="back-btn" href="<%=request.getContextPath()%>/ir/members.jsp">
    ⬅ Back to Forum Members
	</a>

    <div class="top-row">
        <div>
            <div class="page-subtitle">
                <%
                    if (!committeeName.isEmpty()) {
                %>
                    <%= committeeName %>
                <%
                    } else {
                %>
                    Members for Committee ID: <%= committeeId %>
                <%
                    }
                %>
            </div>
            <div class="page-title">Representatives</div>
        </div>

        <% if (showList) { %>
        <div class="top-actions">
            <div class="search-box">
                <input type="text" id="searchInput" placeholder="Search members..."
                       onkeyup="filterMembers()">
            </div>
            <a class="btn-add"
               href="<%=request.getContextPath()%>/membersManage?action=new&committeeId=<%= committeeId %>">
                + Add Member
            </a>
        </div>
        <% } %>
    </div>

    <%-- ===== LIST SECTION ===== --%>
    <% if (showList) { %>
        <%
            if (members == null || members.isEmpty()) {
        %>
            <div class="no-data">
                No members added yet for this committee.
                Click <strong>+ Add Member</strong> to create the first entry.
            </div>
        <%
            } else {
        %>
            <div class="cards-grid">
                <%
                    for (Member m : members) {
                        String photoPath = m.getPhotoPath();
                %>
                <div class="member-card">
                    <div class="member-photo">
                        <%
                            if (photoPath != null && !photoPath.trim().isEmpty()) {
                        %>
                            <img src="<%=request.getContextPath()%>/<%=photoPath%>" alt="Photo">
                        <%
                            } else {
                        %>
                            <span>Photo</span>
                        <%
                            }
                        %>
                    </div>
					
                    <div class="member-details">
                        <div class="member-name"><%= m.getName() %></div>
                        <div class="member-role">
                            <%= m.getRoleTitle() == null ? "" : m.getRoleTitle() %>
                        </div>

                        <div class="member-meta">
                            <div>Staff No.: <%= m.getStaffNo() == null ? "" : m.getStaffNo() %></div>
                            <div>Designation: <%= m.getDesignation() == null ? "" : m.getDesignation() %></div>
                            <div>Department: <%= m.getDepartment() == null ? "" : m.getDepartment() %></div>
                            <div>Office No.: <%= m.getOfficeNo() == null ? "" : m.getOfficeNo() %></div>
                            <div>Phone: <%= m.getPhone() == null ? "" : m.getPhone() %></div>
                        </div>

                        <div class="member-actions">
                            <a href="<%=request.getContextPath()%>/membersManage?action=edit&id=<%=m.getId()%>&committeeId=<%=committeeId%>">
                                Edit
                            </a>
                            <a class="delete"
                               href="<%=request.getContextPath()%>/membersManage?action=delete&id=<%=m.getId()%>&committeeId=<%=committeeId%>"
                               onclick="return confirm('Delete this member?');">
                                Delete
                            </a>
                        </div>
                    </div>
                 
                </div>
                <%
                    } 
                %>
            </div>
        <%
            } 
        %>
    <% } %>

    <%-- ===== FORM SECTION (ADD / EDIT) ===== --%>
    <% if (showForm) { %>
    <div class="form-wrapper">
        <div class="form-card">
            <h2 class="form-title"><%= isEdit ? "Edit Member" : "Add Member" %></h2>

            <form method="post"
                  action="<%=request.getContextPath()%>/membersManage"
                  enctype="multipart/form-data">

                <input type="hidden" name="committeeId" value="<%= committeeId %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%=member.getId()%>">
                <% } %>
                <input type="hidden" name="existingPhotoPath"
                       value="<%=member.getPhotoPath() == null ? "" : member.getPhotoPath()%>">

                <div class="form-row">
                    <label>Name</label>
                    <input type="text" name="name"
                           value="<%=member.getName() == null ? "" : member.getName()%>" required>
                </div>

                <div class="form-row">
                    <label>Position</label>
                    <input type="text" name="roleTitle"
                           value="<%=member.getRoleTitle() == null ? "" : member.getRoleTitle()%>">
                </div>

                <div class="form-row">
                    <label>Staff No.</label>
                    <input type="text" name="staffNo"
                           value="<%=member.getStaffNo() == null ? "" : member.getStaffNo()%>">
                </div>

                <div class="form-row">
                    <label>Designation</label>
                    <input type="text" name="designation"
                           value="<%=member.getDesignation() == null ? "" : member.getDesignation()%>">
                </div>

                <div class="form-row">
                    <label>Department</label>
                    <input type="text" name="department"
                           value="<%=member.getDepartment() == null ? "" : member.getDepartment()%>">
                </div>

                <div class="form-row">
                    <label>Office No.</label>
                    <input type="text" name="officeNo"
                           value="<%=member.getOfficeNo() == null ? "" : member.getOfficeNo()%>">
                </div>

                <div class="form-row">
                    <label>Phone</label>
                    <input type="text" name="phone"
                           value="<%=member.getPhone() == null ? "" : member.getPhone()%>">
                </div>

                <div class="form-row">
                    <label>Photo (upload from PC)</label>
                    <input type="file" name="photoFile" accept="image/*">
                    <% if (member.getPhotoPath() != null && !member.getPhotoPath().isEmpty()) { %>
                        <div class="current-photo">
                            Current: <%= member.getPhotoPath() %>
                        </div>
                
                    <% } %>
                </div>

                <div class="btn-row">
                    <button type="submit" class="btn btn-save">Save</button>
                    <a class="btn btn-cancel"
                       href="<%=request.getContextPath()%>/membersManage?action=list&committeeId=<%=committeeId%>">
                        Cancel
                    </a>
                </div>

            </form>
        </div>
    </div>
    <% } %>

<% } %> <%-- end MANAGE vs DASHBOARD --%>

</div> <!-- /page-wrapper -->

</body>
</html>
