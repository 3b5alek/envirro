package db; // Or your chosen package name

import java.io.Serializable; // Good practice for beans

// Make the class public so it can be accessed from the JSP
public class Report implements Serializable {
    private static final long serialVersionUID = 1L; // Optional but good practice for Serializable

    private int reportId;
    private String scientistName;
    private String disasterType;
    private String headerName;
    private String reportText;

    // Default constructor (often needed by frameworks/tools)
    public Report() {}

    // Parameterized constructor (as you had)
    public Report(int reportId, String scientistName, String disasterType, String headerName, String reportText) {
        this.reportId = reportId;
        this.scientistName = scientistName;
        this.disasterType = disasterType;
        this.headerName = headerName;
        this.reportText = reportText;
    }

    // Public Getters
    public int getReportId() { return reportId; }
    public String getScientistName() { return scientistName; }
    public String getDisasterType() { return disasterType; }
    public String getHeaderName() { return headerName; }
    public String getReportText() { return reportText; }

    // Public Setters (Optional - add if you need to modify reports after creation)
    public void setReportId(int reportId) { this.reportId = reportId; }
    public void setScientistName(String scientistName) { this.scientistName = scientistName; }
    public void setDisasterType(String disasterType) { this.disasterType = disasterType; }
    public void setHeaderName(String headerName) { this.headerName = headerName; }
    public void setReportText(String reportText) { this.reportText = reportText; }
}