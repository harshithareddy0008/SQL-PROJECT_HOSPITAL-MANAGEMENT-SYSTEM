-- =====================================================================
-- SECTION 1: DATABASE & TABLE BASICS
-- =====================================================================

DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db;
USE hospital_db;


CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL
);


CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    date_of_birth DATE,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    blood_group VARCHAR(5),
    CONSTRAINT uq_patient_email UNIQUE (email),
    CONSTRAINT chk_patient_gender
        CHECK (gender IN ('Male','Female','Other'))
);


CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    city VARCHAR(50),
    salary DECIMAL(10,2) NOT NULL,
    consultation_fee DECIMAL(10,2) NOT NULL,
    department_id INT NOT NULL,
    CONSTRAINT uq_doctor_email UNIQUE (email),
    CONSTRAINT chk_doctor_salary CHECK (salary >= 0),
    CONSTRAINT chk_consultation_fee CHECK (consultation_fee >= 0),
    CONSTRAINT fk_doctor_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);


CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(100) NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    manager_id INT NULL,
    department_id INT NOT NULL,
    CONSTRAINT chk_employee_salary CHECK (salary >= 0),
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (manager_id)
        REFERENCES employees(employee_id),
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);


CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type VARCHAR(20) NOT NULL,
    daily_charge DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Available',
    CONSTRAINT chk_room_type
        CHECK (room_type IN ('General','Private','ICU')),
    CONSTRAINT chk_room_charge
        CHECK (daily_charge >= 0),
    CONSTRAINT chk_room_status
        CHECK (status IN ('Available','Occupied','Maintenance'))
);


CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    notes VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_appointment_status
        CHECK (status IN ('Scheduled','Completed','Cancelled')),
    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    CONSTRAINT fk_appointment_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
);


CREATE TABLE admissions (
    admission_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    room_id INT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE NULL,
    diagnosis VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'Admitted',
    CONSTRAINT chk_admission_status
        CHECK (status IN ('Admitted','Discharged')),
    CONSTRAINT chk_discharge_date
        CHECK (discharge_date IS NULL OR discharge_date >= admission_date),
    CONSTRAINT fk_admission_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    CONSTRAINT fk_admission_room
        FOREIGN KEY (room_id)
        REFERENCES rooms(room_id)
);


CREATE TABLE medicines (
    medicine_id INT PRIMARY KEY AUTO_INCREMENT,
    medicine_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_medicine_price CHECK (price >= 0),
    CONSTRAINT chk_medicine_stock CHECK (stock >= 0)
);


CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    doctor_id INT NOT NULL,
    patient_id INT NOT NULL,
    medicine_id INT NOT NULL,
    quantity INT NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    prescribed_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT chk_prescription_quantity CHECK (quantity > 0),
    CONSTRAINT fk_prescription_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id),
    CONSTRAINT fk_prescription_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),
    CONSTRAINT fk_prescription_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    CONSTRAINT fk_prescription_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(medicine_id)
);


CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    appointment_id INT NULL,
    admission_id INT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Paid',
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    CONSTRAINT chk_payment_method
        CHECK (payment_method IN ('Cash','Card','UPI','Insurance')),
    CONSTRAINT chk_payment_status
        CHECK (payment_status IN ('Paid','Pending','Failed')),
    CONSTRAINT fk_payment_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    CONSTRAINT fk_payment_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id),
    CONSTRAINT fk_payment_admission
        FOREIGN KEY (admission_id)
        REFERENCES admissions(admission_id)
);


CREATE TABLE audit_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(100) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    record_id INT,
    old_value VARCHAR(255),
    new_value VARCHAR(255),
    description VARCHAR(255),
    action_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- Display the structure of every core table.
DESCRIBE patients;
DESCRIBE departments;
DESCRIBE doctors;
DESCRIBE employees;
DESCRIBE rooms;
DESCRIBE appointments;
DESCRIBE admissions;
DESCRIBE medicines;
DESCRIBE prescriptions;
DESCRIBE payments;
DESCRIBE audit_logs;

-- =====================================================================
-- SECTION 2: SAMPLE DATA
-- Required minimums:
--   20 patients, 5 departments, 10 doctors, 10 employees,
--   15 rooms, 30 appointments, plus other transaction data.
-- =====================================================================

INSERT INTO departments (department_name, location) VALUES
('Cardiology','Block A'),
('Neurology','Block B'),
('Orthopedics','Block C'),
('Pediatrics','Block D'),
('General Medicine','Block E');


INSERT INTO patients
(patient_name, gender, date_of_birth, phone, email, city, blood_group)
VALUES
('Arjun Reddy','Male','1994-05-10','9000000001','arjun@gmail.com','Hyderabad','O+'),
('Anjali Sharma','Female','1998-08-15','9000000002','anjali@gmail.com','Secunderabad','A+'),
('Rahul Verma','Male','1989-02-21','9000000003','rahul@gmail.com','Warangal','B+'),
('Sneha Rao','Female','1996-03-12','9000000004','sneha@gmail.com','Hyderabad','AB+'),
('Vikram Singh','Male','1985-10-05','9000000005','vikram@gmail.com','Karimnagar','O-'),
('Priya Nair','Female','1992-07-22','9000000006','priya@gmail.com','Hyderabad','A-'),
('Akhil Kumar','Male','2000-01-18','9000000007','akhil@gmail.com','Nizamabad','B+'),
('Divya Reddy','Female','1997-11-09','9000000008','divya@gmail.com','Hyderabad','O+'),
('Kiran Rao','Male','1991-09-14','9000000009','kiran@gmail.com','Khammam','AB-'),
('Meghana Das','Female','1999-06-30','9000000010','meghana@gmail.com','Hyderabad','A+'),
('Rohit Kumar','Male','1988-12-24','9000000011','rohit@gmail.com','Warangal','O+'),
('Aparna Reddy','Female','1995-05-16','9000000012','aparna@gmail.com','Hyderabad','B+'),
('Suresh Babu','Male','1982-04-11','9000000013','suresh@gmail.com','Karimnagar','A+'),
('Neha Gupta','Female','1993-08-01','9000000014','neha@gmail.com','Hyderabad','O+'),
('Manoj Kumar','Male','1987-02-17','9000000015','manoj@gmail.com','Secunderabad','B-'),
('Keerthi Rao','Female','2001-07-19','9000000016','keerthi@gmail.com','Hyderabad','AB+'),
('Aditya Sharma','Male','1990-03-27','9000000017','aditya@gmail.com','Nizamabad','A+'),
('Pooja Singh','Female','1994-09-08','9000000018','pooja@gmail.com','Warangal','O+'),
('Naveen Reddy','Male','1986-06-05','9000000019','naveen@gmail.com','Hyderabad','B+'),
('Swathi Nair','Female','1998-10-13','9000000020','swathi@gmail.com','Khammam','A+');


-- 13 doctors so GROUP BY/HAVING examples return useful results.
INSERT INTO doctors
(doctor_name, specialization, email, phone, city, salary, consultation_fee, department_id)
VALUES
('Dr. Ramesh','Cardiologist','ramesh@hospital.com','8000000001','Hyderabad',85000,800,1),
('Dr. Sita','Cardiologist','sita@hospital.com','8000000002','Hyderabad',78000,700,1),
('Dr. Leela','Cardiologist','leela@hospital.com','8000000011','Secunderabad',73000,650,1),
('Dr. Varun','Cardiologist','varun@hospital.com','8000000012','Hyderabad',69000,600,1),
('Dr. Anand','Neurologist','anand@hospital.com','8000000003','Hyderabad',92000,1000,2),
('Dr. Kavya','Neurologist','kavya@hospital.com','8000000004','Secunderabad',88000,900,2),
('Dr. Sandeep','Neurologist','sandeep@hospital.com','8000000013','Hyderabad',76000,750,2),
('Dr. Mohan','Orthopedic','mohan@hospital.com','8000000005','Hyderabad',76000,750,3),
('Dr. Geetha','Orthopedic','geetha@hospital.com','8000000006','Warangal',72000,700,3),
('Dr. Ravi','Pediatrician','ravi@hospital.com','8000000007','Hyderabad',68000,600,4),
('Dr. Latha','Pediatrician','latha@hospital.com','8000000008','Hyderabad',65000,550,4),
('Dr. Ajay','Physician','ajay@hospital.com','8000000009','Karimnagar',70000,650,5),
('Dr. Nisha','Physician','nisha@hospital.com','8000000010','Hyderabad',74000,700,5);


INSERT INTO employees
(employee_name, job_title, salary, manager_id, department_id)
VALUES
('Rajesh','Hospital Manager',90000,NULL,5);

INSERT INTO employees
(employee_name, job_title, salary, manager_id, department_id)
VALUES
('Suman','Receptionist',30000,1,5),
('Mahesh','Accountant',45000,1,5),
('Lakshmi','Nurse',40000,1,1),
('Rupa','Nurse',42000,1,2),
('Satish','Lab Technician',38000,1,5),
('Deepa','Pharmacist',43000,1,5),
('Harish','Ward Assistant',25000,1,3),
('Meena','HR Executive',50000,1,5),
('Prakash','Security',22000,1,5);


INSERT INTO rooms
(room_number, room_type, daily_charge, status)
VALUES
('G101','General',1500,'Available'),
('G102','General',1500,'Occupied'),
('G103','General',1500,'Available'),
('G104','General',1500,'Available'),
('G105','General',1500,'Occupied'),
('P201','Private',3000,'Occupied'),
('P202','Private',3000,'Available'),
('P203','Private',3500,'Available'),
('P204','Private',3500,'Occupied'),
('P205','Private',3000,'Available'),
('I301','ICU',8000,'Occupied'),
('I302','ICU',8000,'Available'),
('I303','ICU',8500,'Occupied'),
('I304','ICU',8500,'Available'),
('I305','ICU',9000,'Maintenance');


INSERT INTO medicines
(medicine_name, category, price, stock)
VALUES
('Paracetamol','Pain Relief',50,100),
('Amoxicillin','Antibiotic',120,60),
('Azithromycin','Antibiotic',180,40),
('Metformin','Diabetes',90,80),
('Aspirin','Cardiac',70,55),
('Atorvastatin','Cardiac',150,30),
('Ibuprofen','Pain Relief',60,45),
('Cetirizine','Allergy',40,70),
('Omeprazole','Gastro',110,35),
('Insulin','Diabetes',450,25),
('Montelukast','Allergy',95,20),
('Calcium Tablets','Supplements',130,50);


