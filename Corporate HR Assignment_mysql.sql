
-- SECTION A – DDL (Database Design)
-- • 1. Create database company_db.
-- • 2. Create tables: departments, employees, projects, employee_project with proper Primary
-- Keys and Foreign Keys.
-- • 3. Add NOT NULL, UNIQUE and CHECK constraints wherever applicable.
-- • 4. Add an index on employee salary column


-- • 1. Create database company_db.
USE company_db;
use assignment;

-- - • 2. Create tables: departments, employees, projects, employee_project with proper Primary
-- -- Keys and Foreign Keys.

CREATE TABLE `assignment`.`department` (
  `depart_id` INT NOT NULL,
  `depart_name` VARCHAR(45) NULL,
  PRIMARY KEY (`depart_id`));
  -- imported data from from csv files 
  select * from department ;
  
  CREATE TABLE employee(
  emp_id INT NOT NULL,
  emp_name VARCHAR(30) NOT NULL,
  dept_id int ,
  designation VARCHAR(15) NOT NULL,
  salary  FLOAT DEFAULT  0,
  hire_date DATE,
  PRIMARY KEY(emp_id),
  FOREIGN KEY (dept_id) REFERENCES department(depart_id) ON DELETE CASCADE
  );
  

CREATE TABLE `assignment`.`project real` (
  `project_id` INT NOT NULL,
  `project_name` VARCHAR(45) NULL,
  `dept_id` INT NOT NULL,
  `budget` bigint NULL,
  PRIMARY KEY (`project_id`),
FOREIGN KEY (dept_id) REFERENCES Department(depart_id) ON DELETE CASCADE
);
-- select * from project real ;

CREATE TABLE `assignment`.`project` (
  `project_id` INT NOT NULL,
  `project_name` VARCHAR(45) NULL,
  `dept_id` INT NOT NULL,
  `budget` bigint NULL,
  PRIMARY KEY (`project_id`),
FOREIGN KEY (dept_id) REFERENCES Department(depart_id) ON DELETE CASCADE
);
SELECT * FROM project ;


-- • 3. Add NOT NULL, UNIQUE and CHECK constraints wherever applicable.
CREATE TABLE `assignment`.`emp_project` (
  `assignment_id` INT NOT NULL,
  `employee_id` INT NULL,
  `project_id` INT NULL,
  `hours_worked` INT NULL,
  PRIMARY KEY (`assignment_id`),
  FOREIGN KEY (employee_id) REFERENCES employee(emp_id) ON UPDATE CASCADE,
  FOREIGN KEY (project_id) REFERENCES project(project_id)ON UPDATE CASCADE
  );
  
SELECT * FROM emp_project;

-- 4. Add Index on Employee Salary Column

CREATE INDEX idx_emp_salary
ON employee(salary);



--  5. Insert at least 5 new employees manually.
-- • 6. Update salary of employees in IT department by 10%.
-- • 7. Delete employees who have salary less than 30000.

-- create index for  smooth 
CREATE INDEX idx_emp_sal ON employee(salary);


--   5. Insert at least 5 new employees manually.
SELECT * FROM employee;
INSERT INTO employee VALUES
(101, 'Shahrukh Khan', 1, 'Analyst', 100000, CURDATE()),
(102, 'Raju Pande', 2, 'Analyst', 95000, CURDATE()),
(103, 'Ramu Singh', 3, 'Manager', 1010000, CURDATE()),
(104, 'Karan Meshram', 4, 'CEO', 1500000, CURDATE()),
(105, 'Manish Patle', 5, 'Executive', 80000, CURDATE());

--  • 6. Update salary of employees in IT department by 10%.
SET SQL_SAFE_UPDATES = 0;
UPDATE employee 
SET salary = salary + salary * 0.10
WHERE dept_id = (
    SELECT depart_id 
    FROM department 
    WHERE depart_name = 'IT'
);

-- 7. Delete employees who have salary less than 30000.
SET SQL_SAFE_UPDATES = 0;
DELETE FROM employee
WHERE salary < 30000;
SET SQL_SAFE_UPDATES = 1;

-- SECTION C – DQL (Queries)  
--  8. Display all employees hired after 2022.
-- • 9. Find average salary department-wise.
-- • 10. Find total hours worked per project.
-- • 11. Find highest paid employee in each department

--  8. Display all employees hired after 2022.

SELECT * FROM employee
WHERE hire_date > '2022-12-31';



-- • 9. Find average salary department-wise.

SELECT d.depart_name,
AVG(e.salary) AS avg_salary
FROM department d
LEFT JOIN employee e 
ON d.depart_id = e.dept_id
GROUP BY d.depart_name;

-- below is the avg salary department wise

-- • 10. Find total hours worked per project
SELECT p.project_id,
       p.project_name,
       IFNULL(SUM(ep.hours_worked), 0) AS total_hours_worked
FROM project p
LEFT JOIN emp_project ep
       ON p.project_id = ep.project_id
GROUP BY p.project_id, p.project_name;




-- • 11. Find highest paid employee in each department
SELECT d.depart_name,
       e.emp_id,
       e.emp_name,
       e.salary
FROM employee e
JOIN department d 
     ON e.dept_id = d.depart_id
JOIN (
        SELECT dept_id, MAX(salary) AS max_salary
        FROM employee
        GROUP BY dept_id
     ) m
ON e.dept_id = m.dept_id
AND e.salary = m.max_salary;
--  m  is temp subquery and join

--  SECTION D – JOINS
-- • 12. Display employee name with department name.
-- • 13. Show project name with total hours worked using JOIN.
-- • 14. List employees who are not assigned to any project.

-- • 12. Display employee name with department name.
SELECT e.emp_name,
       d.depart_name
