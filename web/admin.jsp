<%@page import="db.Report"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="db.DBInitialization" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // --- Data Fetching Block ---
    List<Report> unpublishedReports = new ArrayList<>();
    String fetchError = null; // To store any error message during fetch

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBInitialization.getConnection();

        // --- Query for unpublished reports ---
        String selectQuery = "SELECT reportId, scientistName, disasterType, headerName, reportText FROM Reports WHERE published = FALSE"; 

        ps = conn.prepareStatement(selectQuery);
        rs = ps.executeQuery();

        while (rs.next()) {
            unpublishedReports.add(new Report(
                rs.getInt("reportId"),
                rs.getString("scientistName"),
                rs.getString("disasterType"),
                rs.getString("headerName"),
                rs.getString("reportText")
            ));
        }

    } catch (SQLException e) {
        fetchError = "Database error fetching reports: " + e.getMessage();
        e.printStackTrace(); // Log full trace for server-side debugging
    } catch (Exception e) { // Catch broader exceptions during connection/setup
        fetchError = "An unexpected error occurred while trying to fetch reports: " + e.getMessage();
        e.printStackTrace();
    } finally {
        // --- Resource Cleanup ---
        try { if (rs != null) rs.close(); } catch (SQLException ignore) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignore) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignore) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin - Manage Reports</title>
  <style>
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  body {
    font-family: Arial, sans-serif;
    background-color: #f4f4f9;
    color: #333;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 20px;
  }

  header {
    width: 100%;
    background-color: #1a1a1a;
    color: white;
    padding: 20px;
    text-align: center;
    margin-bottom: 20px;
  }

  header h1 {
    font-size: 2.5rem;
  }

  .container {
    width: 100%;
    max-width: 1200px;
    background-color: #fff;
    padding: 25px;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 20px;
  }

  th, td {
    border: 1px solid #ddd;
    padding: 12px;
    text-align: left;
    vertical-align: top;
  }

  th {
    background-color: #f0f0f0;
    font-weight: bold;
  }

  tr:nth-child(even) {
    background-color: #fafafa;
  }

  tr:hover {
    background-color: #f1f1f1;
  }

  .publish-button {
    padding: 10px 16px;
    background-color: #e60000;
    color: white;
    border: none;
    border-radius: 5px;
    font-size: 0.95rem;
    cursor: pointer;
    transition: background-color 0.3s;
  }

  .publish-button:hover {
    background-color: #cc0000;
  }

  .status-message-container {
    width: 100%;
    max-width: 800px;
    margin: 0 auto 20px;
  }

  .status-message {
    padding: 15px;
    text-align: center;
    border-radius: 5px;
    font-weight: bold;
  }

  .success {
    background-color: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
  }

  .error {
    background-color: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
  }

  .no-reports {
    text-align: center;
    font-style: italic;
    color: #666;
    font-size: 1.1rem;
    margin-top: 20px;
  }

  td.report-text-cell {
    max-width: 350px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    cursor: help;
  }

  td.report-text-cell:hover {
    white-space: normal;
    overflow: visible;
    max-width: none;
    background-color: #fdfdfd;
    box-shadow: 0 0 5px rgba(0, 0, 0, 0.2);
    position: relative;
    z-index: 10;
  }

  .dashboard-link {
    margin-top: 30px;
    text-align: center;
  }

  .dashboard-link a {
    text-decoration: none;
    background-color: #1a1a1a;
    color: white;
    padding: 12px 24px;
    border-radius: 6px;
    transition: background-color 0.3s;
    font-size: 1rem;
  }

  .dashboard-link a:hover {
    background-color: #333;
  }
</style>
</head>
<body>

  <div class="container">
      <h1>Manage Unpublished Reports</h1>

       <!-- Placeholder for status messages from publish action -->
       <div id="statusMessageContainer">
          <div id="statusMessage" class="status-message" style="display: none;"></div>
       </div>

<%
    // --- Display Logic ---
    if (fetchError != null) {
        // Display fetch error prominently
%>
        <p class="status-message error">Could not load reports: <%= fetchError %></p>
<%
    } else if (unpublishedReports.isEmpty()) {
        // Display message if no unpublished reports were found
%>
        <p class="no-reports">There are currently no unpublished reports awaiting review.</p>
<%
    } else {
        // Display the table if reports were loaded successfully
%>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Scientist</th>
              <th>Disaster</th>
              <th>Title</th>
              <th>Report (Hover for full text)</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
<%
            // Iterate through the list of Report beans
            for (Report report : unpublishedReports) {
                String scientistName = report.getScientistName() != null ? report.getScientistName().replace("<", "&lt;").replace(">", "&gt;") : "";
                String disasterType = report.getDisasterType() != null ? report.getDisasterType().replace("<", "&lt;").replace(">", "&gt;") : "";
                String headerName = report.getHeaderName() != null ? report.getHeaderName().replace("<", "&lt;").replace(">", "&gt;") : "";
                String reportText = report.getReportText() != null ? report.getReportText().replace("<", "&lt;").replace(">", "&gt;") : "";
                
%>
            <tr>
              <td><%= report.getReportId() %></td>
              <td><%= scientistName %></td>
              <td><%= disasterType %></td>
              <td><%= headerName %></td>
              <td class="report-text-cell" title="<%= reportText %>"><%= reportText.substring(0, Math.min(reportText.length(), 50)) %>...</td>
              <td>
                <form action="publishReport.jsp" method="post" style="display:inline;">
                  <input type="hidden" name="reportId" value="<%= report.getReportId() %>">
                  <button type="submit" class="publish-button" title="Publish this report (ID: <%= report.getReportId() %>)">Publish</button>
                </form>
              </td>
            </tr>
<%
            } // End of loop
%>
          </tbody>
        </table>
<%
    } // End of else (reports found)
%>

      <div class="dashboard-link">
          <a href="index.html">Back to Dashboard</a>
      </div>

  </div> <!-- End container -->

  <script>
  // Display status messages passed via URL parameter from publishReport.jsp
  document.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const status = urlParams.get('publishStatus');
    const code = urlParams.get('code');
    const reportId = urlParams.get('reportId');
    const messageDiv = document.getElementById('statusMessage');

    if (status) {
      let message = '';
      let messageClass = '';
      let reportIdDisplay = reportId || 'N/A';

      if (status === 'success') {
        message = 'Report (ID: ' + reportIdDisplay + ') published successfully!';
        messageClass = 'success';
      } else if (status === 'error') {
          messageClass = 'error';
          let baseMsg = 'Error publishing report (ID: ' + reportIdDisplay + '): ';
          if (code === 'not_found') {
              message = baseMsg + 'Report not found in the database.';
          } else if (code === 'db_error') {
               message = baseMsg + 'A database error occurred.';
          } else if (code === 'missing_id') {
               message = 'Error publishing report: Report ID was missing in the request.';
          } else {
              message = baseMsg + 'An unknown error occurred. Code: ' + (code || 'N/A');
          }
      }

      if (message) {
          messageDiv.textContent = message;
          messageDiv.className = 'status-message ' + messageClass;
          messageDiv.style.display = 'block';

          setTimeout(() => {
             if (window.history && window.history.replaceState) {
                 window.history.replaceState(null, null, window.location.pathname);
             }
          }, 6000);
      }
    }
  });
</script>

</body>
</html>