-- 31 appointments are inserted; one safe demo row is deleted later,
-- leaving 30 appointments in the database.
INSERT INTO appointments
(patient_id, doctor_id, appointment_date, status, notes)
VALUES
(1,1,'2026-07-05 10:00:00','Completed','Chest pain'),
(2,5,'2026-07-06 11:00:00','Completed','Headache'),
(3,8,'2026-07-10 09:30:00','Completed','Knee pain'),
(4,10,'2026-07-12 12:00:00','Completed','Fever'),
(5,12,'2026-07-15 10:00:00','Completed','General checkup'),
(6,2,'2026-08-03 15:00:00','Completed','BP issue'),
(7,6,'2026-08-04 10:30:00','Completed','Migraine'),
(8,9,'2026-08-05 14:00:00','Completed','Back pain'),
(9,11,'2026-08-06 11:00:00','Completed','Child consultation'),
(10,13,'2026-08-08 16:00:00','Completed','Cold'),
(11,1,'2026-08-10 10:00:00','Completed','Heart check'),
(12,5,'2026-08-12 13:00:00','Completed','Dizziness'),
(13,8,'2026-08-13 09:00:00','Completed','Fracture follow-up'),
(14,10,'2026-08-15 10:00:00','Completed','Fever'),
(15,12,'2026-08-17 11:00:00','Completed','Diabetes review'),
(16,2,'2026-09-01 12:00:00','Completed','Cardiac review'),
(17,6,'2026-09-02 10:00:00','Completed','Neurology review'),
(18,9,'2026-09-03 15:00:00','Completed','Joint pain'),
(19,11,'2026-09-04 09:30:00','Completed','Pediatric review'),
(1,3,'2026-09-05 10:00:00','Completed','Follow-up'),
(2,7,'2026-09-06 11:00:00','Completed','Follow-up'),
(3,8,'2026-09-07 12:00:00','Completed','Follow-up'),
(4,10,'2026-09-08 13:00:00','Completed','Follow-up'),
(5,13,'2026-09-09 14:00:00','Completed','Follow-up'),
(6,1,'2026-09-15 10:00:00','Completed','Cardiology follow-up'),
(7,5,'2026-09-16 11:00:00','Completed','Neurology follow-up'),
(8,8,'2026-09-18 12:00:00','Completed','Orthopedic follow-up'),
(9,10,'2026-09-20 13:00:00','Cancelled','Patient unavailable'),
(10,12,'2026-09-28 14:00:00','Scheduled',NULL),
(11,4,'2026-09-29 15:00:00','Scheduled',NULL),
(12,3,TIMESTAMP(CURDATE(),'10:30:00'),'Scheduled','Today appointment');


INSERT INTO admissions
(patient_id, room_id, admission_date, discharge_date, diagnosis, status)
VALUES
(1,11,'2026-07-01','2026-07-04','Cardiac observation','Discharged'),
(3,6,'2026-07-08','2026-07-11','Knee procedure','Discharged'),
(5,2,'2026-08-01','2026-08-04','Viral fever','Discharged'),
(7,13,'2026-08-03','2026-08-07','Neurological observation','Discharged'),
(9,9,'2026-08-05','2026-08-08','Pediatric observation','Discharged'),
(12,5,'2026-09-10',NULL,'Recovery monitoring','Admitted'),
(15,4,'2026-09-14','2026-09-16','Diabetes stabilization','Discharged'),
(18,3,'2026-09-18','2026-09-20','Joint observation','Discharged');


INSERT INTO prescriptions
(appointment_id, doctor_id, patient_id, medicine_id, quantity, dosage, prescribed_date)
VALUES
(1,1,1,5,10,'1 tablet daily','2026-07-05'),
(2,5,2,3,5,'1 tablet daily','2026-07-06'),
(3,8,3,7,10,'After food','2026-07-10'),
(4,10,4,1,10,'Twice daily','2026-07-12'),
(5,12,5,8,5,'Once daily','2026-07-15'),
(6,2,6,6,10,'Once daily','2026-08-03'),
(7,6,7,3,5,'Once daily','2026-08-04'),
(8,9,8,7,10,'Twice daily','2026-08-05'),
(9,11,9,1,5,'Twice daily','2026-08-06'),
(10,13,10,8,10,'At night','2026-08-08'),
(11,1,11,5,10,'Daily','2026-08-10'),
(12,5,12,2,5,'Twice daily','2026-08-12'),
(13,8,13,12,15,'Daily','2026-08-13'),
(14,10,14,1,10,'Twice daily','2026-08-15'),
(15,12,15,4,30,'Twice daily','2026-08-17'),
(16,2,16,6,15,'Daily','2026-09-01'),
(17,6,17,3,5,'Daily','2026-09-02'),
(18,9,18,7,10,'After food','2026-09-03'),
(19,11,19,1,5,'Twice daily','2026-09-04'),
(20,3,1,5,10,'Daily','2026-09-05');


INSERT INTO payments
(patient_id, appointment_id, admission_id, amount, payment_date, payment_method, payment_status)
VALUES
(1,NULL,1,45000,'2026-07-04','Insurance','Paid'),
(3,NULL,2,32000,'2026-07-11','Card','Paid'),
(1,1,NULL,8000,'2026-07-05','UPI','Paid'),
(2,2,NULL,7000,'2026-07-06','Cash','Paid'),
(3,3,NULL,9000,'2026-07-10','Card','Paid'),
(4,4,NULL,6000,'2026-07-12','UPI','Paid'),
(5,NULL,3,18000,'2026-08-04','UPI','Paid'),
(7,NULL,4,55000,'2026-08-07','Insurance','Paid'),
(9,NULL,5,22000,'2026-08-08','Cash','Paid'),
(6,6,NULL,5000,'2026-08-03','UPI','Paid'),
(7,7,NULL,12000,'2026-08-04','Card','Paid'),
(8,8,NULL,6500,'2026-08-05','UPI','Paid'),
(10,10,NULL,8000,'2026-08-08','Cash','Paid'),
(11,11,NULL,7500,'2026-08-10','Card','Paid'),
(12,12,NULL,9000,'2026-08-12','UPI','Paid'),
(15,NULL,7,28000,'2026-09-16','Insurance','Paid'),
(18,NULL,8,16000,'2026-09-20','Card','Paid'),
(16,16,NULL,8500,'2026-09-01','UPI','Paid'),
(17,17,NULL,9500,'2026-09-02','Card','Paid'),
(18,18,NULL,6500,'2026-09-03','UPI','Paid'),
(19,19,NULL,5500,'2026-09-04','Cash','Paid'),
(1,20,NULL,8000,'2026-09-05','UPI','Paid'),
(2,21,NULL,7000,'2026-09-06','Cash','Paid'),
(3,22,NULL,9000,'2026-09-07','Card','Paid'),
(4,23,NULL,6000,'2026-09-08','UPI','Paid'),
(5,24,NULL,7500,'2026-09-09','Cash','Paid'),
(12,NULL,6,15000,'2026-09-12','Card','Pending');


-- =====================================================================
-- SECTION 3: DDL COMMANDS
-- =====================================================================

-- 3.1 ALTER TABLE: add a new column to patients.
ALTER TABLE patients
ADD COLUMN temp_contact VARCHAR(20);

-- 3.2 ALTER TABLE: modify an existing column.
ALTER TABLE patients
MODIFY COLUMN city VARCHAR(80) NOT NULL;

-- 3.3 ALTER TABLE: rename a column.
ALTER TABLE patients
RENAME COLUMN temp_contact TO emergency_contact;

-- 3.4 RENAME TABLE query.
-- Rename and immediately rename back so the rest of the project continues.
RENAME TABLE audit_logs TO audit_logs_demo;
RENAME TABLE audit_logs_demo TO audit_logs;

-- 3.5 Add a constraint.
ALTER TABLE patients
ADD CONSTRAINT chk_patient_phone_demo
CHECK (CHAR_LENGTH(phone) >= 10);

-- 3.6 Drop a constraint.
ALTER TABLE patients
DROP CHECK chk_patient_phone_demo;

-- 3.7 Temporary table for today's appointments.
CREATE TEMPORARY TABLE todays_appointments AS
SELECT
    appointment_id,
    patient_id,
    doctor_id,
    appointment_date,
    status
FROM appointments
WHERE DATE(appointment_date) = CURDATE();

SELECT * FROM todays_appointments;

-- 3.8 TRUNCATE temporary/staging table.
TRUNCATE TABLE todays_appointments;

-- 3.9 DROP temporary table.
DROP TEMPORARY TABLE todays_appointments;

-- Requirement: DROP DATABASE after completing the project.
-- DO NOT execute this until your final demo is finished.
-- DROP DATABASE hospital_db;

-- ============================================================================================================================
-- =====================================================================
-- SECTION 4: INSERT / UPDATE / DELETE
-- =====================================================================

-- Data insertion requirements are already satisfied in SECTION 2.

-- 4.1 Change a patient's city.
UPDATE patients
SET city = 'Secunderabad'
WHERE patient_id = 6;

-- 4.2 Increase selected doctor salaries by 10%.
UPDATE doctors
SET salary = salary * 1.10
WHERE department_id = 4;

-- 4.3 Increase medicine stock for selected medicines.
UPDATE medicines
SET stock = stock + 20
WHERE medicine_id IN (
    SELECT medicine_id
    FROM (
        SELECT medicine_id
        FROM medicines
        WHERE category = 'Antibiotic'
    ) AS selected_medicines
);

-- 4.4 Delete a particular appointment.
-- Appointment 30 has no child prescription/payment rows.
DELETE FROM appointments
WHERE appointment_id = 30;

-- 4.5 Delete patients satisfying a condition.
-- Insert a safe demo row first so no FK relationship is affected.
INSERT INTO patients
(patient_name, gender, date_of_birth, phone, email, city, blood_group)
VALUES
('Delete Demo','Other','2000-01-01','9999999999',
 'delete.demo@hospital.com','DeleteDemo','O+');

DELETE FROM patients
WHERE patient_id IN (
    SELECT patient_id
    FROM (
        SELECT patient_id
        FROM patients
        WHERE city = 'DeleteDemo'
    ) AS temp
);

-- ==============================================================================================================================

-- =====================================================================
-- SECTION 5: SELECT & OPERATORS
-- =====================================================================

-- Display all patients.
SELECT * FROM patients;

-- Patient names and cities.
SELECT patient_name, city
FROM patients;

-- Doctors salary > 60000.
SELECT *
FROM doctors
WHERE salary > 60000;

-- Payments between 5000 and 20000.
SELECT *
FROM payments
WHERE amount BETWEEN 5000 AND 20000;

-- Doctors in selected departments using IN.
SELECT *
FROM doctors
WHERE department_id IN (1,2,3);

-- Patient names starting with A.
SELECT *
FROM patients
WHERE patient_name LIKE 'A%';

-- Patient names containing a.
SELECT *
FROM patients
WHERE patient_name LIKE '%a%';

-- Patients whose city is not Hyderabad.
SELECT *
FROM patients
WHERE city <> 'Hyderabad';

-- Medicines stock between 10 and 50.
SELECT *
FROM medicines
WHERE stock BETWEEN 10 AND 50;

-- Nullable field IS NULL.
SELECT *
FROM appointments
WHERE notes IS NULL;

-- Same field IS NOT NULL.
SELECT *
FROM appointments
WHERE notes IS NOT NULL;

-- Revised consultation fee using arithmetic operators.
SELECT
    doctor_name,
    consultation_fee,
    consultation_fee * 1.10 AS revised_consultation_fee