FROM employee e
JOIN department d
     ON e.dept_id = d.depart_id; 
	
    
     
     
-- • 13. Show project name with total hours worked using JOIN.
SELECT p.project_name,
       SUM(ep.hours_worked) AS total_hours
FROM project p
JOIN emp_project ep
     ON p.project_id = ep.project_id
GROUP BY p.project_name;

-- all emp = left join 
-- inner join = no data miss , miss data fro left , and right 
-- right join 
-- full join is expensive 

-- • 14. List employees who are not assigned to any project.
SELECT e.emp_id,
       e.emp_name
FROM employee e
LEFT JOIN emp_project ep
       ON e.emp_id = ep.employee_id
WHERE ep.employee_id IS NULL; 


SELECT e.* FROM  
employee e LEFT JOIN emp_project ep  
ON e.emp_id = ep.employee_id
WHERE ep.employee_id IS NULL;

-- SECTION E – VIEWS
--  • 15. Create a view showing department-wise total salary expense.
--  • 16. Create a view for employees earning above average salary.

--  • 15. Create a view showing department-wise total salary expense.

DROP VIEW IF EXISTS dept_salary_expense;
CREATE VIEW dept_salary_expense AS
SELECT d.depart_id,
       d.depart_name,
       IFNULL(SUM(e.salary), 0) AS total_salary_expense
FROM department d
LEFT JOIN employee e 
       ON d.depart_id = e.dept_id
GROUP BY d.depart_id, d.depart_name;
SELECT * FROM dept_salary_expense;


CREATE VIEW dept_wise_sal_exp 
AS 
SELECT d.dept_name ,SUM(e.salary ) AS  TOTAL_SAL_EXP FROM  department d LEFT JOIN  employee e on d.dept_id = e.dept_id;
GROUP BY d.dept_name ORDER BY d.dept_name ASC;


--  • 16. Create a view for employees earning above average salary.
CREATE VIEW above_avg_salary_employees AS
SELECT emp_id,
       emp_name,
       dept_id,
       designation,
       salary,
       hire_date
FROM employee
WHERE salary > (
    SELECT AVG(salary) FROM employee
);
SELECT * FROM above_avg_salary_employees;


CREATE VIEW emp_mor_avg_sal AS
SELECT * FROM  employee where salary > (select avg(salary) FROM employee);
select * from emp_mor_avg_sal ;


--  SECTION F – STORED PROCEDURES & FUNCTIONS
-- • 17. Create a stored procedure to get employees by department_id.
-- • 18. Create a stored procedure to increase salary by given percentage.
-- • 19. Create a function to calculate annual salary

-- • 17. Create a stored procedure to get employees by department_id.
DELIMITER //

CREATE PROCEDURE  GetEmployeesByDepart(IN p_dept_id INT)
BEGIN
    SELECT emp_id,
           emp_name,
           dept_id,
           designation,
           salary,
           hire_date
    FROM employee
    WHERE dept_id = p_dept_id;
END //
DELIMITER ;



-- 2 

-- Drop procedure if already exists
DROP PROCEDURE IF EXISTS get_emp;

-- Change delimiter
DELIMITER $$

-- Create procedure
CREATE PROCEDURE get_emp(IN ids INT)
BEGIN
    SELECT * 
    FROM employee
    WHERE dept_id = ids;
END $$

-- Reset delimiter back to normal
DELIMITER ;

-- Call the procedure (Example: dept_id = 1)
CALL get_emp(1);
-- end 

-- • 18. Create a stored procedure to increase salary by given percentage.
-- Step 1: Select database
USE your_database_name;
-- Step 2: Drop procedure if exists
DROP PROCEDURE IF EXISTS sp_increase_salary;
-- Step 3: Change delimiter
DELIMITER //
-- Step 4: Create procedure
CREATE PROCEDURE sp_increase_salary(IN p_percent DECIMAL(5,2))
BEGIN
    UPDATE employee
    SET salary = salary + (salary * p_percent / 100);
END //
-- Step 5: Reset delimiter
DELIMITER ;
-- Step 6: Call procedure (Example: 25%)
CALL sp_increase_salary(25);
-- Step 7: Check result
SELECT * FROM employee;





-- • 19. Create a function to calculate annual salary
DROP FUNCTION IF EXISTS CalculateAnnualSalary;
✅ Step 2: Create Function
DELIMITER //

CREATE FUNCTION CalculateAnnualSalary(p_emp_id INT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE annual_salary FLOAT;

    SELECT salary * 12
    INTO annual_salary
    FROM employee
    WHERE emp_id = p_emp_id;

    RETURN annual_salary;
END //

DELIMITER ;


--  SECTION G – WINDOW FUNCTIONS
-- • 20. Rank employees based on salary within each department.
-- • 21. Find second highest salary in each department.
-- • 22. Calculate running total of salaries department-wise

-- • 20. Rank employees based on salary within each department.
SELECT emp_id,
       emp_name,
       dept_id,
       designation,
       salary,
       RANK() OVER (
           PARTITION BY dept_id 
           ORDER BY salary DESC
       ) AS salary_rank
FROM employee;



-- • 21. Find second highest salary in each department.

SELECT emp_id,
       emp_name,
       dept_id,
       salary
FROM (
    SELECT emp_id,
           emp_name,
           dept_id,
           salary,
           DENSE_RANK() OVER (
               PARTITION BY dept_id
               ORDER BY salary DESC
           ) AS rnk
    FROM employee
) AS ranked_data
WHERE rnk = 2;

-- • 22. Calculate running total of salaries department-wise
SELECT emp_id,
       emp_name,
       dept_id,
       salary,
       SUM(salary) OVER (
           PARTITION BY dept_id
           ORDER BY salary
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total_salary
FROM employee;






