USE master;
GO

IF DB_ID('EnergyManagementDB') IS NOT NULL
BEGIN
    ALTER DATABASE EnergyManagementDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EnergyManagementDB;
END
GO

CREATE DATABASE EnergyManagementDB;
GO

USE EnergyManagementDB;
GO

CREATE TABLE Role (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(150)
);

CREATE TABLE UserAccount (
    user_id INT PRIMARY KEY,
    role_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    account_status VARCHAR(20) NOT NULL CHECK (account_status IN ('Active', 'Inactive')),
    created_date DATE NOT NULL,
    FOREIGN KEY (role_id) REFERENCES Role(role_id)
);

CREATE TABLE Location (
    location_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    address VARCHAR(150) NOT NULL,
    suburb VARCHAR(50) NOT NULL,
    location_type VARCHAR(50) NOT NULL CHECK (location_type IN ('Residential', 'Commercial', 'Industrial')),
    FOREIGN KEY (user_id) REFERENCES UserAccount(user_id)
);

CREATE TABLE SmartMeter (
    meter_id INT PRIMARY KEY,
    location_id INT NOT NULL,
    meter_serial VARCHAR(50) NOT NULL UNIQUE,
    installation_date DATE NOT NULL,
    meter_status VARCHAR(20) NOT NULL CHECK (meter_status IN ('Active', 'Inactive')),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE EnergySource (
    source_id INT PRIMARY KEY,
    location_id INT NOT NULL,
    source_type VARCHAR(50) NOT NULL,
    capacity_kw FLOAT NOT NULL CHECK (capacity_kw > 0),
    source_status VARCHAR(20) NOT NULL CHECK (source_status IN ('Running', 'Stopped', 'Maintenance')),
    installed_date DATE NOT NULL,
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE EnergyReading (
    reading_id INT PRIMARY KEY,
    meter_id INT NOT NULL,
    source_id INT NULL,
    reading_type VARCHAR(30) NOT NULL CHECK (reading_type IN ('Consumption', 'Generation')),
    reading_value_kwh FLOAT NOT NULL CHECK (reading_value_kwh >= 0),
    reading_time DATETIME NOT NULL,
    FOREIGN KEY (meter_id) REFERENCES SmartMeter(meter_id),
    FOREIGN KEY (source_id) REFERENCES EnergySource(source_id)
);

CREATE TABLE Forecast (
    forecast_id INT PRIMARY KEY,
    location_id INT NOT NULL,
    forecast_type VARCHAR(50) NOT NULL,
    forecast_period VARCHAR(50) NOT NULL,
    predicted_kwh FLOAT NOT NULL CHECK (predicted_kwh >= 0),
    confidence_level FLOAT NOT NULL CHECK (confidence_level BETWEEN 0 AND 100),
    created_date DATE NOT NULL,
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE Alert (
    alert_id INT PRIMARY KEY,
    location_id INT NOT NULL,
    reading_id INT NULL,
    alert_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('Low', 'Medium', 'High', 'Critical')),
    alert_status VARCHAR(20) NOT NULL CHECK (alert_status IN ('Open', 'Closed', 'Investigating')),
    created_date DATE NOT NULL,
    resolved_date DATE NULL,
    FOREIGN KEY (location_id) REFERENCES Location(location_id),
    FOREIGN KEY (reading_id) REFERENCES EnergyReading(reading_id)
);

CREATE TABLE SustainabilityReport (
    report_id INT PRIMARY KEY,
    location_id INT NOT NULL,
    report_month VARCHAR(20) NOT NULL,
    total_generation_kwh FLOAT NOT NULL CHECK (total_generation_kwh >= 0),
    total_consumption_kwh FLOAT NOT NULL CHECK (total_consumption_kwh >= 0),
    carbon_offset_kg FLOAT NOT NULL CHECK (carbon_offset_kg >= 0),
    created_date DATE NOT NULL,
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE AlertLog (
    log_id INT PRIMARY KEY,
    alert_id INT NOT NULL,
    user_id INT NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    action_note VARCHAR(150),
    changed_date DATE NOT NULL,
    FOREIGN KEY (alert_id) REFERENCES Alert(alert_id),
    FOREIGN KEY (user_id) REFERENCES UserAccount(user_id)
);

INSERT INTO Role VALUES
(1, 'Admin', 'System administrator with full access'),
(2, 'User', 'Regular consumer account'),
(3, 'Manager', 'Energy management supervisor'),
(4, 'Operator', 'Utility operator'),
(5, 'Planner', 'City sustainability planner');

INSERT INTO UserAccount VALUES
(1, 1, 'Habib Shohag', 'habib@example.com', '0400000001', 'Active', '2026-01-01'),
(2, 2, 'Riaz Raihan', 'riaz@example.com', '0400000002', 'Active', '2026-01-05'),
(3, 3, 'Abul Kalam Azad', 'azad@example.com', '0400000003', 'Active', '2026-01-10'),
(4, 2, 'Fatema Begum', 'fatema@example.com', '0400000004', 'Active', '2026-01-15'),
(5, 2, 'Mehedi Hassan Shohan', 'shohan@example.com', '0400000005', 'Active', '2026-01-20');

INSERT INTO Location VALUES
(1, 1, '12 Green St', 'Perth', 'Residential'),
(2, 2, '45 Solar Ave', 'Joondalup', 'Commercial'),
(3, 3, '78 Eco Rd', 'Fremantle', 'Industrial'),
(4, 4, '90 Wind Dr', 'Subiaco', 'Residential'),
(5, 5, '11 Future Ln', 'Cannington', 'Commercial');

INSERT INTO SmartMeter VALUES
(1, 1, 'SM1001', '2026-01-01', 'Active'),
(2, 2, 'SM1002', '2026-01-02', 'Active'),
(3, 3, 'SM1003', '2026-01-03', 'Inactive'),
(4, 4, 'SM1004', '2026-01-04', 'Active'),
(5, 5, 'SM1005', '2026-01-05', 'Active');

INSERT INTO EnergySource VALUES
(1, 1, 'Solar', 25.5, 'Running', '2026-01-01'),
(2, 2, 'Wind', 40.0, 'Running', '2026-01-02'),
(3, 3, 'Battery', 15.0, 'Stopped', '2026-01-03'),
(4, 4, 'Solar', 30.0, 'Running', '2026-01-04'),
(5, 5, 'Hybrid', 50.0, 'Running', '2026-01-05');

INSERT INTO EnergyReading VALUES
(1, 1, 1, 'Consumption', 120.5, '2026-02-01 10:00:00'),
(2, 2, 2, 'Generation', 250.0, '2026-02-01 11:00:00'),
(3, 3, 3, 'Consumption', 90.0, '2026-02-01 12:00:00'),
(4, 4, 4, 'Generation', 180.0, '2026-02-01 13:00:00'),
(5, 5, 5, 'Consumption', 300.0, '2026-02-01 14:00:00');

INSERT INTO Forecast VALUES
(1, 1, 'Weekly', 'Week 1', 500.0, 95.5, '2026-02-01'),
(2, 2, 'Monthly', 'February', 1500.0, 90.0, '2026-02-01'),
(3, 3, 'Weekly', 'Week 1', 700.0, 85.0, '2026-02-01'),
(4, 4, 'Monthly', 'February', 2000.0, 92.0, '2026-02-01'),
(5, 5, 'Weekly', 'Week 1', 850.0, 88.0, '2026-02-01');

INSERT INTO Alert VALUES
(1, 1, 1, 'High Usage', 'High', 'Open', '2026-02-01', NULL),
(2, 2, 2, 'Low Generation', 'Medium', 'Closed', '2026-02-01', '2026-02-03'),
(3, 3, 3, 'Meter Failure', 'Critical', 'Open', '2026-02-01', NULL),
(4, 4, 4, 'Power Surge', 'High', 'Closed', '2026-02-01', '2026-02-04'),
(5, 5, 5, 'Battery Low', 'Medium', 'Open', '2026-02-01', NULL);

INSERT INTO SustainabilityReport VALUES
(1, 1, 'January', 500.0, 400.0, 50.0, '2026-02-01'),
(2, 2, 'January', 800.0, 650.0, 75.0, '2026-02-01'),
(3, 3, 'January', 300.0, 500.0, 20.0, '2026-02-01'),
(4, 4, 'January', 900.0, 700.0, 90.0, '2026-02-01'),
(5, 5, 'January', 1200.0, 1000.0, 120.0, '2026-02-01');

INSERT INTO AlertLog VALUES
(1, 1, 1, 'Open', 'Investigating', 'Checking issue', '2026-02-02'),
(2, 2, 2, 'Open', 'Closed', 'Issue fixed', '2026-02-03'),
(3, 3, 3, 'Open', 'Investigating', 'Waiting for technician', '2026-02-03'),
(4, 4, 4, 'Open', 'Closed', 'Power stabilized', '2026-02-04'),
(5, 5, 5, 'Open', 'Investigating', 'Battery replacement planned', '2026-02-05');