FROM doctors;

-- AND.
SELECT *
FROM doctors
WHERE salary > 70000
  AND city = 'Hyderabad';

-- OR.
SELECT *
FROM patients
WHERE city = 'Hyderabad'
   OR city = 'Warangal';

-- NOT.
SELECT *
FROM doctors
WHERE NOT department_id = 1;

-- ================================================================================================================================

-- =====================================================================
-- SECTION 6: DISTINCT, ORDER BY & LIMIT
-- =====================================================================

SELECT DISTINCT city
FROM patients;

SELECT DISTINCT specialization
FROM doctors;

SELECT *
FROM doctors
ORDER BY salary ASC;

SELECT *
FROM doctors
ORDER BY salary DESC;

SELECT *
FROM patients
ORDER BY patient_name ASC;

SELECT *
FROM doctors
ORDER BY salary DESC
LIMIT 5;

SELECT *
FROM medicines
ORDER BY price ASC
LIMIT 3;

-- Second page: 10 rows per page.
SELECT *
FROM appointments
ORDER BY appointment_id
LIMIT 10 OFFSET 10;

-- ================================================================================================================================

-- =====================================================================
-- SECTION 7: AGGREGATE FUNCTIONS
-- =====================================================================

SELECT COUNT(*) AS total_patients
FROM patients;

SELECT COUNT(*) AS total_doctors
FROM doctors;

SELECT MAX(salary) AS highest_doctor_salary
FROM doctors;

SELECT MIN(salary) AS lowest_doctor_salary
FROM doctors;

SELECT ROUND(AVG(salary),2) AS average_doctor_salary
FROM doctors;

SELECT SUM(stock) AS total_medicine_stock
FROM medicines;

SELECT SUM(amount) AS total_payment_amount
FROM payments;

SELECT ROUND(AVG(amount),2) AS average_payment_amount
FROM payments;

SELECT MAX(amount) AS highest_payment
FROM payments;

SELECT MIN(amount) AS lowest_payment
FROM payments;

-- =================================================================================================================================

-- =====================================================================
-- SECTION 8: GROUP BY & HAVING
-- =====================================================================

SELECT city, COUNT(*) AS patient_count
FROM patients
GROUP BY city
ORDER BY patient_count DESC;

SELECT department_id, COUNT(*) AS doctor_count
FROM doctors
GROUP BY department_id;

SELECT department_id, ROUND(AVG(salary),2) AS average_salary
FROM doctors
GROUP BY department_id;

SELECT category, SUM(stock) AS total_stock
FROM medicines
GROUP BY category;

SELECT patient_id, SUM(amount) AS total_spending
FROM payments
GROUP BY patient_id;

SELECT doctor_id, COUNT(*) AS total_appointments
FROM appointments
GROUP BY doctor_id;

SELECT department_id, COUNT(*) AS doctor_count
FROM doctors
GROUP BY department_id
HAVING COUNT(*) > 3;

SELECT patient_id, SUM(amount) AS total_spending
FROM payments
GROUP BY patient_id
HAVING SUM(amount) > 50000;

SELECT department_id, ROUND(AVG(salary),2) AS average_salary
FROM doctors
GROUP BY department_id
HAVING AVG(salary) > 70000;

-- ================================================================================================================================

-- =====================================================================
-- SECTION 9: JOINS
-- =====================================================================

-- INNER JOIN: doctors with departments.
SELECT
    d.doctor_id,
    d.doctor_name,
    d.specialization,
    dep.department_name
FROM doctors d
INNER JOIN departments dep
    ON d.department_id = dep.department_id;

-- INNER JOIN: appointments with patient and doctor names.
SELECT
    a.appointment_id,
    p.patient_name,
    d.doctor_name,
    a.appointment_date,
    a.status
FROM appointments a
INNER JOIN patients p
    ON a.patient_id = p.patient_id
INNER JOIN doctors d
    ON a.doctor_id = d.doctor_id;

-- INNER JOIN: prescriptions with medicine names.
SELECT
    pr.prescription_id,
    p.patient_name,
    d.doctor_name,
    m.medicine_name,
    pr.quantity,
    pr.dosage
FROM prescriptions pr
INNER JOIN patients p
    ON pr.patient_id = p.patient_id
INNER JOIN doctors d
    ON pr.doctor_id = d.doctor_id
INNER JOIN medicines m
    ON pr.medicine_id = m.medicine_id;

-- INNER JOIN: employees with managers.
SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees e
INNER JOIN employees m
    ON e.manager_id = m.employee_id;

-- LEFT JOIN: all patients and appointments.
SELECT
    p.patient_id,
    p.patient_name,
    a.appointment_id,
    a.appointment_date
FROM patients p
LEFT JOIN appointments a
    ON p.patient_id = a.patient_id;

-- LEFT JOIN: patients who never had an appointment.
SELECT
    p.patient_id,
    p.patient_name
FROM patients p
LEFT JOIN appointments a
    ON p.patient_id = a.patient_id
WHERE a.appointment_id IS NULL;

-- LEFT JOIN: all departments including no-doctor departments.
SELECT
    dep.department_id,
    dep.department_name,
    d.doctor_name
FROM departments dep
LEFT JOIN doctors d
    ON dep.department_id = d.department_id;

-- RIGHT JOIN.
SELECT
    dep.department_name,
    d.doctor_name
FROM doctors d
RIGHT JOIN departments dep
    ON d.department_id = dep.department_id;

-- FULL OUTER JOIN equivalent in MySQL.
SELECT
    dep.department_id,
    dep.department_name,
    d.doctor_id,
    d.doctor_name
FROM departments dep
LEFT JOIN doctors d
    ON dep.department_id = d.department_id

UNION

SELECT
    dep.department_id,
    dep.department_name,
    d.doctor_id,
    d.doctor_name
FROM departments dep
RIGHT JOIN doctors d
    ON dep.department_id = d.department_id;

-- SELF JOIN: employees and managers.
SELECT
    e.employee_id,
    e.employee_name,
    m.employee_name AS manager_name
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.employee_id;

-- SELF JOIN: employees reporting to same manager.
SELECT
    e1.employee_name AS employee_1,
    e2.employee_name AS employee_2,
    e1.manager_id
FROM employees e1
JOIN employees e2
    ON e1.manager_id = e2.manager_id
   AND e1.employee_id < e2.employee_id
WHERE e1.manager_id IS NOT NULL;

-- CROSS JOIN: every department and room type.
SELECT
    d.department_name,
    rt.room_type
FROM departments d
CROSS JOIN (
    SELECT DISTINCT room_type
    FROM rooms
) rt;

-- ================================================================================================================================

-- =====================================================================
-- SECTION 10: MULTI-TABLE JOINS
-- =====================================================================

-- Patient -> Appointment -> Doctor.
SELECT
    p.patient_name,
    a.appointment_date,
    a.status,
    d.doctor_name,
    d.specialization
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id;

-- Patient -> Admission -> Room.
SELECT
    p.patient_name,
    ad.admission_date,
    ad.discharge_date,
    r.room_number,
    r.room_type
FROM patients p
JOIN admissions ad
    ON p.patient_id = ad.patient_id
JOIN rooms r
    ON ad.room_id = r.room_id;

-- Patient -> Payment.
SELECT
    p.patient_name,
    pay.payment_id,
    pay.amount,
    pay.payment_date,
    pay.payment_status
FROM patients p
JOIN payments pay
    ON p.patient_id = pay.patient_id;

-- Medicine -> Prescription -> Doctor.
SELECT
    m.medicine_name,
    pr.quantity,
    pr.dosage,
    d.doctor_name
FROM medicines m
JOIN prescriptions pr
    ON m.medicine_id = pr.medicine_id
JOIN doctors d
    ON pr.doctor_id = d.doctor_id;

-- Complete hospital billing query using 4+ tables.
SELECT
    pay.payment_id,
    p.patient_name,
    ad.admission_id,
    r.room_number,
    r.room_type,
    r.daily_charge,
    pay.amount,
    pay.payment_status
FROM payments pay
JOIN patients p
    ON pay.patient_id = p.patient_id
LEFT JOIN admissions ad
    ON pay.admission_id = ad.admission_id
LEFT JOIN rooms r
    ON ad.room_id = r.room_id
ORDER BY pay.payment_id;

-- Hospital report using 6 tables.
SELECT
    p.patient_name,
    a.appointment_date,
    d.doctor_name,
    dep.department_name,
    m.medicine_name,
    pr.dosage
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
JOIN departments dep
    ON d.department_id = dep.department_id
LEFT JOIN prescriptions pr
    ON a.appointment_id = pr.appointment_id
LEFT JOIN medicines m
    ON pr.medicine_id = m.medicine_id;

-- ==================================================================================================================================

-- =====================================================================
-- SECTION 11: SUBQUERIES
-- =====================================================================

-- Doctors earning more than average doctor salary.
SELECT *
FROM doctors
WHERE salary > (
    SELECT AVG(salary)
    FROM doctors
);

-- Most expensive medicine.
SELECT *
FROM medicines
WHERE price = (
    SELECT MAX(price)
    FROM medicines
);

-- Second-highest doctor salary.
SELECT MAX(salary) AS second_highest_salary
FROM doctors
WHERE salary < (
    SELECT MAX(salary)
    FROM doctors
);

-- Patients who placed at least one appointment.
SELECT *
FROM patients
WHERE patient_id IN (
    SELECT DISTINCT patient_id
    FROM appointments
);

-- Patients who never had an appointment.
SELECT *
FROM patients
WHERE patient_id NOT IN (
    SELECT DISTINCT patient_id
    FROM appointments
);

-- Medicines that have been prescribed.
SELECT *
FROM medicines
WHERE medicine_id IN (
    SELECT DISTINCT medicine_id
    FROM prescriptions
);

-- Medicines that have never been prescribed.
SELECT *
FROM medicines
WHERE medicine_id NOT IN (
    SELECT DISTINCT medicine_id
    FROM prescriptions
);

-- Patients whose total spending is above average patient spending.
SELECT
    p.patient_id,
    p.patient_name,
    (
        SELECT SUM(pay.amount)
        FROM payments pay
        WHERE pay.patient_id = p.patient_id
          AND pay.payment_status = 'Paid'
    ) AS total_spending
FROM patients p
WHERE (
    SELECT COALESCE(SUM(pay.amount),0)
    FROM payments pay
    WHERE pay.patient_id = p.patient_id
      AND pay.payment_status = 'Paid'
) > (
    SELECT AVG(patient_total)
    FROM (
        SELECT
            patient_id,
            SUM(amount) AS patient_total
        FROM payments
        WHERE payment_status = 'Paid'
        GROUP BY patient_id
    ) spending
);

-- Employees earning more than average employee salary.
SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);

-- ==================================================================================================================================

-- =====================================================================
-- SECTION 12: ANY, ALL & EXISTS
-- =====================================================================

-- More than ALL doctors in Pediatrics (department_id = 4).
SELECT *
FROM doctors
WHERE salary > ALL (
    SELECT salary
    FROM doctors
    WHERE department_id = 4
);

