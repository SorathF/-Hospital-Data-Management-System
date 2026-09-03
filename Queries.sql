
-- Room numbers and capacities in the Neurology department

SELECT room_no, capacity
FROM rooms
WHERE department_id = 6;

-- All appointments today onwards

SELECT appointment_id, MAX(appointment_date) AS lastest_appointment_date
FROM appointments
GROUP BY appointment_id;

-- Patients with more than 3 appointments

SELECT patient_id, COUNT(*) AS total_appointments
FROM appointments
GROUP BY patient_id
HAVING total_appointments > 3;

-- Appointments with patient and doctor names

SELECT a.appointment_id, p.name AS patient_name, d.name AS doctor_name
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN patients p ON a.patient_id = p.patient_id
ORDER BY appointment_id;

-- Names, phones, and appointment dates for patients appointments in August 2026

SELECT p.name AS patient_name, p.phone AS phone, a.appointment_date
FROM patients p
LEFT JOIN appointments a ON a.patient_id = p.patient_id
WHERE MONTH(appointment_date) = 8 AND YEAR(appointment_date) = 2026;

-- Medications with "pain" or "infection" in the description

SELECT *
FROM medications
WHERE description LIKE "%pain%" OR description LIKE "%infections%";

-- Doctors who have not prescribed any medication yet

SELECT *
FROM doctors
WHERE doctor_id NOT IN (SELECT DISTINCT doctor_id FROM prescriptions);

-- Patients prescribed more than one medication

With med AS (
SELECT patient_id, COUNT(medication_id) AS number_of_medications
										FROM prescriptions
										GROUP BY patient_id
                                        HAVING number_of_medications > 1

)
SELECT p.name AS patient_name, med.number_of_medications
FROM patients p
JOIN med
ON p.patient_id = med.patient_id
ORDER BY patient_name;


-- Number of appointments in each month, per hospital

SELECT  h.hospital_id, h.name AS hospital_name, MONTHNAME(a.appointment_date) AS appointment_month, COUNT(*) AS total_appointments
FROM appointments a
LEFT JOIN doctors d ON d.doctor_id = a.doctor_id
LEFT JOIN hospitals h ON h.hospital_id = d.hospital_id
GROUP BY  h.hospital_id, hospital_name, appointment_month
ORDER BY h.hospital_id;


-- Rank doctors by number of appointments within each hospital

With app AS (
SELECT  d.name AS doctor_name, h.name AS hospital_name, MONTHNAME(a.appointment_date) AS appointment_month, COUNT(*) AS total_appointments
				FROM appointments a
				LEFT JOIN doctors d ON d.doctor_id = a.doctor_id
				LEFT JOIN hospitals h ON h.hospital_id = d.hospital_id
				GROUP BY  doctor_name, hospital_name, appointment_month

),

doc AS (
SELECT doctor_name, hospital_name, total_appointments, 
		RANK() OVER(PARTITION BY hospital_name ORDER BY total_appointments DESC) AS doctor_rank
FROM app
)

SELECT *
FROM doc
ORDER BY doctor_rank;

-- Doctors with zero appointments within each hospital

SELECT  d.doctor_id, d.name AS doctor_name, h.hospital_id, h.name AS hospital_name
FROM doctors d
LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
JOIN hospitals h ON h.hospital_id = d.hospital_id
WHERE a.appointment_id IS NULL;


-- Last 2 appointments for every patient
SELECT *
FROM (SELECT ROW_NUMBER() OVER 
						(PARTITION BY a.patient_id ORDER BY a.appointment_date DESC) AS Row_no,
						p.name AS patient_name, a.appointment_date
		FROM appointments a
        LEFT JOIN patients p ON a.appointment_id = p.patient_id) t
WHERE Row_no <= 2
ORDER BY patient_name, appointment_date DESC;

-- Emergency appointments: patient name, DOB, age group

SELECT p.patient_id, p.name AS patient_name,
	   (CASE 
       WHEN DATEDIFF(NOW(), dob) <= 18 THEN " Pediatric"
       WHEN DATEDIFF(NOW(), dob) BETWEEN 19 AND 64 THEN "Adult"
       WHEN DATEDIFF(NOW(), dob) >= 65 THEN "Geriatric"
       ELSE "NA"
       END) AS age_goup,
	   a.reason
