-- ============================================================
-- Attendance Management System - PostgreSQL Setup Script
-- ============================================================
-- Run this script against your PostgreSQL server:
--   psql -U postgres -f setup.sql
--
-- Or step-by-step:
--   1. Create the database first
--   2. Connect to it (\c attendance_db)
--   3. Run the table creation and seed data below
-- ============================================================

-- Step 1: Create the database (run as superuser, outside any DB)
-- CREATE DATABASE attendance_db;

-- Step 2: Connect to the new database, then run everything below.
-- \c attendance_db;

-- ────────────────────────────────────────────────────────────
-- Table: employees  (validation-only — no auth credentials)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS employees (
    employee_id   VARCHAR(50)  PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department    VARCHAR(100)
);

-- ────────────────────────────────────────────────────────────
-- Table: attendance
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS attendance (
    id              SERIAL       PRIMARY KEY,
    employee_id     VARCHAR(50)  NOT NULL,
    employee_name   VARCHAR(100) NOT NULL,
    attendance_date DATE         NOT NULL,
    sign_in_time    TIMESTAMP,
    sign_out_time   TIMESTAMP,
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_attendance_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    -- Prevent duplicate attendance records for the same employee on the same day
    CONSTRAINT uq_attendance_employee_date
        UNIQUE (employee_id, attendance_date)
);

-- ────────────────────────────────────────────────────────────
-- Table: visitors
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS visitors (
    id           SERIAL       PRIMARY KEY,
    visitor_name VARCHAR(100) NOT NULL,
    company      VARCHAR(100),
    purpose      TEXT,
    visit_date   DATE         NOT NULL,
    visit_time   TIME         NOT NULL,
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ────────────────────────────────────────────────────────────
-- Seed: Sample employee records for testing
-- ────────────────────────────────────────────────────────────
INSERT INTO employees (employee_id, employee_name, department) VALUES
    ('EMP001', 'John Smith',      'Engineering'),
    ('EMP002', 'Jane Doe',        'Marketing'),
    ('EMP003', 'Bob Johnson',     'Finance'),
    ('EMP004', 'Alice Williams',  'Human Resources'),
    ('EMP005', 'Charlie Brown',   'Operations'),
    ('EMP006', 'Diana Prince',    'Engineering'),
    ('EMP007', 'Ethan Hunt',      'Sales'),
    ('EMP008', 'Fiona Green',     'Customer Support'),
    ('EMP009', 'George Miller',   'IT'),
    ('EMP010', 'Helen Troy',      'Administration')
ON CONFLICT (employee_id) DO NOTHING;

-- ────────────────────────────────────────────────────────────
-- Helper function: auto-update updated_at on attendance rows
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_attendance_updated_at ON attendance;
CREATE TRIGGER trg_attendance_updated_at
    BEFORE UPDATE ON attendance
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
