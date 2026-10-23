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
    when_text VARCHAR(120) NULL,   -- e.g. "Tue & Thu, 4–5 pm" (free text from the faculty member)
    where_text VARCHAR(120) NULL,  -- e.g. "Library, 2nd floor" or "Remote"
    -- Open (taking applications) → In progress (someone hired) → Done (the faculty member marked it done).
    status ENUM('Open', 'In progress', 'Done') NOT NULL DEFAULT 'Open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    done_at TIMESTAMP NULL,        -- when it was marked done; rewards and the monthly standing count from this
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

-- Example gigs for local testing only (posted by the demo faculty account). Delete with the demo accounts.
INSERT INTO Gigs (poster_id, title, description, budget, deadline, completion_deadline, category, when_text, where_text) VALUES
 (2, 'Tutor first-years in C pointers', 'Example gig for testing. Two one-hour sessions a week for three first-year students who are stuck on pointers and arrays.', 350, DATE_ADD(CURDATE(), INTERVAL 8 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'Tutoring', 'Tue & Thu, 4–5 pm', 'Library, 2nd floor'),
 (2, 'Invigilate the Saturday mock test', 'Example gig for testing. Help the exam cell invigilate a three-hour mock test for 60 students.', 800, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'Event Support', 'Sat, 9 am–12 pm', 'Block C, room 204'),
 (2, 'Poster for the robotics expo', 'Example gig for testing. An A3 poster for the robotics expo. The club logo and event details are provided; you choose the look.', 1500, DATE_ADD(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Design', 'Your time, 3 days', 'Remote'),
 (2, 'Fix the lab booking form', 'Example gig for testing. The lab booking form loses entries when two people book at once. Find and fix the bug.', 2500, DATE_ADD(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 'Development', 'Weekends, about 6 hours', 'Remote'),
 (2, 'Proofread the placement brochure', 'Example gig for testing. Check the 12-page placement brochure for spelling and consistency.', 600, DATE_ADD(CURDATE(), INTERVAL 6 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), 'Writing', 'Your time, 2 days', 'Placement cell, Block A');

-- Example work for local testing only, so dashboards, review and rewards have something real to count.
-- Shreyash finished one gig and is on another; Mohak and Shivam are waiting on gig 1. Delete with the demo accounts.
INSERT INTO Gigs (poster_id, title, description, budget, category, when_text, where_text, status, created_at, done_at) VALUES
 (2, 'Help at the orientation desk', 'Example gig for testing. Answer first-year questions at the orientation desk.', 700, 'Event Support', 'Mon, 9 am–1 pm', 'Main block lobby', 'Done', NOW() - INTERVAL 5 DAY, NOW()),
 (2, 'Record the lab safety video', 'Example gig for testing. Film and cut a three-minute lab safety video.', 1200, 'Design', 'Your time, 1 week', 'Chemistry lab', 'In progress', NOW() - INTERVAL 3 DAY, NULL);
INSERT INTO Applications (gig_id, applicant_id, pitch_text, status) VALUES
 (6, 3, 'Example pitch. I volunteered at last year''s orientation.', 'Hired'),
 (6, 5, 'Example pitch. I know the campus well.', 'Rejected'),
 (7, 3, 'Example pitch. I edit videos for the film club.', 'Hired'),
 (1, 5, 'Example pitch. I scored top marks in C last semester.', 'Pending'),
 (1, 4, 'Example pitch. I tutor juniors in my hostel.', 'Pending');
