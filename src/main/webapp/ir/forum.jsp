<%@ page import="java.sql.*, java.util.*, com.hrm.util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    /* ========================= 0. AJAX FOR SUBCATEGORY (replaces load_subcategory.jsp) ========================= */
    String mode = request.getParameter("mode");
    if ("subcat".equals(mode)) {
        String catId = request.getParameter("cat");
        if (catId != null && !catId.trim().isEmpty()) {
            Connection conSub = null;
            PreparedStatement psSub = null;
            ResultSet rsSub = null;
            try {
                conSub = DBConnection.getConnection();
                psSub = conSub.prepareStatement(
                    "SELECT subcategory_id, forum_name " +
                    "FROM forum_subcategory " +
                    "WHERE category_id = ? " +
                    "ORDER BY display_order"
                );
                psSub.setInt(1, Integer.parseInt(catId));
                rsSub = psSub.executeQuery();
                while (rsSub.next()) {
%>
<option value="<%=rsSub.getInt("subcategory_id")%>">
    <%=rsSub.getString("forum_name")%>
</option>
<%
                }
            } catch (Exception e) {
                // optional: log
            } finally {
                if (rsSub != null) try { rsSub.close(); } catch (Exception ignore) {}
                if (psSub != null) try { psSub.close(); } catch (Exception ignore) {}
                if (conSub != null) try { conSub.close(); } catch (Exception ignore) {}
            }
        }
        return; // IMPORTANT: stop JSP here for AJAX call
    }

    /* ========================= 1. COMMON PARAMS ========================= */

    String section = request.getParameter("section");
    if (section == null) section = "view";   // default section

    String yearParam = request.getParameter("year");
    int year = (yearParam == null || yearParam.isEmpty())
               ? java.util.Calendar.getInstance().get(java.util.Calendar.YEAR)
               : Integer.parseInt(yearParam);

    /* ========================= 2. DATA FOR VIEW MATRIX ========================= */

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // Data structures: for yearly matrix
    Map<Integer, Map<Integer, String>> data = new HashMap<>();
    Map<Integer, String> categories = new LinkedHashMap<>();
    Map<Integer, LinkedHashMap<Integer, String>> subcategories = new LinkedHashMap<>();

    try {
        con = DBConnection.getConnection();

        // ---- minutes for selected year ----
        String sqlMinutes =
            "SELECT subcategory_id, month_no, day, pdf_path " +
            "FROM forum_minutes WHERE year = ?";
        ps = con.prepareStatement(sqlMinutes);
        ps.setInt(1, year);
        rs = ps.executeQuery();

        while (rs.next()) {
            int subId = rs.getInt("subcategory_id");
            int month = rs.getInt("month_no");
            String day = rs.getString("day");
            String file = rs.getString("pdf_path");

            data.putIfAbsent(subId, new HashMap<Integer,String>());
            String link = (file == null || day == null)
                    ? ""
                    : "<a href='" + file + "' target='_blank'>" + day + "</a>";
            data.get(subId).put(month, link);
        }
        rs.close();
        ps.close();

        // ---- categories ----
        String sqlCat =
            "SELECT category_id, category_name " +
            "FROM forum_category ORDER BY display_order";
        ps = con.prepareStatement(sqlCat);
        rs = ps.executeQuery();
        while (rs.next()) {
            int catId = rs.getInt("category_id");
            String name = rs.getString("category_name");
            categories.put(catId, name);
            subcategories.put(catId, new LinkedHashMap<Integer,String>());
        }
        rs.close();
        ps.close();

        // ---- subcategories ----
        String sqlSub =
            "SELECT subcategory_id, category_id, forum_name " +
            "FROM forum_subcategory ORDER BY display_order";
        ps = con.prepareStatement(sqlSub);
        rs = ps.executeQuery();
        while (rs.next()) {
            int subId = rs.getInt("subcategory_id");
            int catId = rs.getInt("category_id");
            String name = rs.getString("forum_name");
            LinkedHashMap<Integer,String> map = subcategories.get(catId);
            if (map != null) {
                map.put(subId, name);
            }
        }

    } catch (Exception e) {
        out.println("DB Error: " + e);
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (con != null) try { con.close(); } catch (Exception ignore) {}
    }

    /* ========================= 3. DATA FOR MANAGE SECTION ========================= */

    String mYearStr = request.getParameter("m_year");       // manage filter year
    String mCatStr  = request.getParameter("category");     // category id
    String mSubStr  = request.getParameter("subcategory");  // subcategory id

    if (mYearStr == null) mYearStr = "";
    if (mCatStr == null)  mCatStr  = "";
    if (mSubStr == null)  mSubStr  = "";

    boolean hasManageFilter = !mYearStr.isEmpty() && !mCatStr.isEmpty() && !mSubStr.isEmpty();

    /* ========================= 4. DATA FOR EDIT SECTION ========================= */

    String idParam = request.getParameter("id");
    boolean isEditSection = "edit".equalsIgnoreCase(section);
    boolean hasEditId = isEditSection && idParam != null && !idParam.trim().isEmpty();

    int editId = 0, editYear = 0, editMonth = 0, editCategoryId = 0, editSubId = 0;
    String editTitle = "", editDay = "", editPdf = "";

    if (hasEditId) {
        Connection conE = null;
        PreparedStatement psE = null;
        ResultSet rsE = null;
        try {
            conE = DBConnection.getConnection();
            String sqlE =
                "SELECT fs.category_id, fm.subcategory_id, fm.meeting_title, " +
                "       fm.year, fm.month_no, fm.day, fm.pdf_path " +
                "FROM forum_minutes fm " +
                "JOIN forum_subcategory fs ON fm.subcategory_id = fs.subcategory_id " +
                "WHERE fm.id = ?";
            psE = conE.prepareStatement(sqlE);
            psE.setInt(1, Integer.parseInt(idParam));
            rsE = psE.executeQuery();
            if (rsE.next()) {
                editId         = Integer.parseInt(idParam);
                editCategoryId = rsE.getInt("category_id");
                editSubId      = rsE.getInt("subcategory_id");
                editTitle      = rsE.getString("meeting_title");
                editYear       = rsE.getInt("year");
                editMonth      = rsE.getInt("month_no");
                editDay        = rsE.getString("day");
                editPdf        = rsE.getString("pdf_path");
            }
        } catch (Exception e) {
            out.println("<!-- Error loading edit record: " + e + " -->");
        } finally {
            if (rsE != null) try { rsE.close(); } catch (Exception ignore) {}
            if (psE != null) try { psE.close(); } catch (Exception ignore) {}
            if (conE != null) try { conE.close(); } catch (Exception ignore) {}
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
<title>Forum Minutes</title>

<style>
body {
    font-family: "Times New Roman", Arial, sans-serif;
    background: #d7ecff;
    margin:0;
}

/* Header Section */
.header-bar {
    color: white;
    background:#0077c7;
    padding: 15px;
    display: flex;
    align-items: center;
    border-bottom: 3px solid #0077c7;
}
.header-bar img { height: 60px; margin-right: 20px; }
.header-title {
    text-align: center;
    width: 100%;
    font-size: 30px;
    font-weight: bold;
    color: White;
    line-height: 1.3;
}

/* Navbar */
.navbar {
    display: flex;
    justify-content: right;
    background: #0077c7;
    padding: 10px;
    gap: 40px;
    border-bottom: 3px solid #005b9a;
}
.navbar a {
    text-decoration: none;
    color: white;
    font-size: 18px;
    position: relative;
    padding: 5px 0;
    transition: color 0.3s;
}
.navbar a:hover {
    color: #ffe600;
    transform: scale(1.05);
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
.navbar a.active::after {
    width: 100%;
}
.navbar a.active {
    font-weight:bold;
}

/* Common title */
.big-title {
    text-align: center;
    font-size: 30px;
    margin-top: 20px;
    color: #003366;
    font-weight: bold;
}

/* Year Controls (View section) */
.year-controls {
    text-align: right;
    margin: 15px 40px;
}
.year-btn {
    padding: 8px 15px;
    background: #0077c7;
    color: white;
    border: none;
    cursor: pointer;
    transition: 0.3s;
    border-radius: 5px;
}
.year-btn:hover { background: #005a96; }
.year-dropdown {
    padding: 7px;
    border-radius: 5px;
    border: 1px solid #0077c7;
}

/* Matrix table */
.forum-table {
    width: 98%;
    margin: 20px auto;
    border-collapse: collapse;
    background: white;
    box-shadow: 0 0 10px #bcd3e6;
}
.forum-table th {
    background: #0077c7;
    padding: 10px;
    color: white;
    border: 1px solid #004f85;
    text-align: center;
}
.forum-table td {
    border: 1px solid #4d88c7;
    padding: 8px;
    text-align: center;
}
.forum-title {
    margin-left: 20px;
    margin-top: 40px;
    font-size: 25px;
    color: #003366;
    font-weight: bold;
}

/* Card Wrapper (for upload / edit) */
.card-wrap {
    max-width: 600px;
    margin: 30px auto 40px;
    background:#fff;
    border-radius:18px;
    padding:25px 30px 30px;
    box-shadow:0 10px 25px rgba(0,0,0,0.08);
}
.card-wrap h2 {
    text-align:center;
    margin-top:0;
    margin-bottom:20px;
    color:#003366;
}

/* Upload / Edit form fields */
.card-wrap label {
    display:block;
    margin-top:10px;
    font-weight:bold;
    color:#003366;
}
.card-wrap input[type="text"],
.card-wrap select,
.card-wrap input[type="file"] {
    width:100%;
    padding:8px;
    margin-top:5px;
    border-radius:8px;
    border:1px solid #b5cce2;
    box-sizing:border-box;
}
.card-wrap button {
    margin-top:20px;
    width:100%;
    padding:10px;
    background:#0077c7;
    color:white;
    border:none;
    border-radius:8px;
    cursor:pointer;
    font-size:14px;
}
.card-wrap button:hover { background:#005a96; }

.row-3 {
    display:flex;
    gap:10px;
    margin-top:5px;
}
.row-3 select { flex:1; }

/* Manage filter row + table */
.filter-row {
    display:flex;
    gap:15px;
    align-items:flex-end;
    margin-top:10px;
    flex-wrap:wrap;
}
.filter-row .col {
    min-width:180px;
}
.manage-table {
    width:100%;
    border-collapse:collapse;
    margin-top:20px;
}
.manage-table th, .manage-table td {
    border:1px solid #b5cce2;
    padding:8px;
    text-align:center;
    font-size:14px;
}
.manage-table th {
    background:#0077c7;
    color:white;
}
.small-link {
    font-size:12px;
    color:#0077c7;
    text-decoration:none;
}
.small-link:hover { text-decoration:underline; }

.info-text {
    font-size:13px;
    color:#555;
    margin-top:10px;
    text-align:center;
}
</style>
</head>
<body>

<!-- ================= HEADER ================= -->
<div class="header-bar">
    <img src="../images/Logo.png">
    <div class="header-title">
        BHARAT HEAVY ELECTRICALS LIMITED<br>
        Boiler Auxiliaries Plant - Ranipet
    </div>
</div>

<!-- ================= NAV BAR ================= -->
<div class="navbar">
    <a href="../homepage.jsp">Home</a>
    <a href="forum.jsp?section=view&year=<%=year%>"   class="<%= "view".equalsIgnoreCase(section)   ? "active" : "" %>">View Forum</a>
    <a href="forum.jsp?section=upload&year=<%=year%>" class="<%= "upload".equalsIgnoreCase(section) ? "active" : "" %>">Upload Forum</a>
    <a href="forum.jsp?section=manage&year=<%=year%>" class="<%= "manage".equalsIgnoreCase(section) ? "active" : "" %>">Edit Forum</a>
    <a href="../login.jsp">Logout</a>
</div>

<div class="big-title">
    <% if ("view".equalsIgnoreCase(section)) { %>
        MINUTES OF MEETINGS - IR Yearly Reports
    <% } else if ("upload".equalsIgnoreCase(section)) { %>
        
    <% } else if ("manage".equalsIgnoreCase(section)) { %>
        
    <% } else if ("edit".equalsIgnoreCase(section)) { %>
        
    <% } %>
</div>

<!-- ================= VIEW SECTION ================= -->
<% if ("view".equalsIgnoreCase(section)) { %>
<div>
    <div class="year-controls">
        <form action="forum.jsp" method="get" style="display:inline;">
            <input type="hidden" name="section" value="view">
            <input type="hidden" name="year" value="<%= year - 1 %>">
            <button class="year-btn">&larr; Previous</button>
        </form>

        <span style="font-size:20px; margin:0 10px; font-weight:bold;"><%= year %></span>

        <form action="forum.jsp" method="get" style="display:inline;">
            <input type="hidden" name="section" value="view">
            <input type="hidden" name="year" value="<%= year + 1 %>">
            <button class="year-btn">Next &rarr;</button>
        </form>

        <form action="forum.jsp" method="get" style="display:inline;">
            <input type="hidden" name="section" value="view">
            <select name="year" class="year-dropdown" onchange="this.form.submit()">
                <% for(int y = 2015; y <= 2045; y++) { %>
                    <option value="<%=y%>" <%= (y==year ? "selected" : "") %>><%=y%></option>
                <% } %>
            </select>
        </form>
    </div>

    <%
    for (Map.Entry<Integer, String> catEntry : categories.entrySet()) {
        int catId = catEntry.getKey();
        String catName = catEntry.getValue();
        LinkedHashMap<Integer, String> subs = subcategories.get(catId);
        if (subs == null || subs.isEmpty()) {
            continue;
        }
    %>

    <div class="forum-title"><%= catName %></div>

    <table class="forum-table">
        <tr>
            <th>SL.NO</th>
            <th>FORUM MINUTES</th>
            <% for (int m = 1; m <= 12; m++) { %>
                <th><%= new java.text.DateFormatSymbols().getShortMonths()[m-1].toUpperCase() %></th>
            <% } %>
        </tr>

        <%
            int sl = 1;
            for (Map.Entry<Integer, String> subEntry : subs.entrySet()) {
                int subId = subEntry.getKey();
                String subName = subEntry.getValue();
        %>
        <tr>
            <td><%= String.format("%02d", sl) %></td>
            <td><%= subName %></td>

            <% for (int m = 1; m <= 12; m++) {
                   String cell = data.getOrDefault(subId, new HashMap<Integer,String>()).get(m);
            %>
                <td><%= (cell == null ? "" : cell) %></td>
            <% } %>
        </tr>
        <%
                sl++;
            }
        %>
    </table>

    <%
    } // end category loop
    %>
</div>
<% } %>

<!-- ================= UPLOAD SECTION ================= -->
<% if ("upload".equalsIgnoreCase(section)) { %>
<div class="card-wrap">
    <h2>Upload IR Minutes</h2>

    <form action="${pageContext.request.contextPath}/UploadMinutesServlet"
          method="post" enctype="multipart/form-data">

        <label for="category">Select Category</label>
        <select name="category" id="category" required onchange="updateSubcategories('category','subcategory')">
            <option value="">-- Select --</option>
            <%
                Connection conU = null;
                PreparedStatement psU = null;
                ResultSet rsU = null;
                try {
                    conU = DBConnection.getConnection();
                    psU = conU.prepareStatement(
                        "SELECT category_id, category_name " +
                        "FROM forum_category ORDER BY display_order"
                    );
                    rsU = psU.executeQuery();
                    while (rsU.next()) {
            %>
                <option value="<%=rsU.getInt("category_id")%>">
                    <%=rsU.getString("category_name")%>
                </option>
            <%
                    }
                } catch(Exception e) {
                    out.println("<!-- Error loading categories: " + e + " -->");
                } finally {
                    if (rsU != null) try { rsU.close(); } catch (Exception ignore) {}
                    if (psU != null) try { psU.close(); } catch (Exception ignore) {}
                    if (conU != null) try { conU.close(); } catch (Exception ignore) {}
                }
            %>
        </select>

        <label for="subcategory">Select Subcategory</label>
        <select name="subcategory" id="subcategory" required>
            <option value="">-- Select --</option>
        </select>

        <label for="title">Meeting Title</label>
        <input type="text" id="title" name="meetingTitle" placeholder="Enter meeting title" required>

        <label>Meeting Date</label>
        <div class="row-3">
            <select name="day" required>
                <option value="">Day</option>
                <% for(int d=1; d<=31; d++){ %>
                    <option value="<%=d%>"><%=d%></option>
                <% } %>
            </select>

            <select name="month" required>
                <option value="">Month</option>
                <%
                    String[] ms = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
                    for(int m=1; m<=12; m++){ %>
                        <option value="<%=m%>"><%=ms[m-1]%></option>
                <% } %>
            </select>

            <select name="year" required>
                <option value="">Year</option>
                <%
                    int cy = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                    for (int y = cy-10; y <= cy+10; y++) {
                %>
                    <option value="<%=y%>" <%= (y==cy ? "selected" : "") %>><%=y%></option>
                <% } %>
            </select>
        </div>

        <label for="pdfFile">Select PDF File</label>
        <input type="file" id="pdfFile" name="file" accept="application/pdf" required>

        <button type="submit">Upload</button>
    </form>
</div>
<% } %>

<!-- ================= EDIT LIST SECTION ================= -->
<% if ("manage".equalsIgnoreCase(section)) { %>
<div class="card-wrap">
    <h2>Edit Forum Minutes</h2>

    <form method="get" action="forum.jsp">
        <input type="hidden" name="section" value="manage">
        <div class="filter-row">
            <div class="col">
                <label>Year</label>
                <select name="m_year" required>
                    <option value="">--Year--</option>
                    <%
                        int cy2 = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                        for (int y = cy2-5; y <= cy2+5; y++) {
                    %>
                    <option value="<%=y%>" <%= String.valueOf(y).equals(mYearStr) ? "selected" : "" %>><%=y%></option>
                    <% } %>
                </select>
            </div>

            <div class="col">
                <label>Category</label>
                <select name="category" id="m_category" onchange="updateSubcategories('m_category','m_subcategory')" required>
                    <option value="">--Category--</option>
                    <%
                        for (Map.Entry<Integer,String> catEntry : categories.entrySet()) {
                            int catId = catEntry.getKey();
                            String catName = catEntry.getValue();
                    %>
                        <option value="<%=catId%>" <%= String.valueOf(catId).equals(mCatStr) ? "selected" : "" %>>
                            <%=catName%>
                        </option>
                    <%
                        }
                    %>
                </select>
            </div>

            <div class="col">
                <label>Subcategory</label>
                <select name="subcategory" id="m_subcategory" required>
                    <option value="">--Subcategory--</option>
                </select>
            </div>

            <div class="col">
                <button type="submit">Load Records</button>
            </div>
        </div>
    </form>

    <%
        if (hasManageFilter) {
            Connection conM = null;
            PreparedStatement psM = null;
            ResultSet rsM = null;
            try {
                conM = DBConnection.getConnection();
                String sqlM =
                    "SELECT fm.id, fm.meeting_title, fm.year, fm.month_no, fm.day, fm.pdf_path " +
                    "FROM forum_minutes fm " +
                    "JOIN forum_subcategory fs ON fm.subcategory_id = fs.subcategory_id " +
                    "WHERE fm.year = ? AND fs.category_id = ? AND fm.subcategory_id = ? " +
                    "ORDER BY fm.year, fm.month_no, fm.day";
                psM = conM.prepareStatement(sqlM);
                psM.setInt(1, Integer.parseInt(mYearStr));
                psM.setInt(2, Integer.parseInt(mCatStr));
                psM.setInt(3, Integer.parseInt(mSubStr));
                rsM = psM.executeQuery();
    %>

    <table class="manage-table">
        <tr>
            <th>ID</th>
            <th>Title</th>
            <th>Month</th>
            <th>Day</th>
            <th>PDF</th>
            <th>Action</th>
        </tr>
        <%
            boolean any = false;
            while (rsM.next()) {
                any = true;
        %>
        <tr>
            <td><%=rsM.getInt("id")%></td>
            <td><%=rsM.getString("meeting_title")%></td>
            <td><%=rsM.getInt("month_no")%></td>
            <td><%=rsM.getString("day")%></td>
            <td>
                <a class="small-link" href="<%=rsM.getString("pdf_path")%>" target="_blank">View</a>
            </td>
            <td>
                <a class="small-link"
                   href="forum.jsp?section=edit&year=<%=mYearStr%>&category=<%=mCatStr%>&subcategory=<%=mSubStr%>&id=<%=rsM.getInt("id")%>">
                    Edit
                </a>
            </td>
        </tr>
        <% } %>
    </table>

    <%
            if (!any) {
    %>
        <p class="info-text">No records found for this selection.</p>
    <%
            }
            } catch (Exception e) {
                out.println("<!-- Manage error: " + e + " -->");
            } finally {
                if (rsM != null) try { rsM.close(); } catch(Exception ig) {}
                if (psM != null) try { psM.close(); } catch(Exception ig) {}
                if (conM != null) try { conM.close(); } catch(Exception ig) {}
            }
        }
    %>
</div>
<% } %>

<!-- ================= EDIT FORM SECTION ================= -->
<% if ("edit".equalsIgnoreCase(section)) { %>
<div class="card-wrap">
    <h2>Edit Forum Minute (ID: <%=editId%>)</h2>

    <p>Current PDF:
        <% if (editPdf != null && !editPdf.isEmpty()) { %>
            <a href="<%=editPdf%>" target="_blank">View</a>
        <% } else { %>
            <span>None</span>
        <% } %>
    </p>

    <form action="<%=request.getContextPath()%>/editMinutes"
          method="post" enctype="multipart/form-data">

        <input type="hidden" name="id" value="<%=editId%>">
        <!-- optional: to return to manage page exactly -->
        <input type="hidden" name="origYear" value="<%=request.getParameter("year") == null ? editYear : Integer.parseInt(request.getParameter("year"))%>">
        <input type="hidden" name="origCategory" value="<%=request.getParameter("category") == null ? editCategoryId : Integer.parseInt(request.getParameter("category"))%>">
        <input type="hidden" name="origSubcategory" value="<%=request.getParameter("subcategory") == null ? editSubId : Integer.parseInt(request.getParameter("subcategory"))%>">

        <label>Category</label>
        <select name="category_id" required>
            <option value="1" <%= editCategoryId==1 ? "selected" : "" %>>PLANT COUNCIL</option>
            <option value="2" <%= editCategoryId==2 ? "selected" : "" %>>SHOP COUNCIL</option>
            <option value="3" <%= editCategoryId==3 ? "selected" : "" %>>IR SECTION CO-ORDINATED FORUMS</option>
            <option value="4" <%= editCategoryId==4 ? "selected" : "" %>>OTHER FORUMS</option>
        </select>

        <label>Subcategory ID (same as forum row id)</label>
        <input type="text" name="subcategory_id" value="<%=editSubId%>" required>

        <label>Meeting Title</label>
        <input type="text" name="title" value="<%=editTitle%>" required>

        <label>Year</label>
        <input type="text" name="year" value="<%=editYear%>" required>

        <label>Month (1-12)</label>
        <input type="text" name="month" value="<%=editMonth%>" required>

        <label>Day (01-31)</label>
        <input type="text" name="day" value="<%=editDay%>" required>

        <label>Replace PDF (optional)</label>
        <input type="file" name="newPdf" accept="application/pdf">

               <button type="submit">Save Changes</button>
    </form>
</div>
<% } %>

<script>
    // Generic function: load subcategories for a given catSelect and subSelect
    function updateSubcategories(catSelectId, subSelectId) {
        const catSel = document.getElementById(catSelectId);
        const subSel = document.getElementById(subSelectId);
        const catId = catSel ? catSel.value : "";

        subSel.innerHTML = '<option value="">--Subcategory--</option>';
        if (!catId) return;

        fetch("forum.jsp?mode=subcat&cat=" + encodeURIComponent(catId))
            .then(res => res.text())
            .then(html => {
                subSel.innerHTML = '<option value="">--Subcategory--</option>' + html;
                // For manage, we may have a previously selected subcategory
                const selectedSub = subSel.getAttribute("data-selected");
                if (selectedSub) {
                    subSel.value = selectedSub;
                }
            })
            .catch(err => console.error("Error loading subcategories", err));
    }

    // On load: for manage section, populate subcategory if category already selected
    window.addEventListener('load', function() {
        var section = "<%=section%>";
        if (section.toLowerCase() === "manage") {
            const catVal = "<%=mCatStr%>";
            const subVal = "<%=mSubStr%>";
            if (catVal) {
                const subSel = document.getElementById("m_subcategory");
                if (subSel) subSel.setAttribute("data-selected", subVal);
                updateSubcategories('m_category','m_subcategory');
            }
        }
    });
</script>

</body>
</html>
