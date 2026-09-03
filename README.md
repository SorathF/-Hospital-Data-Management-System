# Hospital-Data-Management-System

## Objective
This project designs a Hospital Data Management System using a relational SQL database, modeling multiple hospitals’ operational data into one cohesive database. It uses SQL queries to analyze patient visits, resource utilization, and care patterns across hospitals. The objective is to derive meaningful insights from raw data that could assist in resource allocation decisions.

## Overview of the Dataset
 
| Table | Description | Key Fields |
|---|---|---|
| `Hospitals` | General information about hospitals in the system | `hospital_id`, `name`, `address`, `phone` |
| `Doctors` | Doctor details and hospital affiliations | `doctor_id`, `name`, `specialty`, `hospital_id`, `email` |
| `Patients` | Patient demographics and contact information | `patient_id`, `name`, `dob`, `address`, `phone` |
| `Appointments` | Appointments between patients and doctors | `appointment_id`, `patient_id`, `doctor_id`, `appointment_date`, `reason` |
| `Departments` | Medical departments within hospitals | `department_id`, `hospital_id`, `name` |
| `Medications` | Available/prescribed medications | `medication_id`, `name`, `description` |
| `Prescriptions` | Links doctors, patients, and medications | `prescription_id`, `patient_id`, `doctor_id`, `medication_id`, `prescribed_date` |
| `Rooms` | Rooms assigned to departments | `room_id`, `room_no`, `department_id`, `capacity` |

## Analysis

- JOINs across multiple tables
- Aggregations and GROUP BY analysis
- CTEs and subqueries for complex queries
- Window functions for ranking and department-level analysis

## Tools Used
MySQL