-- More than ANY doctor in Pediatrics.
SELECT *
FROM doctors
WHERE salary > ANY (
    SELECT salary
    FROM doctors
    WHERE department_id = 4
);

-- EXISTS: patients with appointments.
SELECT
    p.patient_id,
    p.patient_name
FROM patients p
WHERE EXISTS (
    SELECT 1
    FROM appointments a
    WHERE a.patient_id = p.patient_id
);

-- NOT EXISTS: patients without appointments.
SELECT
    p.patient_id,
    p.patient_name
FROM patients p
WHERE NOT EXISTS (
    SELECT 1
    FROM appointments a
    WHERE a.patient_id = p.patient_id
);

-- Same business requirement using IN.
SELECT patient_id, patient_name
FROM patients
WHERE patient_id IN (
    SELECT patient_id
    FROM appointments
);

-- Same business requirement using EXISTS.
SELECT p.patient_id, p.patient_name
FROM patients p
WHERE EXISTS (
    SELECT 1
    FROM appointments a
    WHERE a.patient_id = p.patient_id
);

-- Comparison note:
-- IN compares a value against a returned set.
-- EXISTS checks whether at least one matching row exists and is often
-- convenient for correlated existence checks.

-- ==================================================================================================================================

-- =====================================================================
-- SECTION 13: CORRELATED SUBQUERIES
-- =====================================================================

-- Doctors above their department average salary.
SELECT
    d.doctor_id,
    d.doctor_name,
    d.department_id,
    d.salary
FROM doctors d
WHERE d.salary > (
    SELECT AVG(d2.salary)
    FROM doctors d2
    WHERE d2.department_id = d.department_id
);

-- Medicines above category average price.
SELECT
    m.medicine_id,
    m.medicine_name,
    m.category,
    m.price
FROM medicines m
WHERE m.price > (
    SELECT AVG(m2.price)
    FROM medicines m2
    WHERE m2.category = m.category
);

-- Patients whose spending is greater than the average spending
-- of paying patients in the same city.
SELECT
    p.patient_id,
    p.patient_name,
    p.city,
    (
        SELECT COALESCE(SUM(pay.amount),0)
        FROM payments pay
        WHERE pay.patient_id = p.patient_id
          AND pay.payment_status = 'Paid'
    ) AS patient_spending
FROM patients p
WHERE (
    SELECT COALESCE(SUM(pay.amount),0)
    FROM payments pay
    WHERE pay.patient_id = p.patient_id
      AND pay.payment_status = 'Paid'
) > (
    SELECT AVG(city_spend.patient_total)
    FROM (
        SELECT
            p2.patient_id,
            p2.city,
            SUM(pay2.amount) AS patient_total
        FROM patients p2
        JOIN payments pay2
            ON p2.patient_id = pay2.patient_id
        WHERE pay2.payment_status = 'Paid'
        GROUP BY p2.patient_id, p2.city
    ) city_spend
    WHERE city_spend.city = p.city
);

-- Highest-paid doctor from every department using correlated subquery.
SELECT
    d.doctor_id,
    d.doctor_name,
    d.department_id,
    d.salary
FROM doctors d
WHERE d.salary = (
    SELECT MAX(d2.salary)
    FROM doctors d2
    WHERE d2.department_id = d.department_id
);

-- ===============================================================================================================================

-- =====================================================================
-- SECTION 14: CASE EXPRESSIONS
-- =====================================================================

-- Doctor salary classification.
SELECT
    doctor_name,
    salary,
    CASE
        WHEN salary < 70000 THEN 'Low'
        WHEN salary <= 85000 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM doctors;

-- Patient spending classification.
SELECT
    p.patient_id,
    p.patient_name,
    COALESCE(SUM(pay.amount),0) AS total_spending,
    CASE
        WHEN COALESCE(SUM(pay.amount),0) < 10000 THEN 'Low Spender'
        WHEN COALESCE(SUM(pay.amount),0) <= 50000 THEN 'Medium Spender'
        ELSE 'High Spender'
    END AS spending_category
FROM patients p
LEFT JOIN payments pay
    ON p.patient_id = pay.patient_id
   AND pay.payment_status = 'Paid'
GROUP BY p.patient_id, p.patient_name;

-- Room classification.
SELECT
    room_number,
    daily_charge,
    CASE
        WHEN daily_charge < 2500 THEN 'Economy'
        WHEN daily_charge < 6000 THEN 'Premium'
        ELSE 'Critical Care'
    END AS room_category
FROM rooms;

-- Appointment classification.
SELECT
    appointment_id,
    appointment_date,
    status,
    CASE
        WHEN status = 'Cancelled' THEN 'Cancelled'
        WHEN status = 'Completed' THEN 'Completed'
        WHEN appointment_date >= NOW() THEN 'Upcoming'
        ELSE 'Scheduled'
    END AS appointment_category
FROM appointments;

-- Meaningful text instead of payment status codes.
SELECT
    payment_id,
    payment_status,
    CASE payment_status
        WHEN 'Paid' THEN 'Payment received successfully'
        WHEN 'Pending' THEN 'Payment awaiting confirmation'
        WHEN 'Failed' THEN 'Payment failed'
        ELSE 'Unknown payment state'
    END AS payment_message
FROM payments;

-- ==================================================================================================================================

-- =====================================================================
-- SECTION 15: MYSQL FUNCTIONS
-- =====================================================================

-- UPPER and LOWER.
SELECT
    patient_name,
    UPPER(patient_name) AS patient_upper,
    LOWER(patient_name) AS patient_lower
FROM patients;

SELECT
    doctor_name,
    UPPER(doctor_name) AS doctor_upper,
    LOWER(doctor_name) AS doctor_lower
FROM doctors;

-- CONCAT.
SELECT
    CONCAT(patient_name, ' - ', city) AS patient_display_name
FROM patients;

-- SUBSTRING.
SELECT
    patient_name,
    SUBSTRING(patient_name,1,5) AS first_five_characters
FROM patients;

-- LENGTH.
SELECT
    patient_name,
    LENGTH(patient_name) AS name_length
FROM patients
WHERE LENGTH(patient_name) > 10;

-- REPLACE.
SELECT
    patient_name,
    REPLACE(patient_name,'Reddy','R.') AS modified_name
FROM patients;

-- TRIM.
SELECT
    TRIM('   Hospital Management   ') AS trimmed_text;

-- ROUND.
SELECT
    payment_id,
    amount,
    ROUND(amount,0) AS rounded_amount
FROM payments;

-- CEIL, FLOOR, ABS.
SELECT
    payment_id,
    amount,
    CEIL(amount / 3) AS ceil_value,
    FLOOR(amount / 3) AS floor_value,
    ABS(amount - 10000) AS absolute_difference
FROM payments;

-- CURDATE and NOW.
SELECT
    CURDATE() AS current_date_value,
    NOW() AS current_datetime_value;

-- YEAR, MONTH, DAY.
SELECT
    appointment_id,
    appointment_date,
    YEAR(appointment_date) AS appointment_year,
    MONTH(appointment_date) AS appointment_month,
    DAY(appointment_date) AS appointment_day
FROM appointments;

-- DATEDIFF.
SELECT
    admission_id,
    admission_date,
    discharge_date,
    DATEDIFF(discharge_date, admission_date) AS admission_duration_days
FROM admissions
WHERE discharge_date IS NOT NULL;

-- DATE_ADD.
SELECT
    appointment_id,
    appointment_date,
    DATE_ADD(appointment_date, INTERVAL 15 DAY) AS follow_up_date
FROM appointments;

-- DATE_SUB.
SELECT *
FROM payments
WHERE payment_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- IFNULL.
SELECT
    appointment_id,
    IFNULL(notes,'No notes available') AS appointment_notes
FROM appointments;

-- COALESCE.
SELECT
    patient_name,
    COALESCE(emergency_contact, phone, email, 'No contact available')
        AS best_contact
FROM patients;

-- NULLIF.
SELECT
    payment_id,
    NULLIF(payment_status,'Paid') AS non_paid_status_only
FROM payments;

-- Appointments in current year.
SELECT *
FROM appointments
WHERE YEAR(appointment_date) = YEAR(CURDATE());

-- Patients registered in last 30 days.
SELECT *
FROM patients
WHERE registration_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- ===================================================================================================================================

-- =====================================================================
-- SECTION 16: UNION & SET OPERATIONS
-- =====================================================================

-- UNION removes duplicates.
SELECT city
FROM patients
UNION
SELECT city
FROM doctors;

-- UNION ALL keeps duplicates.
SELECT city
FROM patients
UNION ALL
SELECT city
FROM doctors;

-- Explicit UNION vs UNION ALL demonstration.
SELECT 'UNION' AS operation_type, city
FROM (
    SELECT city FROM patients
    UNION
    SELECT city FROM doctors
) u

UNION ALL

SELECT 'UNION ALL' AS operation_type, city
FROM (
    SELECT city FROM patients
    UNION ALL
    SELECT city FROM doctors
) ua;

-- Business report combining compatible sets.
SELECT
    'Patient' AS entity_type,
    patient_name AS entity_name,
    city
FROM patients

UNION ALL

SELECT
    'Doctor' AS entity_type,
    doctor_name AS entity_name,
    city
FROM doctors;

-- ==================================================================================================================================

-- =====================================================================
-- SECTION 17: CTE
-- =====================================================================

-- Simple CTE.
WITH high_salary_doctors AS (
    SELECT doctor_id, doctor_name, salary
    FROM doctors
    WHERE salary > 80000
)
SELECT *
FROM high_salary_doctors;

-- CTE: total spending for each patient.
WITH patient_spending AS (
    SELECT
        patient_id,
        SUM(amount) AS total_spending
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY patient_id
)
SELECT
    p.patient_name,
    ps.total_spending
FROM patient_spending ps
JOIN patients p
    ON ps.patient_id = p.patient_id
ORDER BY ps.total_spending DESC;

-- CTE: patients above average spending.
WITH patient_spending AS (
    SELECT
        patient_id,
        SUM(amount) AS total_spending
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY patient_id
)
SELECT *
FROM patient_spending
WHERE total_spending > (
    SELECT AVG(total_spending)
    FROM patient_spending
);

-- Multiple CTEs.
WITH
patient_spending AS (
    SELECT patient_id, SUM(amount) AS total_spending
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY patient_id
),
city_summary AS (
    SELECT
        p.city,
        AVG(ps.total_spending) AS average_city_spending
    FROM patient_spending ps
    JOIN patients p
        ON ps.patient_id = p.patient_id
    GROUP BY p.city
)
SELECT *
FROM city_summary
ORDER BY average_city_spending DESC;

-- CTE combined with JOIN.
WITH appointment_counts AS (
    SELECT doctor_id, COUNT(*) AS total_appointments
    FROM appointments
    GROUP BY doctor_id
)
SELECT
    d.doctor_name,
    dep.department_name,
    COALESCE(ac.total_appointments,0) AS total_appointments
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
LEFT JOIN appointment_counts ac
    ON d.doctor_id = ac.doctor_id;

