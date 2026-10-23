package com.gigmarket.auth;

/** A university and the two email domains that decide who is a student and who is faculty. */
public final class University {
    private final int id;
    private final String name;
    private final String studentDomain;
    private final String facultyDomain;

    public University(int id, String name, String studentDomain, String facultyDomain) {
        this.id = id;
        this.name = name;
        this.studentDomain = studentDomain;
        this.facultyDomain = facultyDomain;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getStudentDomain() { return studentDomain; }
    public String getFacultyDomain() { return facultyDomain; }
}
