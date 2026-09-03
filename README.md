# Hospital-Data-Management-System

## Objective
This project designs a Hospital Data Management System using a relational SQL database, modeling multiple hospitals’ operational data into one cohesive database. It uses SQL queries to analyze patient visits, resource utilization, and care patterns across hospitals. The objective is to derive meaningful insights from raw data that could assist in resource allocation decisions.

## Overview of the Dataset
The dataset contains operational data from 10 hospitals.

## Database Schema
 
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
Analyzed hospital data using advanced SQL queries(CTEs, subqueries, window functions) to identify trends in appointment patterns, patient demographics, and resource utilization across hospitals.

## Features:
- Total monthly appointments per hospital
- Total number of appointments in the current month
- Most frequent medications prescribed by doctors
- Identify doctors with the highest number of appointments.
- Patients with the highest number of appointments
- Demographics of patients with appointments in the current month
- Age-group classification of patients (Pediatric / Adult / Geriatric) for emergency and specialty visits
- Breakdown of cardiology consultations by age group
- Patients who have seen doctors from multiple specialties
- Hospitals with the lowest doctor count
- Departments with the highest total room capacity per hospital
- Cardiology departments with the maximum number of rooms per hospital

## Tools Used
MySQL

