USE EnergyManagementDB;
GO

-- View 1: Shows energy readings with user and location details.
-- This view can be used for dashboard-style energy usage summaries.

CREATE VIEW vw_EnergyUsageSummary AS
SELECT 
    u.user_id,
    u.full_name,
    l.location_id,
    l.suburb,
    er.reading_type,
    er.reading_value_kwh,
    er.reading_time
FROM UserAccount u
JOIN Location l 
    ON u.user_id = l.user_id
JOIN SmartMeter sm 
    ON l.location_id = sm.location_id
JOIN EnergyReading er 
    ON sm.meter_id = er.meter_id;
GO

-- View 2: Shows alert information with user and location details.
-- This view can be used by managers or operators to monitor active issues.

CREATE VIEW vw_AlertSummary AS
SELECT 
    a.alert_id,
    u.user_id,
    u.full_name,
    l.location_id,
    l.suburb,
    a.alert_type,
    a.severity,
    a.alert_status,
    a.created_date
FROM Alert a
JOIN Location l 
    ON a.location_id = l.location_id
JOIN UserAccount u 
    ON l.user_id = u.user_id;
GO