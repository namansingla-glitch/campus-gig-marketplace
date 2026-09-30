package com.gigmarket.model;

import java.math.BigDecimal;
import java.sql.Date;

public class Gig {
    private int gigId;
    private int posterId;
    private String title;
    private String description;
    private BigDecimal budget;
    private Date deadline;
    private Date completionDeadline;
    private String category;
    private String status;
    private java.sql.Timestamp createdAt;
    
    // Default constructor
    public Gig() {}

    // Getters and Setters
    public int getGigId() { return gigId; }
    public void setGigId(int gigId) { this.gigId = gigId; }

    public int getPosterId() { return posterId; }
    public void setPosterId(int posterId) { this.posterId = posterId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getBudget() { return budget; }
    public void setBudget(BigDecimal budget) { this.budget = budget; }

    public Date getDeadline() { return deadline; }
    public void setDeadline(Date deadline) { this.deadline = deadline; }

    public Date getCompletionDeadline() { return completionDeadline; }
    public void setCompletionDeadline(Date completionDeadline) { this.completionDeadline = completionDeadline; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public java.sql.Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.sql.Timestamp createdAt) { this.createdAt = createdAt; }
}
