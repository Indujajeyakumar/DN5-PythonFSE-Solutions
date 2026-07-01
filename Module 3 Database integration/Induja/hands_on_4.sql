-- ============================================
-- HANDS-ON 4: Query Optimization
-- Indexes, EXPLAIN & N+1 Problem
-- ============================================

-- TASK 1: Baseline EXPLAIN (before indexes)
-- ============================================
EXPLAIN SELECT s.first_name, s.last_name, c.course_name 
FROM enrollments e 
JOIN students s ON s.student_id = e.student_id 
JOIN courses c ON c.course_id = e.course_id 
WHERE s.enrollment_year = 2022;

-- Baseline Results:
-- Seq Scan on enrollments (cost=0.00..26.30)
-- Seq Scan on students (cost=0.00..15.12) with Filter enrollment_year=2022
-- Index Scan on courses (already using primary key index)
-- Observation: enrollments and students doing full table scans

-- ============================================
-- TASK 2: Add Indexes and Compare
-- ============================================

-- B-Tree index on enrollment_year
CREATE INDEX idx_students_enrollment_year ON students(enrollment_year);

-- Composite UNIQUE index (also prevents duplicate enrollments)
CREATE UNIQUE INDEX idx_enrollments_student_course ON enrollments(student_id, course_id);

-- Index on course_code
CREATE INDEX idx_courses_code ON courses(course_code);

-- Partial index for NULL grades
CREATE INDEX idx_enrollments_null_grade ON enrollments(student_id) WHERE grade IS NULL;

-- Re-run EXPLAIN after indexes
EXPLAIN SELECT s.first_name, s.last_name, c.course_name 
FROM enrollments e 
JOIN students s ON s.student_id = e.student_id 
JOIN courses c ON c.course_id = e.course_id 
WHERE s.enrollment_year = 2022;

-- After Index Results:
-- Cost dropped significantly:
-- enrollments cost: 0.00..1.10 (was 26.30) 
-- students cost: 0.00..1.12 (was 15.12)
-- Still shows Seq Scan because table is small (10 rows)
-- PostgreSQL optimizer chooses Seq Scan for small tables
-- Index Scan kicks in for larger datasets (1000+ rows)

-- ============================================
-- TASK 3: N+1 Problem & Fix
-- ============================================

-- N+1 PROBLEM (bad approach - simulation):
-- Step 1: Fetch all enrollments (1 query)
-- SELECT * FROM enrollments; -- returns 10 rows
-- Step 2: For each row, fetch student name separately (10 more queries)
-- SELECT first_name, last_name FROM students WHERE student_id = 1;
-- SELECT first_name, last_name FROM students WHERE student_id = 2;
-- ... and so on
-- Total: 1 + 10 = 11 queries for 10 enrollments
-- In real app with 10,000 enrollments = 10,001 queries!

-- FIX: Single JOIN query (1 query only)
SELECT e.enrollment_id, s.first_name, s.last_name, c.course_name, e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- Result: All 10 enrollments with student and course names in 1 query
-- Query count: 1 (vs 11 with N+1 approach)
-- With 10,000 enrollments: 1 query (vs 10,001 with N+1)