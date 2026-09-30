# CampusGig Marketplace 🎓

CampusGig is a premium, modern SaaS platform designed for university campuses. It connects students looking for short-term paid work (micro-tasks) with professors, faculty members, and authorized campus users who need tasks completed.

## 🚀 Features

* **Dual User Roles**: Seamlessly switch between Student (Applicant) and Poster (Employer) experiences.
* **Premium SaaS UI**: Built with a sophisticated glassmorphism design system, floating navigation, and responsive layouts.
* **Student Dashboard**: Track applications, view earnings analytics, and manage upcoming gig deadlines.
* **Poster Dashboard**: Manage active gigs, track total applications, and oversee hired students.
* **Real-time Gig Preview**: Two-column interactive layout for gig creation.
* **Applicant Management**: Seamlessly review pitches, download portfolios, and hire or reject candidates.
* **Gamified Rewards System**: Bronze/Silver/Gold tiers and achievement unlockables based on completed gigs and earnings.

## 🛠️ Tech Stack

* **Backend**: Java Servlets (J2EE)
* **Frontend**: HTML5, JSP, Tailwind CSS, Alpine.js
* **Database**: MySQL (JDBC)
* **Server**: Apache Tomcat 9
* **Build Tool**: Maven

## ⚙️ How to Run Locally

### Prerequisites
* Java Development Kit (JDK) 11+
* Maven
* MySQL 8.0+

### Setup Database
1. Open your terminal and log into MySQL:
   ```bash
   mysql -u root -p
   ```
2. Run the provided schema to set up the database and dummy users:
   ```bash
   source src/main/resources/schema.sql;
   ```

### Start the Server
1. Clone this repository.
2. Navigate to the project directory in your terminal.
3. Build and run the embedded Tomcat server using the Maven Cargo plugin:
   ```bash
   mvn clean package cargo:run
   ```
4. Open your web browser and navigate to:
   `http://localhost:8080/gig-marketplace/`

## 👥 Demo Accounts
You can easily log in to test the application using the pre-seeded demo accounts:
* **Student**: `naman@campus.edu` (Password: `password123`)
* **Poster**: `riddhi@campus.edu` (Password: `password123`)
