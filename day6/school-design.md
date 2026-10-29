
# School Database Design

## 1. Tables

### Students
The `students` table stores each student's ID, name and email address.
The `id` column is the primary key. The email is required and unique
so that two students cannot register using the same email address.

### Courses
The `courses` table stores each course's ID and course name.
The `id` column is the primary key, and the course name is required
and unique.

### Enrolments
The `enrolments` table records which student takes which course and
the student's grade. It contains `student_id` and `course_id` as
foreign keys, referencing the `students` and `courses` tables.
The grade must be between 0 and 100.

The combination of `student_id` and `course_id` forms a composite
primary key. This prevents the same student from enrolling in the
same course more than once.

## 2. Relationships

**One-to-many:** One student can have many enrolments, but each
enrolment belongs to one student. Similarly, one course can have
many enrolments, but each enrolment refers to one course.

**Many-to-many:** Students and courses have a many-to-many
relationship. A student can take several courses, and each course
can have several students.

The `enrolments` table is the join table that resolves this
many-to-many relationship. It also stores the grade for each
student-course combination.

## 3. Index

I would add an index on `enrolments(course_id)` to help the database
find all enrolments for a particular course efficiently. This
supports queries that list students on a course and count students
per course.

SQLite automatically indexes primary keys. The composite primary
key on `(student_id, course_id)` is useful for searches beginning
with `student_id`, but it does not replace the separate index on
`course_id`.

## 4. SQL or NoSQL?

I would choose a relational SQL database for this school system.
Students, courses and enrolments have clear relationships, and
foreign keys and constraints help maintain data integrity. SQL
joins make it straightforward to list courses for a student,
find students on a course and calculate enrolment counts.
Transactions can also help ensure that related database changes
are completed consistently. A NoSQL database could be useful for
other requirements involving highly flexible or unstructured data,
but SQL is a better fit for this system's structured relationships.
