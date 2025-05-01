<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.SQLException" %>
<%@ page import="db.DBInitialization" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Processing Only - No HTML Output Intended --%>
<%
    // --- Parameter Retrieval ---
    String scientistName = request.getParameter("scientistName");
    String disasterType = request.getParameter("disasterType");
    String headerName = request.getParameter("headername");
    String reportText = request.getParameter("reportText");

    String redirectURL = "scientist.html"; // Default redirect back to form
    String statusParam = null;
    String codeParam = null;

    // --- Basic Validation ---
    if (scientistName == null || scientistName.trim().isEmpty() ||
        disasterType == null || disasterType.trim().isEmpty() ||
        headerName == null || headerName.trim().isEmpty() ||
        reportText == null || reportText.trim().isEmpty())
    {
        statusParam = "error";
        codeParam = "validation_error";
        // Don't proceed to database if validation fails
    } else {
        // --- Database Interaction ---
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            // Correct way to get connection
            conn = DBInitialization.getConnection();

            // SQL uses column names from your DBInitialization
            String insertQuery = "INSERT INTO Reports (scientistName, disasterType, headerName, reportText, published) VALUES (?, ?, ?, ?, ?)";

            ps = conn.prepareStatement(insertQuery);
            ps.setString(1, scientistName.trim());
            ps.setString(2, disasterType); // Assuming value from select is correct type
            ps.setString(3, headerName.trim());
            ps.setString(4, reportText);   // For CLOB, setString usually works, but setClob might be needed for very large data
            ps.setBoolean(5, false); // Default 'published' to false on initial insert

            int rowsInserted = ps.executeUpdate();

            if (rowsInserted > 0) {
                // --- Success ---
                statusParam = "success";
            } else {
                // --- Failure (Insert didn't affect rows, less common without error) ---
                statusParam = "failure";
            }
        } catch (SQLException e) {
            // --- Database Error ---
            System.err.println("SQL Error saving report by " + scientistName + ": " + e.getMessage());
            e.printStackTrace(); // Log stack trace
            statusParam = "error";
            codeParam = "db_error";
        } catch (Exception e) {
            // --- Other Unexpected Errors ---
             System.err.println("Unexpected Error saving report by " + scientistName + ": " + e.getMessage());
             e.printStackTrace();
             statusParam = "error";
             codeParam = "unexpected";
        } finally {
            // --- Resource Cleanup ---
            try { if (ps != null) ps.close(); } catch (SQLException ignore) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignore) {}
        }
    }

    // --- Construct Redirect URL ---
    if (statusParam != null) {
        redirectURL += "?status=" + statusParam;
        if (codeParam != null) {
            redirectURL += "&code=" + codeParam;
        }
    }

    // --- Perform Redirect ---
    response.sendRedirect(redirectURL);
    // No further output after redirect
%>