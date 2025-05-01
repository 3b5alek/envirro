package db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DBInitialization {

    private static final String DATABASE_URL = "jdbc:derby:projectDB;create=true";
    private static final String DRIVER_CLASS = "org.apache.derby.jdbc.EmbeddedDriver";

    // Static initializer block: Runs ONCE when the class is loaded by the JVM
    static {
        try {
            // 1. Load the driver
            Class.forName(DRIVER_CLASS);
            System.out.println("Derby driver loaded.");

            // 2. Perform initial database setup (tables)
            initializeDatabaseStructure();

            // 3. Insert initial data (handle errors if data already exists)
            //    Comment this out if you only want to run it manually once
            //    or if you have other ways to populate initial data.
            insertInitialData();

        } catch (ClassNotFoundException e) {
            System.err.println("FATAL ERROR: Database driver not found: " + e.getMessage());
            // In a real app, you might want to prevent the app from starting fully
            throw new RuntimeException("Database driver not found", e);
        } catch (SQLException e) {
             System.err.println("ERROR during static initialization: " + e.getMessage());
             // Decide if the application can continue
        }
    }

    // Method to get a NEW connection each time it's called
    public static Connection getConnection() throws SQLException {
        // Returns a fresh, open connection
        return DriverManager.getConnection(DATABASE_URL);
    }

    // --- Helper methods for initialization (used by static block) ---

    private static void initializeDatabaseStructure() throws SQLException {
         // Use try-with-resources for the connection used ONLY for setup
         try (Connection conn = DriverManager.getConnection(DATABASE_URL); // Gets a temporary connection
              Statement statement = conn.createStatement()) {

             System.out.println("Checking/Creating database tables...");

             // Use VARCHAR(255) for password if you plan hashing
             // Ensure PRIMARY KEY is correctly defined
             String createPersonTableQuery = """
                 CREATE TABLE Person (
                     firstName VARCHAR(25),
                     lastName VARCHAR(25),
                     email VARCHAR(50) NOT NULL PRIMARY KEY,
                     password VARCHAR(255) NOT NULL,
                     role VARCHAR(25) NOT NULL
                 )
             """;

             // Adjust VARCHAR sizes if needed
             String createReportsTableQuery = """
                 CREATE TABLE Reports (
                     reportId INT GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1) PRIMARY KEY,
                     scientistName VARCHAR(50),
                     disasterType VARCHAR(50),
                     headerName VARCHAR(100),
                     reportText CLOB,
                     published BOOLEAN DEFAULT FALSE
                 )
             """;

             // Using execute to handle potential "already exists" scenarios gracefully with IF NOT EXISTS
             // Note: Derby doesn't directly support CREATE TABLE IF NOT EXISTS before 10.5
             // We rely on catching SQLException if the table exists. A better check might be needed for older Derby.
             try {
                 statement.executeUpdate(createPersonTableQuery);
                 System.out.println("Person table created (or already existed).");
             } catch (SQLException e) {
                 // Specific Derby error code for "object already exists" is X0Y32
                 if ("X0Y32".equals(e.getSQLState())) {
                     System.out.println("Person table already exists.");
                 } else {
                     throw e; // Re-throw other SQL errors
                 }
             }

             try {
                 statement.executeUpdate(createReportsTableQuery);
                 System.out.println("Reports table created (or already existed).");
             } catch (SQLException e) {
                  if ("X0Y32".equals(e.getSQLState())) {
                     System.out.println("Reports table already exists.");
                 } else {
                     throw e; // Re-throw other SQL errors
                 }
             }

             System.out.println("Database structure check complete.");

         } // Connection conn is automatically closed here by try-with-resources
    }

    private static void insertInitialData() {
        System.out.println("Attempting to insert initial data...");
        String insertDataQuery = """
            INSERT INTO Person (firstName, lastName, email, password, role) VALUES
            ('Albert', 'Einstein', 'einstein@example.com', 'emc2pass', 'scientist'),
            ('Marie', 'Curie', 'curie@example.com', 'radiumpass', 'scientist'),
            ('Ada', 'Lovelace', 'lovelace@example.com', 'analyticpass', 'admin'),
            ('Alan', 'Turing', 'turing@example.com', 'enigma123', 'admin')
        """;

        // Use try-with-resources for the connection used ONLY for insertion
        try (Connection conn = DriverManager.getConnection(DATABASE_URL); // Gets a temporary connection
             Statement insertStatement = conn.createStatement()) {

            insertStatement.executeUpdate(insertDataQuery);
            System.out.println("Sample users inserted successfully.");

        } catch (SQLException e) {
            // Derby's unique constraint violation code is 23505
            if ("23505".equals(e.getSQLState())) {
                System.out.println("Sample users likely already exist (Insert skipped).");
            } else {
                // Log other SQL errors during insertion
                System.err.println("Error inserting sample users: " + e.getMessage() + " (SQLState: " + e.getSQLState() + ")");
            }
        } // Connection conn is automatically closed here
    }

    // Private constructor prevents creating instances of DBInitialization
    private DBInitialization() { }
}