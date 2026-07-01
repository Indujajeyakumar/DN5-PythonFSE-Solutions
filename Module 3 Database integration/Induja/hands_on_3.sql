-- ============================================
-- HANDS-ON 3: Advanced SQL
-- Subqueries, Views & Transactions
-- ============================================

-- TASK 1: Subqueries
-- ============================================

-- Q1: Students enrolled in more courses than average
SELECT s.first_name, s.last_name, COUNT(e.course_id) AS course_count
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name
HAVING COUNT(e.course_id) > (
    SELECT AVG(course_count) 
    FROM (
        SELECT COUNT(course_id) AS course_count 
        FROM enrollments 
        GROUP BY student_id
    ) AS avg_table
);

-- Q2: Courses where all enrolled students got grade 'A'
SELECT course_name FROM courses c
WHERE NOT EXISTS (
    SELECT 1 FROM enrollments e
    WHERE e.course_id = c.course_id
    AND e.grade != 'A'
);

-- Q3: Professor with highest salary in each department
SELECT p.prof_name, p.professor_salary, d.dept_name
FROM professors p
JOIN departments d ON p.department_id = d.department_id
WHERE p.professor_salary = (
    SELECT MAX(p2.professor_salary)
    FROM professors p2
    WHERE p2.department_id = p.department_id
);

-- Q4: Departments where average salary exceeds 85,000
SELECT dept_name, avg_salary
FROM (
    SELECT d.dept_name, AVG(p.professor_salary) AS avg_salary
    FROM departments d
    JOIN professors p ON d.department_id = p.department_id
    GROUP BY d.dept_name
) AS dept_avg
WHERE avg_salary > 85000;

-- ============================================
-- TASK 2: Views
-- ============================================

CREATE VIEW vw_student_enrollment_summary AS
SELECT 
    s.first_name || ' ' || s.last_name AS full_name,
    d.dept_name,
    COUNT(e.course_id) AS courses_enrolled,
    ROUND(AVG(
        CASE 
            WHEN e.grade = 'A' THEN 4
            WHEN e.grade = 'B' THEN 3
            WHEN e.grade = 'C' THEN 2
            WHEN e.grade = 'D' THEN 1
            WHEN e.grade = 'F' THEN 0
        END
    ), 2) AS gpa
FROM students s
JOIN departments d ON s.department_id = d.department_id
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name, d.dept_name;

CREATE VIEW vw_course_stats AS
SELECT 
    c.course_name,
    c.course_code,
    COUNT(e.enrollment_id) AS total_enrollments,
    ROUND(AVG(
        CASE 
            WHEN e.grade = 'A' THEN 4
            WHEN e.grade = 'B' THEN 3
            WHEN e.grade = 'C' THEN 2
            WHEN e.grade = 'D' THEN 1
            WHEN e.grade = 'F' THEN 0
        END
    ), 2) AS avg_gpa
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name, c.course_code;

-- Single table view with CHECK OPTION
CREATE VIEW vw_cs_students AS
SELECT student_id, first_name, last_name, email, enrollment_year
FROM students
WHERE department_id = 1
WITH CHECK OPTION;

-- Query views
SELECT * FROM vw_student_enrollment_summary WHERE gpa > 3.0;
SELECT * FROM vw_course_stats;
SELECT * FROM vw_cs_students;

-- ============================================
-- TASK 3: Stored Procedure & Transactions
-- ============================================

-- Function to enroll student with duplicate check
CREATE OR REPLACE FUNCTION fn_enroll_student(
    p_student_id INT,
    p_course_id INT,
    p_enrollment_date DATE
) RETURNS TEXT AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM enrollments 
        WHERE student_id = p_student_id 
        AND course_id = p_course_id
    ) THEN
        RETURN 'Error: Student already enrolled in this course!';
    END IF;
    INSERT INTO enrollments (student_id, course_id, enrollment_date)
    VALUES (p_student_id, p_course_id, p_enrollment_date);
    RETURN 'Success: Student enrolled successfully!';
END;
$$ LANGUAGE plpgsql;

-- Test function
SELECT fn_enroll_student(9, 1, '2023-07-01'); -- Success
SELECT fn_enroll_student(9, 1, '2023-07-01'); -- Duplicate error

-- SAVEPOINT Transaction (concept)
-- BEGIN;
-- INSERT INTO enrollments (student_id, course_id, enrollment_date)
-- VALUES (10, 1, '2023-07-01');
-- SAVEPOINT after_first_insert;
-- INSERT INTO enrollments (student_id, course_id, enrollment_date)
-- VALUES (10, 999, '2023-07-01'); -- This fails (invalid course)
-- ROLLBACK TO SAVEPOINT after_first_insert; -- Undo only failed insert
-- COMMIT; -- Save only the first insert
-- Note: SAVEPOINT tested locally. DB Fiddle stops at FK error
-- so transaction block is commented out here.
-- Expected result: Only enrollment for course_id=1 persists.