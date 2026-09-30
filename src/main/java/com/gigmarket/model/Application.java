package com.gigmarket.model;

public class Application {
    private int applicationId;
    private int gigId;
    private int applicantId;
    private String applicantName; 
    private String pitchText;
    private String portfolioPath;
    private String status;
    private java.sql.Timestamp appliedAt;

    public Application() {}

    public int getApplicationId() { return applicationId; }
    public void setApplicationId(int applicationId) { this.applicationId = applicationId; }

    public int getGigId() { return gigId; }
    public void setGigId(int gigId) { this.gigId = gigId; }

    public int getApplicantId() { return applicantId; }
    public void setApplicantId(int applicantId) { this.applicantId = applicantId; }

    public String getApplicantName() { return applicantName; }
    public void setApplicantName(String applicantName) { this.applicantName = applicantName; }

    public String getPitchText() { return pitchText; }
    public void setPitchText(String pitchText) { this.pitchText = pitchText; }

    public String getPortfolioPath() { return portfolioPath; }
    public void setPortfolioPath(String portfolioPath) { this.portfolioPath = portfolioPath; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public java.sql.Timestamp getAppliedAt() { return appliedAt; }
    public void setAppliedAt(java.sql.Timestamp appliedAt) { this.appliedAt = appliedAt; }
}