-- CTE combined with GROUP BY and aggregation.
WITH department_salary AS (
    SELECT
        department_id,
        AVG(salary) AS average_salary,
        MAX(salary) AS maximum_salary,
        MIN(salary) AS minimum_salary
    FROM doctors
    GROUP BY department_id
)
SELECT
    dep.department_name,
    ds.average_salary,
    ds.maximum_salary,
    ds.minimum_salary
FROM department_salary ds
JOIN departments dep
    ON ds.department_id = dep.department_id;

-- Recursive CTE: employee-manager hierarchy.
WITH RECURSIVE employee_hierarchy AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        1 AS hierarchy_level,
        CAST(employee_name AS CHAR(500)) AS hierarchy_path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        eh.hierarchy_level + 1,
        CONCAT(eh.hierarchy_path, ' -> ', e.employee_name)
    FROM employees e
    JOIN employee_hierarchy eh
        ON e.manager_id = eh.employee_id
)
SELECT *
FROM employee_hierarchy
ORDER BY hierarchy_level, employee_id;

-- ====================================================================================================================

-- =====================================================================
-- SECTION 18: WINDOW FUNCTIONS
-- =====================================================================

-- ROW_NUMBER.
SELECT
    appointment_id,
    patient_id,
    appointment_date,
    ROW_NUMBER() OVER (
        ORDER BY appointment_date, appointment_id
    ) AS row_number_value
FROM appointments;

-- RANK.
SELECT
    doctor_name,
    salary,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM doctors;

-- DENSE_RANK.
SELECT
    doctor_name,
    salary,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS dense_salary_rank
FROM doctors;

-- Top 3 doctors in every department.
WITH ranked_doctors AS (
    SELECT
        doctor_id,
        doctor_name,
        department_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS dept_rank
    FROM doctors
)
SELECT *
FROM ranked_doctors
WHERE dept_rank <= 3
ORDER BY department_id, dept_rank;

-- Running payment total.
SELECT
    payment_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date, payment_id
    ) AS running_payment_total
FROM payments
WHERE payment_status = 'Paid';

-- AVG OVER.
SELECT
    payment_id,
    patient_id,
    amount,
    AVG(amount) OVER (
        PARTITION BY patient_id
    ) AS patient_average_payment
FROM payments;

-- LAG: current payment vs previous payment.
SELECT
    patient_id,
    payment_date,
    amount,
    LAG(amount) OVER (
        PARTITION BY patient_id
        ORDER BY payment_date, payment_id
    ) AS previous_payment
FROM payments;

-- LEAD: current appointment vs next appointment.
SELECT
    patient_id,
    appointment_date,
    LEAD(appointment_date) OVER (
        PARTITION BY patient_id
        ORDER BY appointment_date, appointment_id
    ) AS next_appointment
FROM appointments;

-- Highest-paid doctor in every department using a window function.
WITH doctor_salary_rank AS (
    SELECT
        d.doctor_id,
        d.doctor_name,
        d.department_id,
        d.salary,
        ROW_NUMBER() OVER (
            PARTITION BY d.department_id
            ORDER BY d.salary DESC, d.doctor_id
        ) AS rn
    FROM doctors d
)
SELECT *
FROM doctor_salary_rank
WHERE rn = 1;

-- NTILE: divide patients into spending groups.
WITH patient_spending AS (
    SELECT
        p.patient_id,
        p.patient_name,
        COALESCE(SUM(pay.amount),0) AS total_spending
    FROM patients p
    LEFT JOIN payments pay
        ON p.patient_id = pay.patient_id
       AND pay.payment_status = 'Paid'
    GROUP BY p.patient_id, p.patient_name
)
SELECT
    patient_id,
    patient_name,
    total_spending,
    NTILE(4) OVER (
        ORDER BY total_spending DESC
    ) AS spending_quartile
FROM patient_spending;

-- ===================================================================================================================

-- =====================================================================
-- SECTION 19: VIEWS
-- =====================================================================

-- Patient appointments view.
CREATE OR REPLACE VIEW patient_appointments_view AS
SELECT
    a.appointment_id,
    p.patient_id,
    p.patient_name,
    d.doctor_id,
    d.doctor_name,
    dep.department_name,
    a.appointment_date,
    a.status
FROM appointments a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
JOIN departments dep
    ON d.department_id = dep.department_id;


-- Doctor performance view.
CREATE OR REPLACE VIEW doctor_performance_view AS
SELECT
    d.doctor_id,
    d.doctor_name,
    dep.department_name,
    d.salary,
    d.consultation_fee,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END)
        AS completed_appointments
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name,
    dep.department_name,
    d.salary,
    d.consultation_fee;


-- Patient payments view.
CREATE OR REPLACE VIEW patient_payments_view AS
SELECT
    pay.payment_id,
    p.patient_id,
    p.patient_name,
    pay.amount,
    pay.payment_date,
    pay.payment_method,
    pay.payment_status
FROM payments pay
JOIN patients p
    ON pay.patient_id = p.patient_id;


-- Employee-manager view.
CREATE OR REPLACE VIEW employee_manager_view AS
SELECT
    e.employee_id,
    e.employee_name,
    e.job_title,
    e.salary,
    m.employee_name AS manager_name
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.employee_id;


-- SELECT using a view.
SELECT *
FROM patient_appointments_view;


-- ALTER / recreate a view.
ALTER VIEW patient_payments_view AS
SELECT
    pay.payment_id,
    p.patient_id,
    p.patient_name,
    p.city,
    pay.amount,
    pay.payment_date,
    pay.payment_method,
    pay.payment_status
FROM payments pay
JOIN patients p
    ON pay.patient_id = p.patient_id;


-- DROP VIEW demo without removing required views.
CREATE OR REPLACE VIEW demo_view_to_drop AS
SELECT patient_id, patient_name
FROM patients;

DROP VIEW demo_view_to_drop;

-- =====================================================================================================================

-- =====================================================================
-- SECTION 20: STORED PROCEDURES
-- =====================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS get_all_patients$$
CREATE PROCEDURE get_all_patients()
BEGIN
    SELECT *
    FROM patients
    ORDER BY patient_id;
END$$


DROP PROCEDURE IF EXISTS get_patient_appointments$$
CREATE PROCEDURE get_patient_appointments(IN p_patient_id INT)
BEGIN
    SELECT
        a.appointment_id,
        p.patient_name,
        d.doctor_name,
        a.appointment_date,
        a.status
    FROM appointments a
    JOIN patients p
        ON a.patient_id = p.patient_id
    JOIN doctors d
        ON a.doctor_id = d.doctor_id
    WHERE a.patient_id = p_patient_id
    ORDER BY a.appointment_date;
END$$


DROP PROCEDURE IF EXISTS get_doctors_by_department$$
CREATE PROCEDURE get_doctors_by_department(IN p_department_id INT)
BEGIN
    SELECT
        doctor_id,
        doctor_name,
        specialization,
        salary,
        consultation_fee
    FROM doctors
    WHERE department_id = p_department_id
    ORDER BY salary DESC;
END$$


-- IN parameter procedure.
DROP PROCEDURE IF EXISTS get_patient_by_id$$
CREATE PROCEDURE get_patient_by_id(IN p_patient_id INT)
BEGIN
    SELECT *
    FROM patients
    WHERE patient_id = p_patient_id;
END$$


-- OUT parameter procedure.
DROP PROCEDURE IF EXISTS get_patient_count$$
CREATE PROCEDURE get_patient_count(OUT p_total INT)
BEGIN
    SELECT COUNT(*)
    INTO p_total
    FROM patients;
END$$


-- INOUT parameter procedure.
DROP PROCEDURE IF EXISTS apply_inout_discount$$
CREATE PROCEDURE apply_inout_discount(INOUT p_amount DECIMAL(10,2))
BEGIN
    SET p_amount = p_amount * 0.90;
END$$


-- IF / ELSEIF / ELSE procedure.
DROP PROCEDURE IF EXISTS classify_bill$$
CREATE PROCEDURE classify_bill(
    IN p_amount DECIMAL(10,2),
    OUT p_category VARCHAR(30)
)
BEGIN
    IF p_amount < 10000 THEN
        SET p_category = 'Low Bill';
    ELSEIF p_amount <= 50000 THEN
        SET p_category = 'Medium Bill';
    ELSE
        SET p_category = 'High Bill';
    END IF;
END$$


-- LOOP procedure that processes patient rows.
DROP PROCEDURE IF EXISTS process_patients_loop$$
CREATE PROCEDURE process_patients_loop(IN p_limit INT)
BEGIN
    DECLARE v_counter INT DEFAULT 1;
    DECLARE v_max_id INT DEFAULT 0;

    DROP TEMPORARY TABLE IF EXISTS loop_patient_results;

    CREATE TEMPORARY TABLE loop_patient_results (
        patient_id INT,
        patient_name VARCHAR(100)
    );

    SELECT COALESCE(MAX(patient_id),0)
    INTO v_max_id
    FROM patients;

    patient_loop: LOOP
        IF v_counter > v_max_id OR
           (SELECT COUNT(*) FROM loop_patient_results) >= p_limit THEN
            LEAVE patient_loop;
        END IF;

        INSERT INTO loop_patient_results(patient_id, patient_name)
        SELECT patient_id, patient_name
        FROM patients
        WHERE patient_id = v_counter;

        SET v_counter = v_counter + 1;
    END LOOP;

    SELECT *
    FROM loop_patient_results;
END$$


-- Appointment operation procedure.
DROP PROCEDURE IF EXISTS create_appointment$$
CREATE PROCEDURE create_appointment(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_appointment_date DATETIME,
    IN p_notes VARCHAR(255)
)
BEGIN
    INSERT INTO appointments
    (patient_id, doctor_id, appointment_date, status, notes)
    VALUES
    (p_patient_id, p_doctor_id, p_appointment_date, 'Scheduled', p_notes);
END$$

DELIMITER ;


-- Procedure calls / demonstrations.
CALL get_all_patients();
CALL get_patient_appointments(1);
CALL get_doctors_by_department(1);
CALL get_patient_by_id(1);

CALL get_patient_count(@patient_count);
SELECT @patient_count AS patient_count_from_out_parameter;

SET @bill_amount = 10000.00;
CALL apply_inout_discount(@bill_amount);
SELECT @bill_amount AS amount_after_inout_discount;

CALL classify_bill(45000,@bill_category);
SELECT @bill_category AS bill_category_from_out_parameter;

CALL process_patients_loop(5);

-- Demonstrate appointment operation without affecting the "patient without
-- appointments" example: add another appointment for patient 1.
CALL create_appointment(
    1,
    1,
    '2026-10-01 10:00:00',
    'Procedure-created follow-up'
);

-- ====================================================================================================================

-- =====================================================================
-- SECTION 21: USER-DEFINED FUNCTIONS
-- =====================================================================

DELIMITER $$