FROM patients p
LEFT JOIN appointments a ON a.patient_id = p.patient_id
WHERE a.reason = "Emergency"
ORDER BY p.patient_id;

--  Cardiology consultations broken down by patient age group

SELECT p.patient_id, p.name AS patient_name, d.name AS department_name, d.specialty AS speciality, COUNT(appointment_id) AS total_appointments,
	   (CASE 
       WHEN DATEDIFF(NOW(), dob) <= 18 THEN " Pediatric"
       WHEN DATEDIFF(NOW(), dob) BETWEEN 19 AND 64 THEN "Adult"
       WHEN DATEDIFF(NOW(), dob) >= 65 THEN "Geriatric"
       ELSE "NA"
       END) AS age_group,
	   a.reason
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN patients p ON a.patient_id = p.patient_id
WHERE a.reason = "Consultation" AND d.specialty = "Cardiology"
GROUP BY p.patient_id, patient_name, department_name, speciality;

--  3rd most frequently prescribed medication(s)

With pres_med AS (
	SELECT m.medication_id, m.name AS medication_name, COUNT(*) AS total_prescriptions,
		DENSE_RANK () OVER (ORDER BY COUNT(*) DESC) AS medication_rank
		FROM prescriptions p
		JOIN medications m ON m.medication_id = p.medication_id
		GROUP BY m.medication_id, medication_name
)
SELECT *
FROM pres_med
WHERE medication_rank = 3;

-- Hospital(s) with the lowest doctor count 

With doc AS (
SELECT h.hospital_id, h.name AS hospital_name, 	COUNT(d.hospital_id) AS Total_doctors
FROM doctors d
RIGHT JOIN hospitals h ON h.hospital_id = d.hospital_id
GROUP BY h.hospital_id, hospital_name
)

SELECT hospital_id, hospital_name, MIN(Total_doctors) AS lowest_count
FROM doc
GROUP BY hospital_id, hospital_name
ORDER BY lowest_count;

-- Hospital(s) whose cardiology department has the most rooms

With card_dept AS (
SELECT h.name AS hospital_name, d.name AS department_name, COUNT(r.room_id) AS total_rooms
	FROM rooms r
	JOIN departments d ON d.department_id = r.department_id
	JOIN hospitals h ON h.hospital_id = d.hospital_id
	GROUP BY hospital_name, department_name
)

SELECT hospital_name, department_name, MAX(total_rooms) AS Highest_rooms
FROM card_dept
WHERE department_name = "Cardiology"
GROUP BY hospital_name, department_name
ORDER BY Highest_rooms DESC;


-- Days between appointment dates of returning patients

With App_date AS (
SELECT patient_id, appointment_date,
			 LAG(appointment_date) OVER (PARTITION BY patient_id ORDER BY appointment_date) AS prev_appointment_date
		FROM appointments        
)

SELECT patient_id,
	   DATEDIFF(appointment_date, prev_appointment_date) AS difference
FROM App_date
WHERE prev_appointment_date IS NOT NULL;


-- Patients who have seen doctors from multiple specialties

SELECT 
    p.patient_id,
    p.name AS patient_name,
    COUNT(DISTINCT d.specialty) AS total_specialty_count
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY p.patient_id, patient_name
HAVING COUNT(DISTINCT d.specialty) > 1
ORDER BY p.patient_id;

-- Department with the 2nd largest total room capacity, per hospital

With Dept AS (
SELECT h.hospital_id, h.name AS hospital_name, d.department_id, d.name AS department_name, SUM(r.capacity) AS total_room_capacity,
		DENSE_RANK () OVER (PARTITION BY h.hospital_id ORDER BY SUM(r.capacity) DESC) AS capacity_rank
		FROM departments d
		JOIN hospitals h ON h.hospital_id = d.hospital_id
        JOIN rooms r ON r.department_id = d.department_id
		GROUP BY h.hospital_id, hospital_name, d.department_id, department_name
)

SELECT *
FROM Dept
WHERE Dept.capacity_rank = 2;