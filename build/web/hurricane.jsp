<%@ page import="java.sql.*" %>
<%@ page import="db.DBInitialization" %> <%-- Import the DBInitialization class --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Hurricane Reports</title>

    <!-- Link to the external disaster CSS file -->
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
        <h1 class="disaster-title">Hurricane Disaster Reports</h1>

        <%
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                // --- Use the DBInitialization class to get the connection ---
                conn = DBInitialization.getConnection();

                // --- SQL query for hurricanes ---
                String query = "SELECT scientistName, headerName, reportText FROM Reports WHERE published = TRUE AND disasterType = 'hurricane'";
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
                        boolean hasResults = false; // Flag to check if any rows were found
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
                        } // End while loop

                        if (!hasResults) {
                    %>
                    <tr>
                        <td colspan="3" style="text-align: center; padding: 10px;">No published hurricane reports found.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>

        <%
            } catch (SQLException sqle) {
                System.err.println("SQL Error in hurricanes.jsp: " + sqle.getMessage());
                sqle.printStackTrace();
        %>
        <p class="error-message">Error accessing report data: A database error occurred. Please contact support.</p>
        <p class="error-message">Details: <%= sqle.getMessage() %></p>
        <%
            } catch (Exception e) {
                System.err.println("General Error in hurricanes.jsp: " + e.getMessage());
                e.printStackTrace();
        %>
        <p class="error-message">Error: An unexpected error occurred (<%= e.getClass().getSimpleName() %>).</p>
        <%
            } finally {
                try { if (rs != null) rs.close(); } catch (SQLException e) { /* ignore */ }
                try { if (ps != null) ps.close(); } catch (SQLException e) { /* ignore */ }
                try { if (conn != null) conn.close(); } catch (SQLException e) { /* ignore */ }
            }
        %>

        <div class="button-container">
            <a href="hurricanes.html" class="view-reports-btn">Back to Hurricane Information</a>
        </div>
    </main>

</body>
</html>