-- Consultation discount function.
DROP FUNCTION IF EXISTS consultation_discount$$
CREATE FUNCTION consultation_discount(
    p_fee DECIMAL(10,2),
    p_discount_percent DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN ROUND(
        p_fee - (p_fee * p_discount_percent / 100),
        2
    );
END$$


-- GST/tax function.
DROP FUNCTION IF EXISTS calculate_gst$$
CREATE FUNCTION calculate_gst(
    p_bill_amount DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN ROUND(p_bill_amount * 0.18,2);
END$$


-- Final payment amount function.
DROP FUNCTION IF EXISTS final_payment_amount$$
CREATE FUNCTION final_payment_amount(
    p_bill_amount DECIMAL(10,2),
    p_discount_percent DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_after_discount DECIMAL(10,2);

    SET v_after_discount =
        p_bill_amount - (p_bill_amount * p_discount_percent / 100);

    RETURN ROUND(
        v_after_discount + (v_after_discount * 0.18),
        2
    );
END$$


-- Patient spending classification function.
DROP FUNCTION IF EXISTS classify_patient_spending$$
CREATE FUNCTION classify_patient_spending(
    p_total DECIMAL(12,2)
)
RETURNS VARCHAR(30)
DETERMINISTIC
NO SQL
BEGIN
    RETURN CASE
        WHEN p_total < 10000 THEN 'Low Spender'
        WHEN p_total <= 50000 THEN 'Medium Spender'
        ELSE 'High Spender'
    END;
END$$

DELIMITER ;


-- Use user-defined functions inside SELECT.
SELECT
    doctor_name,
    consultation_fee,
    consultation_discount(consultation_fee,10)
        AS discounted_consultation_fee
FROM doctors;

SELECT
    payment_id,
    amount,
    calculate_gst(amount) AS gst_amount,
    final_payment_amount(amount,5) AS final_amount_after_discount_and_gst
FROM payments;

SELECT
    p.patient_name,
    COALESCE(SUM(pay.amount),0) AS total_spending,
    classify_patient_spending(COALESCE(SUM(pay.amount),0))
        AS spending_class
FROM patients p
LEFT JOIN payments pay
    ON p.patient_id = pay.patient_id
   AND pay.payment_status = 'Paid'
GROUP BY p.patient_id, p.patient_name;

-- ======================================================================================================================

-- =====================================================================
-- SECTION 22: TRIGGERS
-- =====================================================================

DELIMITER $$

-- BEFORE INSERT trigger validates payment amount.
DROP TRIGGER IF EXISTS before_payment_insert$$
CREATE TRIGGER before_payment_insert
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment amount must be greater than zero';
    END IF;
END$$


-- AFTER INSERT trigger writes audit record.
DROP TRIGGER IF EXISTS after_payment_insert$$
CREATE TRIGGER after_payment_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
    (
        table_name,
        action_type,
        record_id,
        old_value,
        new_value,
        description
    )
    VALUES
    (
        'payments',
        'INSERT',
        NEW.payment_id,
        NULL,
        CAST(NEW.amount AS CHAR),
        CONCAT(
            'Payment inserted for patient ',
            NEW.patient_id,
            ', amount = ',
            NEW.amount
        )
    );
END$$


-- AFTER UPDATE trigger demonstrates OLD and NEW.
DROP TRIGGER IF EXISTS after_medicine_update$$
CREATE TRIGGER after_medicine_update
AFTER UPDATE ON medicines
FOR EACH ROW
BEGIN
    IF OLD.stock <> NEW.stock OR OLD.price <> NEW.price THEN
        INSERT INTO audit_logs
        (
            table_name,
            action_type,
            record_id,
            old_value,
            new_value,
            description
        )
        VALUES
        (
            'medicines',
            'UPDATE',
            NEW.medicine_id,
            CONCAT('stock=',OLD.stock,', price=',OLD.price),
            CONCAT('stock=',NEW.stock,', price=',NEW.price),
            CONCAT('Medicine updated: ',NEW.medicine_name)
        );
    END IF;
END$$


-- Demo trigger only to demonstrate DROP TRIGGER.
DROP TRIGGER IF EXISTS demo_room_trigger$$
CREATE TRIGGER demo_room_trigger
AFTER UPDATE ON rooms
FOR EACH ROW
BEGIN
    SET @last_updated_room = NEW.room_id;
END$$

DELIMITER ;


-- Trigger definitions.
SHOW TRIGGERS FROM hospital_db;
SHOW CREATE TRIGGER before_payment_insert;
SHOW CREATE TRIGGER after_payment_insert;
SHOW CREATE TRIGGER after_medicine_update;

-- Demonstrate AFTER UPDATE audit trigger.
UPDATE medicines
SET stock = stock + 1
WHERE medicine_id = 1;

SELECT *
FROM audit_logs
ORDER BY log_id DESC;

-- DROP TRIGGER query.
DROP TRIGGER demo_room_trigger;

-- Invalid-value SIGNAL test.
-- Keep this commented when using "Run All" because it is intentionally
-- designed to throw an error.
-- INSERT INTO payments
-- (patient_id, amount, payment_method, payment_status)
-- VALUES (1,-100,'Cash','Paid');

-- ====================================================================================================================

-- =====================================================================
-- SECTION 23: TRANSACTIONS / TCL
-- =====================================================================

-- 23.1 Complete billing transaction with SAVEPOINT.
START TRANSACTION;

INSERT INTO payments
(
    patient_id,
    appointment_id,
    admission_id,
    amount,
    payment_date,
    payment_method,
    payment_status
)
VALUES
(
    2,
    21,
    NULL,
    2500,
    CURDATE(),
    'UPI',
    'Paid'
);

SAVEPOINT payment_created;

UPDATE medicines
SET stock = stock - 1
WHERE medicine_id = 1
  AND stock > 0;

-- Demonstrate ROLLBACK TO SAVEPOINT.
ROLLBACK TO SAVEPOINT payment_created;

-- Payment remains, medicine update is rolled back.
COMMIT;


-- 23.2 ROLLBACK demonstration after a simulated business failure.
START TRANSACTION;

INSERT INTO payments
(
    patient_id,
    amount,
    payment_date,
    payment_method,
    payment_status
)
VALUES
(
    3,
    1000,
    CURDATE(),
    'Cash',
    'Paid'
);

-- Simulated business validation failure detected here.
ROLLBACK;


-- 23.3 Complete admission/payment transaction.
START TRANSACTION;

INSERT INTO admissions
(
    patient_id,
    room_id,
    admission_date,
    discharge_date,
    diagnosis,
    status
)
VALUES
(
    18,
    7,
    CURDATE(),
    NULL,
    'Observation',
    'Admitted'
);

SET @new_admission_id = LAST_INSERT_ID();

UPDATE rooms
SET status = 'Occupied'
WHERE room_id = 7;

INSERT INTO payments
(
    patient_id,
    appointment_id,
    admission_id,
    amount,
    payment_date,
    payment_method,
    payment_status
)
VALUES
(
    18,
    NULL,
    @new_admission_id,
    5000,
    CURDATE(),
    'Card',
    'Paid'
);

COMMIT;

-- ====================================================================================================================

-- =====================================================================
-- SECTION 24: INDEXES & OPTIMIZATION
-- =====================================================================

-- Patient email index.
CREATE INDEX idx_patient_email_lookup
ON patients(email);

-- Doctor name index.
CREATE INDEX idx_doctor_name
ON doctors(doctor_name);

-- Appointment date index.
CREATE INDEX idx_appointment_date
ON appointments(appointment_date);

-- Composite index.
CREATE INDEX idx_patient_appointment_date
ON appointments(patient_id, appointment_date);

-- Additional demo index to safely demonstrate DROP INDEX.
CREATE INDEX idx_demo_medicine_category
ON medicines(category);

-- SHOW INDEXES.
SHOW INDEXES FROM patients;
SHOW INDEXES FROM doctors;
SHOW INDEXES FROM appointments;
SHOW INDEXES FROM medicines;

-- DROP INDEX.
DROP INDEX idx_demo_medicine_category
ON medicines;

-- ====================================================================================================================
-- =====================================================================
-- SECTION 25: NORMALIZATION
-- =====================================================================

-- Denormalized example table containing repeating medicine/payment groups.
DROP TABLE IF EXISTS billing_denormalized;

CREATE TABLE billing_denormalized (
    billing_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    patient_phone VARCHAR(20),
    doctor_name VARCHAR(100),
    department VARCHAR(100),
    medicine1 VARCHAR(100),
    medicine2 VARCHAR(100),
    room VARCHAR(20),
    payment1 DECIMAL(10,2),
    payment2 DECIMAL(10,2)
);

INSERT INTO billing_denormalized VALUES
(
    1,
    'Arjun Reddy',
    '9000000001',
    'Dr. Ramesh',
    'Cardiology',
    'Aspirin',
    'Atorvastatin',
    'I301',
    8000,
    45000
);

-- Repeating groups in denormalized table:
--   medicine1, medicine2
--   payment1, payment2
--
-- 1NF:
--   Remove repeating medicine/payment columns and keep one atomic value
--   per row.

DROP TABLE IF EXISTS billing_1nf;

CREATE TABLE billing_1nf (
    billing_id INT,
    patient_name VARCHAR(100),
    patient_phone VARCHAR(20),
    doctor_name VARCHAR(100),
    department VARCHAR(100),
    medicine_name VARCHAR(100),
    room_number VARCHAR(20),
    payment_amount DECIMAL(10,2),
    PRIMARY KEY (
        billing_id,
        medicine_name,
        payment_amount
    )
);

INSERT INTO billing_1nf VALUES
(1,'Arjun Reddy','9000000001','Dr. Ramesh',
 'Cardiology','Aspirin','I301',8000),
(1,'Arjun Reddy','9000000001','Dr. Ramesh',
 'Cardiology','Atorvastatin','I301',45000);


-- 2NF design:
-- Split attributes that depend only on part of the business key.
DROP TABLE IF EXISTS norm_bill_medicines;
DROP TABLE IF EXISTS norm_bill_payments;
DROP TABLE IF EXISTS norm_bills;

CREATE TABLE norm_bills (
    billing_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    patient_phone VARCHAR(20),
    doctor_name VARCHAR(100),
    department VARCHAR(100),
    room_number VARCHAR(20)
);

CREATE TABLE norm_bill_medicines (
    billing_id INT,
    medicine_name VARCHAR(100),
    PRIMARY KEY (billing_id, medicine_name),
    FOREIGN KEY (billing_id)
        REFERENCES norm_bills(billing_id)
);

CREATE TABLE norm_bill_payments (
    billing_id INT,
    payment_no INT,
    payment_amount DECIMAL(10,2),
    PRIMARY KEY (billing_id, payment_no),
    FOREIGN KEY (billing_id)
        REFERENCES norm_bills(billing_id)
);


-- 3NF design:
-- Remove transitive dependencies by separating patient, doctor,
-- department, room, medicine and payment entities.
-- The project's main tables already represent this 3NF design:
-- patients, doctors, departments, rooms, medicines, prescriptions,
-- appointments/admissions and payments.
--
-- Candidate keys examples:
--   patients: patient_id, email
--   doctors: doctor_id, email
--   rooms: room_id, room_number
--   medicines: medicine_id, medicine_name
--
-- Primary keys:
--   patient_id, doctor_id, department_id, room_id, medicine_id, etc.
--
-- Foreign keys:
--   doctors.department_id -> departments.department_id
--   appointments.patient_id -> patients.patient_id
--   appointments.doctor_id -> doctors.doctor_id
--   admissions.patient_id -> patients.patient_id
--   admissions.room_id -> rooms.room_id
--   prescriptions.medicine_id -> medicines.medicine_id
--   payments.patient_id -> patients.patient_id
--
-- BCNF:
-- The main project design is structured so determinants such as IDs and
-- declared UNIQUE business keys identify rows in their own entities.
-- This avoids the main partial/transitive dependencies from the original
-- denormalized billing table.

-- =====================================================================================================================

-- =====================================================================
-- SECTION 26: DCL
-- =====================================================================

-- IMPORTANT:
-- CREATE USER / GRANT / REVOKE require sufficient MySQL admin privileges.
-- Run this block separately using a root/admin connection.
--
-- CREATE USER IF NOT EXISTS
-- 'hospital_reporter'@'localhost'
-- IDENTIFIED BY 'Hospital@123';
--
-- GRANT SELECT
-- ON hospital_db.*
-- TO 'hospital_reporter'@'localhost';
--
-- GRANT INSERT, UPDATE
-- ON hospital_db.payments
-- TO 'hospital_reporter'@'localhost';
--
-- SHOW GRANTS
-- FOR 'hospital_reporter'@'localhost';
--
-- REVOKE INSERT
-- ON hospital_db.payments
-- FROM 'hospital_reporter'@'localhost';

-- ===================================================================================================================

-- =====================================================================
-- SECTION 27: FINAL SQL CHALLENGE
-- =====================================================================

-- 27.1 Second-highest salary without LIMIT.
SELECT MAX(salary) AS second_highest_salary
FROM doctors
WHERE salary < (
    SELECT MAX(salary)
    FROM doctors
);

-- 27.2 Third-highest salary.
SELECT MAX(salary) AS third_highest_salary
FROM doctors
WHERE salary < (
    SELECT MAX(salary)
    FROM doctors
    WHERE salary < (
        SELECT MAX(salary)
        FROM doctors
    )
);

-- 27.3 Highest-paid doctor from each department.
WITH ranked_doctors AS (
    SELECT
        d.doctor_id,
        d.doctor_name,
        dep.department_name,
        d.salary,
        DENSE_RANK() OVER (
            PARTITION BY d.department_id
            ORDER BY d.salary DESC
        ) AS salary_rank
    FROM doctors d
    JOIN departments dep
        ON d.department_id = dep.department_id
)
SELECT
    doctor_id,
    doctor_name,
    department_name,
    salary
FROM ranked_doctors
WHERE salary_rank = 1;

-- 27.4 Second-highest-paid doctor from each department.
WITH ranked_doctors AS (
    SELECT
        d.doctor_id,
        d.doctor_name,
        dep.department_name,
        d.salary,
        DENSE_RANK() OVER (
            PARTITION BY d.department_id
            ORDER BY d.salary DESC
        ) AS salary_rank
    FROM doctors d
    JOIN departments dep
        ON d.department_id = dep.department_id
)
SELECT
    doctor_id,
    doctor_name,
    department_name,
    salary
FROM ranked_doctors
WHERE salary_rank = 2;

-- 27.5 Patients who never had an appointment.
SELECT
    p.patient_id,
    p.patient_name
FROM patients p
WHERE NOT EXISTS (
    SELECT 1
    FROM appointments a
    WHERE a.patient_id = p.patient_id
);

-- 27.6 Medicines never prescribed.
SELECT
    m.medicine_id,
    m.medicine_name
FROM medicines m
WHERE NOT EXISTS (
    SELECT 1
    FROM prescriptions pr
    WHERE pr.medicine_id = m.medicine_id
);

-- 27.7 Patient with highest total spending.
WITH patient_spending AS (
    SELECT
        p.patient_id,
        p.patient_name,
        SUM(pay.amount) AS total_spending
    FROM patients p
    JOIN payments pay
        ON p.patient_id = pay.patient_id
    WHERE pay.payment_status = 'Paid'
    GROUP BY p.patient_id, p.patient_name
)
SELECT *
FROM patient_spending
WHERE total_spending = (
    SELECT MAX(total_spending)
    FROM patient_spending
);

-- 27.8 Top 3 patients from each city.
WITH patient_spending AS (
    SELECT
        p.patient_id,
        p.patient_name,
        p.city,
        COALESCE(SUM(pay.amount),0) AS total_spending
    FROM patients p
    LEFT JOIN payments pay
        ON p.patient_id = pay.patient_id
       AND pay.payment_status = 'Paid'
    GROUP BY
        p.patient_id,
        p.patient_name,
        p.city
),
ranked_patients AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY total_spending DESC, patient_id
        ) AS city_rank
    FROM patient_spending
)
SELECT *
FROM ranked_patients
WHERE city_rank <= 3
ORDER BY city, city_rank;

-- 27.9 Most prescribed medicine in every category.
WITH medicine_usage AS (
    SELECT
        m.medicine_id,
        m.medicine_name,
        m.category,
        COALESCE(SUM(pr.quantity),0) AS total_quantity
    FROM medicines m
    LEFT JOIN prescriptions pr
        ON m.medicine_id = pr.medicine_id
    GROUP BY
        m.medicine_id,
        m.medicine_name,
        m.category
),
ranked_medicines AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY total_quantity DESC
        ) AS category_rank
    FROM medicine_usage
)
SELECT *
FROM ranked_medicines
WHERE category_rank = 1;

