<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="db.DBInitialization" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- This page performs processing ONLY. No HTML output is intended. --%>
<%
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String email = request.getParameter("email");
    String password = request.getParameter("password"); // WARNING: HASH THIS PASSWORD!
    String role = "user"; // Fixed role for signup
    String redirectURL = null;
    String errorParam = null;

    // --- Input Validation ---
    if (fname == null || fname.trim().isEmpty() ||
        lname == null || lname.trim().isEmpty() ||
        email == null || email.trim().isEmpty() ||
        password == null || password.isEmpty())
    {
        errorParam = "missing_fields";
        redirectURL = "signup.html"; // Redirect back to signup page
    } else {
        // --- Database Interaction ---
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBInitialization.getConnection();

            // WARNING: Storing plain text passwords is very insecure! Use hashing (e.g., bcrypt).
            String insertQuery = "INSERT INTO Person (firstName, lastName, email, password, role) VALUES (?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(insertQuery);
            ps.setString(1, fname.trim());
            ps.setString(2, lname.trim());
            ps.setString(3, email.trim());
            ps.setString(4, password); // HASH the password before storing
            ps.setString(5, role);

            int rowsInserted = ps.executeUpdate();

            if (rowsInserted > 0) {
                // --- Signup Successful ---
                redirectURL = "index.html"; // Redirect to login page after successful signup
                // Optionally add a success message parameter: redirectURL = "index.html?success=signup_complete";
            } else {
                // Less likely case if executeUpdate returns 0 without exception
                errorParam = "insert_failed";
                redirectURL = "signup.html";
            }
        } catch (SQLException e) {
            System.err.println("SQL Error during signup for " + email + ": " + e.getMessage() + " (SQLState: " + e.getSQLState() + ")");
            e.printStackTrace();

            // Check for unique constraint violation (email already exists) - Derby code 23505
            if ("23505".equals(e.getSQLState())) {
                errorParam = "duplicate_email";
            } else {
                errorParam = "db_error"; // Generic database error
            }
            redirectURL = "signup.html"; // Redirect back to signup page on error

        } catch (Exception e) { // Catch other potential errors
             System.err.println("Unexpected Error during signup for " + email + ": " + e.getMessage());
             e.printStackTrace();
             errorParam = "unexpected";
             redirectURL = "signup.html";
        } finally {
             // --- Resource Cleanup ---
            try { if (ps != null) ps.close(); } catch (SQLException ignore) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignore) {}
        }
    }

    // --- Perform Redirect ---
    String finalRedirectURL = redirectURL;
     if (errorParam != null) {
        finalRedirectURL += "?error=" + errorParam;
    }

    // Check if redirectURL is set before redirecting
    if (finalRedirectURL != null) {
        response.sendRedirect(finalRedirectURL);
    } else {
        // Fallback
        response.sendRedirect("signup.html?error=processing_failed");
    }
    // No further output
%>