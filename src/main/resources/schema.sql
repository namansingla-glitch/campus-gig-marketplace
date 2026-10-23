DROP DATABASE IF EXISTS gig_marketplace;
CREATE DATABASE gig_marketplace;
USE gig_marketplace;

-- Universities and the email domains that decide who is a student and who is faculty.
CREATE TABLE Universities (
    university_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    student_domain VARCHAR(100) NOT NULL,
    faculty_domain VARCHAR(100) NOT NULL
);

-- Every account (students, faculty, admins). The name is kept so existing queries keep working.
-- role comes from the email domain at sign-up, never from a form; faculty start as 'pending' until an admin approves.
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'faculty', 'admin') NOT NULL DEFAULT 'student',
    status ENUM('active', 'pending', 'rejected') NOT NULL DEFAULT 'active',
    university_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (university_id) REFERENCES Universities(university_id)
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

-- Universities (more later: one row each)
INSERT INTO Universities (name, student_domain, faculty_domain) VALUES ('Woxsen University', 'woxsen.edu.in', 'faculty.woxsen.com');

-- Demo accounts for local testing only. Every one uses the password password123 (stored as a PBKDF2 hash).
-- Delete them before anyone outside uses the site (and before any real gigs reference them).
INSERT INTO Students (name, email, password_hash, role, status, university_id) VALUES
 ('Naman', 'naman@woxsen.edu.in', 'pbkdf2_sha256$600000$ehLrVrT9dEKeNKqYXn9S9Q==$jnOUiN3MW5crsILCEIoad9SybTBiod3otFlanEJgBh0=', 'student', 'active', 1),
 ('Riddhi', 'riddhi@faculty.woxsen.com', 'pbkdf2_sha256$600000$cR3K6MwF0ZB53Y9qEowanA==$u0CzjHmTHdlH9lZtqRQcpM2pC0I4Me+NdFweh2/r/IY=', 'faculty', 'active', 1),
 ('Shreyash', 'shreyash@woxsen.edu.in', 'pbkdf2_sha256$600000$o/UrX8tuj33hMBw5JEBKJQ==$3KfMKbffxkQj41wM2hc99Nccs5J5sEskA9+Ii/MP0Dk=', 'student', 'active', 1),
 ('Shivam', 'shivam@woxsen.edu.in', 'pbkdf2_sha256$600000$bgD2mJCoo/RZ2kX+oMFUKQ==$E/iuaSOsG5p2boLDgClatYwjwNgVwE6qiXJiBosnSkk=', 'student', 'active', 1),
 ('Mohak', 'mohak@woxsen.edu.in', 'pbkdf2_sha256$600000$ySvxb/7CtKqQQYju+JSttw==$9jFVFP4EgojaG9f+kGrJ8a9Z+8XOfLQgEwQqp3DDeoM=', 'student', 'active', 1),
 ('Dr. Anika Rao', 'a.rao@faculty.woxsen.com', 'pbkdf2_sha256$600000$H8FRPM0VrpVPayqMHbKcXQ==$6aOYwitBJ4g+BrJgBceCaJ46yuxCBS+Q9Ll5xrM/bz0=', 'faculty', 'pending', 1);

-- Admin: there is no seeded admin (a known admin password in a public repo would let anyone in).
-- Join with your own Woxsen email, then run once:
--   UPDATE Students SET role = 'admin', status = 'active' WHERE email = 'you@woxsen.edu.in';