-- 27.10 Departments with average salary above overall average.
SELECT
    dep.department_name,
    AVG(d.salary) AS department_average_salary
FROM departments dep
JOIN doctors d
    ON dep.department_id = d.department_id
GROUP BY dep.department_id, dep.department_name
HAVING AVG(d.salary) > (
    SELECT AVG(salary)
    FROM doctors
);

-- 27.11 Doctors earning more than department average.
SELECT
    d.doctor_id,
    d.doctor_name,
    d.department_id,
    d.salary
FROM doctors d
WHERE d.salary > (
    SELECT AVG(d2.salary)
    FROM doctors d2
    WHERE d2.department_id = d.department_id
);

-- 27.12 Consecutive appointments for the same patient.
WITH appointment_sequence AS (
    SELECT
        patient_id,
        appointment_id,
        appointment_date,
        LAG(appointment_id) OVER (
            PARTITION BY patient_id
            ORDER BY appointment_date, appointment_id
        ) AS previous_appointment_id,
        LAG(appointment_date) OVER (
            PARTITION BY patient_id
            ORDER BY appointment_date, appointment_id
        ) AS previous_appointment_date
    FROM appointments
)
SELECT *
FROM appointment_sequence
WHERE previous_appointment_id IS NOT NULL
ORDER BY patient_id, appointment_date;

-- 27.13 Each patient's first and latest appointment.
SELECT
    p.patient_id,
    p.patient_name,
    MIN(a.appointment_date) AS first_appointment,
    MAX(a.appointment_date) AS latest_appointment
FROM patients p
LEFT JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.patient_name;

-- 27.14 Monthly hospital revenue.
SELECT
    DATE_FORMAT(payment_date,'%Y-%m') AS revenue_month,
    SUM(amount) AS monthly_revenue
FROM payments
WHERE payment_status = 'Paid'
GROUP BY DATE_FORMAT(payment_date,'%Y-%m')
ORDER BY revenue_month;

-- 27.15 Month with highest revenue.
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(payment_date,'%Y-%m') AS revenue_month,
        SUM(amount) AS total_revenue
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY DATE_FORMAT(payment_date,'%Y-%m')
)
SELECT *
FROM monthly_revenue
WHERE total_revenue = (
    SELECT MAX(total_revenue)
    FROM monthly_revenue
);

-- 27.16 Running total of revenue.
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(payment_date,'%Y-%m') AS revenue_month,
        SUM(amount) AS monthly_revenue
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY DATE_FORMAT(payment_date,'%Y-%m')
)
SELECT
    revenue_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY revenue_month
    ) AS running_revenue
FROM monthly_revenue;

-- 27.17 Patients whose spending increased month-over-month.
WITH monthly_patient_spending AS (
    SELECT
        patient_id,
        DATE_FORMAT(payment_date,'%Y-%m') AS spend_month,
        SUM(amount) AS monthly_spending
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY
        patient_id,
        DATE_FORMAT(payment_date,'%Y-%m')
),
spending_with_previous AS (
    SELECT
        patient_id,
        spend_month,
        monthly_spending,
        LAG(monthly_spending) OVER (
            PARTITION BY patient_id
            ORDER BY spend_month
        ) AS previous_month_spending
    FROM monthly_patient_spending
)
SELECT
    p.patient_name,
    s.spend_month,
    s.previous_month_spending,
    s.monthly_spending
FROM spending_with_previous s
JOIN patients p
    ON s.patient_id = p.patient_id
WHERE s.previous_month_spending IS NOT NULL
  AND s.monthly_spending > s.previous_month_spending;

-- 27.18 Duplicate patient records.
-- Insert a semantic duplicate with different email to demonstrate detection.
INSERT INTO patients
(
    patient_name,
    gender,
    date_of_birth,
    phone,
    email,
    city,
    blood_group
)
SELECT
    patient_name,
    gender,
    date_of_birth,
    phone,
    'arjun.duplicate@gmail.com',
    city,
    blood_group
FROM patients
WHERE patient_id = 1;

SELECT
    patient_name,
    phone,
    city,
    COUNT(*) AS duplicate_count
FROM patients
GROUP BY
    patient_name,
    phone,
    city
HAVING COUNT(*) > 1;

-- 27.19 Remove duplicate records while retaining one.
SET SQL_SAFE_UPDATES = 0;

DELETE p1
FROM patients p1
JOIN patients p2
    ON p1.patient_name = p2.patient_name
   AND p1.phone = p2.phone
   AND p1.city = p2.city
   AND p1.patient_id > p2.patient_id;

SET SQL_SAFE_UPDATES = 1;

-- 27.20 Employees earning more than their managers.
SELECT
    e.employee_name AS employee,
    e.salary AS employee_salary,
    m.employee_name AS manager,
    m.salary AS manager_salary
FROM employees e
JOIN employees m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- 27.21 Managers having more than 3 employees.
SELECT
    m.employee_id AS manager_id,
    m.employee_name AS manager_name,
    COUNT(e.employee_id) AS employee_count
FROM employees m
JOIN employees e
    ON e.manager_id = m.employee_id
GROUP BY
    m.employee_id,
    m.employee_name
HAVING COUNT(e.employee_id) > 3;

