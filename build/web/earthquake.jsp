<%@ page import="java.sql.*" %>
<%@ page import="db.DBInitialization" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Earthquake Reports | Enviiro</title>
    <link rel="stylesheet" href="css/disaster.css" />
</head>
<body>
    <nav class="navbar">
        <div class="logo-text"><span class="en">En</span><span class="vii">vii</span><span class="ro">ro</span></div>
        <ul class="nav-links">
            <li><a href="user.html" class="nav-btn">Back to Menu</a></li>
        </ul>
    </nav>

    <main class="disaster-page">
        <h1 class="disaster-title">Published Earthquake Reports</h1>

        <%
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                conn = DBInitialization.getConnection();

                String query = "SELECT scientistName, headerName, reportText FROM Reports WHERE published = TRUE AND disasterType = 'earthquake'";
                ps = conn.prepareStatement(query);
                rs = ps.executeQuery();
        %>

        <div class="report-table-container">
            <table class="styled-report-table">
                <thead>
                    <tr>
                        <th>Header</th>
                        <th>Scientist Name</th>
                        <th>Report</th>
                    </tr>
                </thead>
                <tbody>
        <%
            boolean hasResults = false;
            while (rs.next()) {
                hasResults = true;
                String header = rs.getString("headerName");
                String scientist = rs.getString("scientistName");
                String report = rs.getString("reportText") != null ? rs.getString("reportText") : "";
        %>
                    <tr>
                        <td><%= header %></td>
                        <td><%= scientist %></td>
                        <td><pre><%= report %></pre></td>
                    </tr>
        <%
            }

            if (!hasResults) {
        %>
                    <tr>
                        <td colspan="3" style="text-align: center;">No published earthquake reports found.</td>
                    </tr>
        <%
            }
        %>
                </tbody>
            </table>
        </div>

        <%
            } catch (SQLException sqle) {
        %>
            <p class="error-message">Database error occurred: <%= sqle.getMessage() %></p>
        <%
            } catch (Exception e) {
        %>
            <p class="error-message">Unexpected error: <%= e.getClass().getSimpleName() %> - <%= e.getMessage() %></p>
        <%
            } finally {
                try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
                try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
                try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
            }
        %>

        <div class="button-container">
            <a href="earthquake.html" class="view-reports-btn">Back to Earthquake Info</a>
        </div>
    </main>
</body>
</html>
