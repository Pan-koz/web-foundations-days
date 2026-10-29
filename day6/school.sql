
PRAGMA foreign_keys = ON;

-- 1. Create the students table
CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

-- 2. Create the courses table
CREATE TABLE courses (
    id INTEGER PRIMARY KEY,
    course_name TEXT NOT NULL UNIQUE
);

-- 3. Create the enrolments table
-- The composite primary key prevents duplicate enrolments.
CREATE TABLE enrolments (
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade INTEGER NOT NULL CHECK (grade BETWEEN 0 AND 100),

    PRIMARY KEY (student_id, course_id),

    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- 4. Insert at least three students
INSERT INTO students (id, name, email) VALUES
(1, 'Amina Hassan', 'amina@example.com'),
(2, 'Brian Otieno', 'brian@example.com'),
(3, 'Grace Wanjiku', 'grace@example.com');

-- 5. Insert at least three courses
INSERT INTO courses (id, course_name) VALUES
(1, 'SQL Fundamentals'),
(2, 'Web Development'),
(3, 'Cybersecurity');

-- 6. Insert five enrolments
INSERT INTO enrolments (student_id, course_id, grade) VALUES
(1, 1, 82),
(1, 2, 90),
(1, 3, 78),
(2, 1, 75),
(2, 2, 88);

-- QUERY 1: All courses for one student, by name
SELECT students.name, courses.course_name, enrolments.grade
FROM students
JOIN enrolments ON enrolments.student_id = students.id
JOIN courses ON courses.id = enrolments.course_id
WHERE students.name = 'Amina Hassan'
ORDER BY courses.course_name;

-- QUERY 2: All students on one course
SELECT courses.course_name, students.name
FROM courses
JOIN enrolments ON enrolments.course_id = courses.id
JOIN students ON students.id = enrolments.student_id
WHERE courses.course_name = 'Web Development'
ORDER BY students.name;

-- QUERY 3: Number of students per course, including courses with zero
SELECT courses.course_name,
       COUNT(enrolments.student_id) AS student_count
FROM courses
LEFT JOIN enrolments ON enrolments.course_id = courses.id
GROUP BY courses.id, courses.course_name
ORDER BY courses.course_name;

-- QUERY 4: Students who have no enrolments
SELECT students.id, students.name
FROM students
LEFT JOIN enrolments ON enrolments.student_id = students.id
WHERE enrolments.student_id IS NULL;

-- QUERY 5: Update one enrolment's grade
UPDATE enrolments
SET grade = 85
WHERE student_id = 1 AND course_id = 3;

-- Verify the updated grade
SELECT students.name, courses.course_name, enrolments.grade
FROM enrolments
JOIN students ON students.id = enrolments.student_id
JOIN courses ON courses.id = enrolments.course_id
WHERE student_id = 1 AND course_id = 3;