-- 27.22 Complete hospital management dashboard query.
SELECT
    (SELECT COUNT(*) FROM patients) AS total_patients,
    (SELECT COUNT(*) FROM doctors) AS total_doctors,
    (SELECT COUNT(*) FROM departments) AS total_departments,
    (SELECT COUNT(*) FROM appointments) AS total_appointments,
    (SELECT COUNT(*) FROM admissions) AS total_admissions,
    (
        SELECT COUNT(*)
        FROM rooms
        WHERE status = 'Available'
    ) AS available_rooms,
    (
        SELECT COUNT(*)
        FROM medicines
        WHERE stock < 30
    ) AS low_stock_medicines,
    (
        SELECT COALESCE(SUM(amount),0)
        FROM payments
        WHERE payment_status = 'Paid'
    ) AS total_revenue;

-- =====================================================================================================================

-- =====================================================================
-- SECTION 28: FINAL PROJECT REPORTS
-- =====================================================================

-- 28.1 Patient Report.
SELECT
    p.patient_id,
    p.patient_name,
    p.city,
    p.phone,
    p.email,
    (
        SELECT COUNT(*)
        FROM appointments a
        WHERE a.patient_id = p.patient_id
    ) AS total_appointments,
    (
        SELECT MAX(a.appointment_date)
        FROM appointments a
        WHERE a.patient_id = p.patient_id
    ) AS latest_appointment,
    (
        SELECT COALESCE(SUM(pay.amount),0)
        FROM payments pay
        WHERE pay.patient_id = p.patient_id
          AND pay.payment_status = 'Paid'
    ) AS total_spending
FROM patients p
ORDER BY p.patient_id;


-- 28.2 Doctor Report.
SELECT
    d.doctor_id,
    d.doctor_name,
    d.specialization,
    dep.department_name,
    d.salary,
    d.consultation_fee,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(CASE WHEN a.status='Completed' THEN 1 ELSE 0 END)
        AS completed_appointments
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name,
    d.specialization,
    dep.department_name,
    d.salary,
    d.consultation_fee
ORDER BY d.doctor_id;


-- 28.3 Department Report.
WITH doctor_stats AS (
    SELECT
        department_id,
        COUNT(*) AS doctor_count,
        AVG(salary) AS average_salary
    FROM doctors
    GROUP BY department_id
),
appointment_stats AS (
    SELECT
        d.department_id,
        COUNT(a.appointment_id) AS appointment_count
    FROM doctors d
    LEFT JOIN appointments a
        ON d.doctor_id = a.doctor_id
    GROUP BY d.department_id
)
SELECT
    dep.department_id,
    dep.department_name,
    COALESCE(ds.doctor_count,0) AS doctor_count,
    ROUND(COALESCE(ds.average_salary,0),2) AS average_salary,
    COALESCE(aps.appointment_count,0) AS appointment_count
FROM departments dep
LEFT JOIN doctor_stats ds
    ON dep.department_id = ds.department_id
LEFT JOIN appointment_stats aps
    ON dep.department_id = aps.department_id;


-- 28.4 Room Report.
SELECT
    r.room_id,
    r.room_number,
    r.room_type,
    r.daily_charge,
    r.status,
    COUNT(ad.admission_id) AS total_admissions
FROM rooms r
LEFT JOIN admissions ad
    ON r.room_id = ad.room_id
GROUP BY
    r.room_id,
    r.room_number,
    r.room_type,
    r.daily_charge,
    r.status;


-- 28.5 Medicine Report.
SELECT
    m.medicine_id,
    m.medicine_name,
    m.category,
    m.price,
    m.stock,
    COALESCE(SUM(pr.quantity),0) AS total_prescribed_quantity
FROM medicines m
LEFT JOIN prescriptions pr
    ON m.medicine_id = pr.medicine_id
GROUP BY
    m.medicine_id,
    m.medicine_name,
    m.category,
    m.price,
    m.stock;


-- 28.6 Appointment Report.
SELECT
    a.appointment_id,
    p.patient_name,
    d.doctor_name,
    dep.department_name,
    a.appointment_date,
    a.status,
    IFNULL(a.notes,'No notes') AS notes
FROM appointments a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
JOIN departments dep
    ON d.department_id = dep.department_id
ORDER BY a.appointment_date;


-- 28.7 Admission Report.
SELECT
    ad.admission_id,
    p.patient_name,
    r.room_number,
    r.room_type,
    ad.admission_date,
    ad.discharge_date,
    ad.status,
    ad.diagnosis,
    CASE
        WHEN ad.discharge_date IS NULL
            THEN DATEDIFF(CURDATE(),ad.admission_date)
        ELSE DATEDIFF(ad.discharge_date,ad.admission_date)
    END AS duration_days
FROM admissions ad
JOIN patients p
    ON ad.patient_id = p.patient_id
JOIN rooms r
    ON ad.room_id = r.room_id;


-- 28.8 Payment Report.
SELECT
    pay.payment_id,
    p.patient_name,
    pay.amount,
    pay.payment_date,
    pay.payment_method,
    pay.payment_status
FROM payments pay
JOIN patients p
    ON pay.patient_id = p.patient_id
ORDER BY pay.payment_date, pay.payment_id;


-- 28.9 Patient Spending Report.
SELECT
    p.patient_id,
    p.patient_name,
    p.city,
    COALESCE(SUM(pay.amount),0) AS total_spending,
    classify_patient_spending(
        COALESCE(SUM(pay.amount),0)
    ) AS spending_category
FROM patients p
LEFT JOIN payments pay
    ON p.patient_id = pay.patient_id
   AND pay.payment_status = 'Paid'
GROUP BY
    p.patient_id,
    p.patient_name,
    p.city
ORDER BY total_spending DESC;


-- 28.10 Doctor Salary Report.
SELECT
    dep.department_name,
    d.doctor_id,
    d.doctor_name,
    d.specialization,
    d.salary,
    DENSE_RANK() OVER (
        PARTITION BY d.department_id
        ORDER BY d.salary DESC
    ) AS department_salary_rank
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
ORDER BY dep.department_name, department_salary_rank;


-- 28.11 Department Revenue Report.
-- Revenue here is consultation revenue from completed appointments.
SELECT
    dep.department_id,
    dep.department_name,
    SUM(
        CASE
            WHEN a.status = 'Completed'
                THEN d.consultation_fee
            ELSE 0
        END
    ) AS consultation_revenue
FROM departments dep
JOIN doctors d
    ON dep.department_id = d.department_id
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    dep.department_id,
    dep.department_name
ORDER BY consultation_revenue DESC;


-- 28.12 Monthly Revenue Report.
SELECT
    DATE_FORMAT(payment_date,'%Y-%m') AS revenue_month,
    COUNT(*) AS payment_count,
    SUM(amount) AS monthly_revenue
FROM payments
WHERE payment_status = 'Paid'
GROUP BY DATE_FORMAT(payment_date,'%Y-%m')
ORDER BY revenue_month;


-- 28.13 Top 10 Patients.
SELECT
    p.patient_id,
    p.patient_name,
    SUM(pay.amount) AS total_spending
FROM patients p
JOIN payments pay
    ON p.patient_id = pay.patient_id
WHERE pay.payment_status = 'Paid'
GROUP BY p.patient_id, p.patient_name
ORDER BY total_spending DESC
LIMIT 10;


-- 28.14 Top 10 Doctors.
SELECT
    d.doctor_id,
    d.doctor_name,
    dep.department_name,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name,
    dep.department_name
ORDER BY total_appointments DESC, d.doctor_name
LIMIT 10;


-- 28.15 Employee-Manager Report.
SELECT
    e.employee_id,
    e.employee_name,
    e.job_title,
    e.salary,
    m.employee_name AS manager_name
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.employee_id
ORDER BY e.employee_id;


-- 28.16 Patients Without Appointments.
SELECT
    p.patient_id,
    p.patient_name,
    p.city
FROM patients p
LEFT JOIN appointments a
    ON p.patient_id = a.patient_id
WHERE a.appointment_id IS NULL;


-- 28.17 Medicines Without Prescriptions.
SELECT
    m.medicine_id,
    m.medicine_name,
    m.category
FROM medicines m
LEFT JOIN prescriptions pr
    ON m.medicine_id = pr.medicine_id
WHERE pr.prescription_id IS NULL;


-- 28.18 Highest-Paid Doctor Per Department.
WITH ranked_doctors AS (
    SELECT
        dep.department_name,
        d.doctor_id,
        d.doctor_name,
        d.salary,
        DENSE_RANK() OVER (
            PARTITION BY d.department_id
            ORDER BY d.salary DESC
        ) AS salary_rank
    FROM doctors d
    JOIN departments dep
        ON d.department_id = dep.department_id
)
SELECT
    department_name,
    doctor_id,
    doctor_name,
    salary
FROM ranked_doctors
WHERE salary_rank = 1;


-- 28.19 Patient Ranking Report.
WITH patient_spending AS (
    SELECT
        p.patient_id,
        p.patient_name,
        p.city,
        COALESCE(SUM(pay.amount),0) AS total_spending
    FROM patients p
    LEFT JOIN payments pay
        ON p.patient_id = pay.patient_id
       AND pay.payment_status = 'Paid'
    GROUP BY
        p.patient_id,
        p.patient_name,
        p.city
)
SELECT
    patient_id,
    patient_name,
    city,
    total_spending,
    DENSE_RANK() OVER (
        ORDER BY total_spending DESC
    ) AS overall_spending_rank
FROM patient_spending
ORDER BY overall_spending_rank;


-- 28.20 Monthly Running Revenue Report.
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(payment_date,'%Y-%m') AS revenue_month,
        SUM(amount) AS monthly_revenue
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY DATE_FORMAT(payment_date,'%Y-%m')
)
SELECT
    revenue_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY revenue_month
    ) AS running_revenue
FROM monthly_revenue;

-- ====================================================================================================================

-- =====================================================================
-- SECTION 29: FINAL VERIFICATION
-- =====================================================================

SELECT 'patients' AS table_name, COUNT(*) AS row_count
FROM patients
UNION ALL
SELECT 'departments', COUNT(*)
FROM departments
UNION ALL
SELECT 'doctors', COUNT(*)
FROM doctors
UNION ALL
SELECT 'employees', COUNT(*)
FROM employees
UNION ALL
SELECT 'rooms', COUNT(*)
FROM rooms
UNION ALL
SELECT 'appointments', COUNT(*)
FROM appointments
UNION ALL
SELECT 'admissions', COUNT(*)
FROM admissions
UNION ALL
SELECT 'medicines', COUNT(*)
FROM medicines
UNION ALL
SELECT 'prescriptions', COUNT(*)
FROM prescriptions
UNION ALL
SELECT 'payments', COUNT(*)
FROM payments
UNION ALL
SELECT 'audit_logs', COUNT(*)
FROM audit_logs;


-- =====================================================================
-- OPTIONAL CLEANUP -
-- =====================================================================

-- DROP DATABASE hospital_db;

-- =====================================================================
-- END OF COMPLETE HOSPITAL MANAGEMENT SQL PROJECT
-- =====================================================================














































