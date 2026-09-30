DROP DATABASE IF EXISTS gig_marketplace;
CREATE DATABASE gig_marketplace;
USE gig_marketplace;

CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Gigs (
    gig_id INT AUTO_INCREMENT PRIMARY KEY,
    poster_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    budget DECIMAL(10, 2) NOT NULL,
    deadline DATE,
    completion_deadline DATE,
    category VARCHAR(100),
    status ENUM('Open', 'Closed') DEFAULT 'Open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (poster_id) REFERENCES Students(student_id)
);

CREATE TABLE Applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    gig_id INT NOT NULL,
    applicant_id INT NOT NULL,
    pitch_text TEXT NOT NULL,
    portfolio_path VARCHAR(255),
    status ENUM('Pending', 'Hired', 'Rejected') DEFAULT 'Pending',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (gig_id) REFERENCES Gigs(gig_id),
    FOREIGN KEY (applicant_id) REFERENCES Students(student_id)
);

CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    gig_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (gig_id) REFERENCES Gigs(gig_id)
);

-- Insert users
INSERT INTO Students (name, email) VALUES ('Naman', 'naman@campus.edu');
INSERT INTO Students (name, email) VALUES ('Riddhi', 'riddhi@campus.edu');
INSERT INTO Students (name, email) VALUES ('Shreyash', 'shreyash@campus.edu');
INSERT INTO Students (name, email) VALUES ('Shivam', 'shivam@campus.edu');
INSERT INTO Students (name, email) VALUES ('Mohak', 'mohak@campus.edu');
