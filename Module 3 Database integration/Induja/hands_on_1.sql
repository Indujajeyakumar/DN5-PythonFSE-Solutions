-- ============================================
-- HANDS-ON 1: Schema Design & Core SQL
-- ============================================

-- TASK 1: Create Tables
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    hod_name VARCHAR(100),
    budget DECIMAL(12,2)
);

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    date_of_birth DATE,
    department_id INT REFERENCES departments(department_id),
    enrollment_year INT
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(150) NOT NULL,
    course_code VARCHAR(20) UNIQUE,
    credits INT,
    department_id INT REFERENCES departments(department_id)
);

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(student_id),
    course_id INT REFERENCES courses(course_id),
    enrollment_date DATE,
    grade CHAR(2)
);

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    prof_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department_id INT REFERENCES departments(department_id),
    professor_salary DECIMAL(10,2)
);

-- SAMPLE DATA
INSERT INTO departments (dept_name, hod_name, budget) VALUES
 ('Computer Science', 'Dr. Ramesh Kumar', 850000.00),
 ('Electronics', 'Dr. Priya Nair', 620000.00),
 ('Mechanical', 'Dr. Suresh Iyer', 540000.00),
 ('Civil', 'Dr. Ananya Sharma', 430000.00);

INSERT INTO students (first_name, last_name, email, date_of_birth, department_id, enrollment_year) VALUES
 ('Arjun', 'Mehta', 'arjun.mehta@college.edu', '2003-04-12', 1, 2022),
 ('Priya', 'Suresh', 'priya.suresh@college.edu', '2003-07-25', 1, 2022),
 ('Rohan', 'Verma', 'rohan.verma@college.edu', '2002-11-08', 2, 2021),
 ('Sneha', 'Patel', 'sneha.patel@college.edu', '2004-01-30', 3, 2023),
 ('Vikram', 'Das', 'vikram.das@college.edu', '2003-09-14', 1, 2022),
 ('Kavya', 'Menon', 'kavya.menon@college.edu', '2002-05-17', 2, 2021),
 ('Aditya', 'Singh', 'aditya.singh@college.edu', '2004-03-22', 4, 2023),
 ('Deepika','Rao', 'deepika.rao@college.edu', '2003-08-09', 1, 2022);

INSERT INTO courses (course_name, course_code, credits, department_id) VALUES
 ('Data Structures & Algorithms', 'CS101', 4, 1),
 ('Database Management Systems', 'CS102', 3, 1),
 ('Object Oriented Programming', 'CS103', 4, 1),
 ('Circuit Theory', 'EC101', 3, 2),
 ('Thermodynamics', 'ME101', 3, 3);

INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
 (1, 1, '2022-07-01', 'A'), (1, 2, '2022-07-01', 'B'),
 (2, 1, '2022-07-01', 'B'), (2, 3, '2022-07-01', 'A'),
 (3, 4, '2021-07-01', 'A'), (4, 5, '2023-07-01', NULL),
 (5, 1, '2022-07-01', 'C'), (5, 2, '2022-07-01', 'A'),
 (6, 4, '2021-07-01', 'B'), (7, 5, '2023-07-01', NULL),
 (8, 1, '2022-07-01', 'A'), (8, 3, '2022-07-01', 'B');

INSERT INTO professors (prof_name, email, department_id, professor_salary) VALUES
 ('Dr. Anand Krishnan', 'anand.k@college.edu', 1, 95000.00),
 ('Dr. Meena Pillai', 'meena.p@college.edu', 1, 88000.00),
 ('Dr. Sunil Rajan', 'sunil.r@college.edu', 2, 82000.00),
 ('Dr. Latha Gopal', 'latha.g@college.edu', 3, 79000.00),
 ('Dr. Kartik Bose', 'kartik.b@college.edu', 4, 76000.00);

-- ============================================
-- TASK 2: Verify Normalisation
-- ============================================
-- 1NF: All columns hold atomic (single) values. 
-- Example violation: storing multiple phone numbers in one field 
-- like '9876543210,9876543211' would break 1NF. We don't do this.

-- 2NF: Every non-key column depends on the WHOLE primary key.
-- In enrollments, the candidate key is (student_id, course_id).
-- enrollment_date and grade depend on BOTH columns together. 2NF satisfied.

-- 3NF: No transitive dependencies exist.
-- If we stored dept_name directly in students, it would depend on 
-- department_id, not directly on student_id - violating 3NF.
-- We avoid this by keeping dept_name only in departments table.

-- ============================================
-- TASK 3: Alter and Extend the Schema
-- ============================================
ALTER TABLE students ADD COLUMN phone_number VARCHAR(15);
ALTER TABLE courses ADD COLUMN max_seats INT DEFAULT 60;
ALTER TABLE enrollments ADD CONSTRAINT chk_grade CHECK (grade IN ('A','B','C','D','F') OR grade IS NULL);
ALTER TABLE departments RENAME COLUMN hod_name TO head_of_dept;
ALTER TABLE students DROP COLUMN phone_number;