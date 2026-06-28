-- ============================================
-- HANDS-ON 2: Writing SQL Queries - DML, Joins & Aggregations
-- ============================================

-- TASK 1: Insert, Update, Delete
INSERT INTO students (first_name, last_name, email, date_of_birth, department_id, enrollment_year) VALUES
 ('Karthik', 'Raj', 'karthik.raj@college.edu', '2003-06-15', 2, 2022),
 ('Meera', 'Iyer', 'meera.iyer@college.edu', '2004-02-20', 1, 2023);

UPDATE enrollments 
SET grade = 'B' 
WHERE student_id = 5 AND course_id = 1;

DELETE FROM enrollments WHERE grade IS NULL;

-- Verify counts
SELECT COUNT(*) AS total_students FROM students;   -- Expected: 10
SELECT COUNT(*) AS total_enrollments FROM enrollments; -- Expected: 10

-- ============================================
-- TASK 2: Single-Table Queries and Filtering
-- ============================================

-- Students enrolled in 2022, ordered by last_name
SELECT first_name, last_name, enrollment_year 
FROM students 
WHERE enrollment_year = 2022 
ORDER BY last_name ASC;

-- Courses with more than 3 credits, sorted by credits descending
SELECT course_name, credits 
FROM courses 
WHERE credits > 3 
ORDER BY credits DESC;

-- Professors with salary between 80,000 and 95,000
SELECT prof_name, professor_salary 
FROM professors 
WHERE professor_salary BETWEEN 80000 AND 95000;

-- Students whose email ends with '@college.edu'
SELECT first_name, last_name, email 
FROM students 
WHERE email LIKE '%@college.edu';

-- Count of students per enrollment_year
SELECT enrollment_year, COUNT(*) AS student_count 
FROM students 
GROUP BY enrollment_year 
ORDER BY enrollment_year;
-- Expected: 3 rows (2021, 2022, 2023)

-- ============================================
-- TASK 3: Multi-Table Joins
-- ============================================

-- Student's full name with department name
SELECT s.first_name || ' ' || s.last_name AS full_name, d.dept_name
FROM students s
JOIN departments d ON s.department_id = d.department_id;

-- Enrollment with student name and course name (3-table join)
SELECT s.first_name || ' ' || s.last_name AS student_name, c.course_name, e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- Students NOT enrolled in any course (LEFT JOIN)
-- Returns 4 rows: Meera, Sneha, Karthik, Aditya
-- (Sneha & Aditya's only enrollments had NULL grade and were deleted in Task 1)
SELECT s.first_name, s.last_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL;

-- Every course with number of students enrolled (including 0)
SELECT c.course_name, COUNT(e.enrollment_id) AS num_students
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name;

-- Each department with its professors and salaries
SELECT d.dept_name, p.prof_name, p.professor_salary
FROM departments d
LEFT JOIN professors p ON d.department_id = p.department_id;

-- ============================================
-- TASK 4: Aggregations and Grouping
-- ============================================

-- Total enrollments per course
SELECT c.course_name, COUNT(e.enrollment_id) AS enrollment_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name;

-- Average salary of professors per department
SELECT d.dept_name, ROUND(AVG(p.professor_salary), 2) AS avg_salary
FROM departments d
JOIN professors p ON d.department_id = p.department_id
GROUP BY d.dept_name;
-- Expected: 4 rows

-- Departments where total budget exceeds 600,000
SELECT dept_name, budget
FROM departments
WHERE budget > 600000;

-- Grade distribution for course CS101
SELECT e.grade, COUNT(*) AS grade_count
FROM enrollments e
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_code = 'CS101'
GROUP BY e.grade;

-- Departments with more than 2 students enrolled (HAVING)
SELECT d.dept_name, COUNT(DISTINCT e.student_id) AS student_count
FROM departments d
JOIN students s ON d.department_id = s.department_id
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY d.dept_name
HAVING COUNT(DISTINCT e.student_id) > 2;