USE EnergyManagementDB;
GO

-- Query 1: Low Complexity
-- Shows all active users in the system.

SELECT 
    full_name, 
    email, 
    account_status
FROM UserAccount
WHERE account_status = 'Active'
ORDER BY full_name;


-- Query 2: Low Complexity
-- Displays all active smart meters ordered by installation date.

SELECT 
    meter_serial, 
    installation_date, 
    meter_status
FROM SmartMeter
WHERE meter_status = 'Active'
ORDER BY installation_date;


-- Query 3: Low Complexity
-- Counts the total number of alerts for each severity level.

SELECT 
    severity, 
    COUNT(*) AS total_alerts
FROM Alert
GROUP BY severity
ORDER BY total_alerts DESC;


-- Query 4: Low Complexity
-- Shows energy sources with capacity greater than 20 kW.

SELECT 
    source_type, 
    capacity_kw, 
    source_status
FROM EnergySource
WHERE capacity_kw > 20
ORDER BY capacity_kw DESC;


-- Query 5: Medium Complexity
-- Shows users with their location and smart meter details.

SELECT 
    u.full_name,
    l.suburb,
    l.location_type,
    sm.meter_serial,
    sm.meter_status
FROM UserAccount u
JOIN Location l 
    ON u.user_id = l.user_id
JOIN SmartMeter sm 
    ON l.location_id = sm.location_id
ORDER BY l.suburb;


-- Query 6: Medium Complexity
-- Shows total energy readings by suburb using Location, SmartMeter and EnergyReading.

SELECT 
    l.suburb,
    COUNT(er.reading_id) AS total_readings,
    SUM(er.reading_value_kwh) AS total_energy_kwh
FROM Location l
JOIN SmartMeter sm 
    ON l.location_id = sm.location_id
JOIN EnergyReading er 
    ON sm.meter_id = er.meter_id
GROUP BY l.suburb
ORDER BY total_energy_kwh DESC;


-- Query 7: High Complexity
-- Shows suburbs where total energy usage is higher than the average suburb-level usage.

SELECT 
    eus.suburb,
    SUM(eus.reading_value_kwh) AS total_energy_kwh,
    COUNT(DISTINCT als.alert_id) AS total_alerts
FROM vw_EnergyUsageSummary eus
LEFT JOIN vw_AlertSummary als
    ON eus.location_id = als.location_id
GROUP BY eus.suburb
HAVING SUM(eus.reading_value_kwh) >
(
    SELECT AVG(SuburbTotal.total_energy_kwh)
    FROM
    (
        SELECT 
            suburb,
            SUM(reading_value_kwh) AS total_energy_kwh
        FROM vw_EnergyUsageSummary
        GROUP BY suburb
    ) AS SuburbTotal
)
ORDER BY total_energy_kwh DESC;