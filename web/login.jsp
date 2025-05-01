<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="db.DBInitialization" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- This page performs processing ONLY. No HTML output is intended unless debugging. --%>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String redirectURL = null; // URL to redirect to
    String errorParam = null;  // Error code for redirect URL

    // --- Input Validation ---
    if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
        errorParam = "missing_fields";
        redirectURL = "index.html"; // Redirect back to login page
    } else {
        // --- Database Interaction ---
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBInitialization.getConnection();

            // WARNING: Plain text password check is insecure! Use hashing.
            String query = "SELECT role FROM Person WHERE email = ? AND password = ?";
            ps = conn.prepareStatement(query);
            ps.setString(1, email.trim()); // Trim email
            ps.setString(2, password);     // Don't trim password

            rs = ps.executeQuery();

            if (rs.next()) {
                // --- Login Successful ---
                String role = rs.getString("role");

                // Store user info in session (optional but common)
                session.setAttribute("userEmail", email.trim());
                session.setAttribute("userRole", role);

                // Determine redirect based on role
                if ("scientist".equalsIgnoreCase(role)) {
                    redirectURL = "scientist.html"; // Or scientist.jsp
                } else if ("admin".equalsIgnoreCase(role)) {
                    redirectURL = "admin.jsp";
                } else {
                    redirectURL = "user.html"; // Or user.jsp
                }
                // No error parameter needed for successful login

            } else {
                // --- Invalid Credentials ---
                errorParam = "invalid_credentials";
                redirectURL = "index.html"; // Redirect back to login page
            }

        } catch (SQLException e) {
            System.err.println("SQL Error during login for " + email + ": " + e.getMessage());
            e.printStackTrace(); // Log full trace for debugging
            errorParam = "db_error";
            redirectURL = "index.html"; // Redirect back to login page

        } catch (Exception e) { // Catch other potential errors (e.g., ClassNotFound)
             System.err.println("Unexpected Error during login for " + email + ": " + e.getMessage());
             e.printStackTrace();
             errorParam = "unexpected";
             redirectURL = "index.html"; // Redirect back to login page
        } finally {
            // --- Resource Cleanup ---
            try { if (rs != null) rs.close(); } catch (SQLException ignore) {}
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
        // Fallback if something went wrong and redirectURL wasn't set
        // Avoids blank page. Could redirect to a generic error page.
        response.sendRedirect("index.html?error=processing_failed");
    }
    // No further output should happen after sendRedirect
%>