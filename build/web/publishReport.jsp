<%@ page import="java.sql.*" %>
<%@ page import="db.DBInitialization" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- This page processes the publish request (only if not already published) and redirects. No HTML output. --%>
<%
String reportIdStr = request.getParameter("reportId");
String redirectURL = "admin.jsp"; // Base redirect URL
String statusParam = null;
String codeParam = null;
String reportIdParamForRedirect = reportIdStr != null ? reportIdStr : ""; // Pass ID back for messages
int reportId = -1; // Default invalid ID


// --- 1. Validation ---
if (reportIdStr == null || reportIdStr.trim().isEmpty()) {
    statusParam = "error";
    codeParam = "missing_id";
} else {
    try {
        reportId = Integer.parseInt(reportIdStr.trim());
        if (reportId <= 0) { // Also check if ID is positive
             statusParam = "error";
             codeParam = "invalid_id"; // ID parsed but is not positive
        }
    } catch (NumberFormatException nfe) {
        statusParam = "error";
        codeParam = "invalid_id_format"; // ID provided but not a number
    }
}

// --- 2. Database Update (Proceed only if ID is valid so far) ---
if (statusParam == null && reportId > 0) {
    Connection conn = null;
    PreparedStatement psUpdate = null;

    try{
        conn = DBInitialization.getConnection();
        conn.setAutoCommit(false); // Start transaction

        // *** MODIFIED QUERY ***
        // Update query: Set published to 1 ONLY IF it is currently 0 (or FALSE).
        // Assumes published is SMALLINT/TINYINT 0/1.
        // If BOOLEAN type, use: WHERE reportId = ? AND published = FALSE
        String updateQuery = "UPDATE Reports SET published = TRUE WHERE reportId = ? AND published = FALSE";

        psUpdate = conn.prepareStatement(updateQuery);
        psUpdate.setInt(1, reportId);

        int rowsUpdated = psUpdate.executeUpdate();

        if (rowsUpdated > 0) {
            // --- Success: Report was unpublished and is now published ---
            conn.commit(); // Commit transaction
            statusParam = "success";
            codeParam = "published"; // Specific success code (optional)
        } else {
            // --- No rows updated: Report either not found or already published ---
            // We assume based on the query logic it's likely "already published"
            // or "not found". A more robust check could select first, but this is simpler.
            conn.rollback(); // Rollback (nothing changed, but good practice)
            statusParam = "no_change"; // Use a different status like 'info' or 'no_change'
            codeParam = "already_published_or_not_found"; // Indicate the reason
        }

    } catch (SQLException e) {
        // --- Database Error ---
        System.err.println("SQL Error publishing report ID " + reportId + ": " + e.getMessage());
        e.printStackTrace(); // Log trace
        statusParam = "error";
        codeParam = "db_error";
         try { if (conn != null) conn.rollback(); } catch (SQLException ignore) {} // Attempt rollback on error
    } catch (Exception e) {
         // --- Other Unexpected Errors (e.g., getting connection) ---
         System.err.println("Unexpected Error publishing report ID " + reportId + ": " + e.getMessage());
         e.printStackTrace();
         statusParam = "error";
         codeParam = "unexpected";
         try { if (conn != null) conn.rollback(); } catch (SQLException ignore) {}
    } finally {
        // --- Resource Cleanup ---
        try { if (psUpdate != null) psUpdate.close(); } catch (SQLException ignore) {}
        try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException ignore) {} // Reset autoCommit and close
    }
} else if (statusParam == null) { // Catchall if validation somehow failed without setting status
     statusParam = "error";
     codeParam = "invalid_id";
}


// --- 3. Construct Redirect URL with parameters ---
if (statusParam != null) {
    // Use try-with-resources for potential URLEncoder if needed later, though current params are safe
    redirectURL += "?publishStatus=" + statusParam; // Changed param name slightly for clarity
    if (reportIdParamForRedirect != null && !reportIdParamForRedirect.isEmpty()) {
         redirectURL += "&reportId=" + reportIdParamForRedirect; // Pass back the ID
    }
    if (codeParam != null) {
        redirectURL += "&code=" + codeParam;
    }
}

// --- 4. Perform Redirect ---
response.sendRedirect(redirectURL);
// IMPORTANT: No whitespace or any other output before <%@ page %> or after sendRedirect()
%>