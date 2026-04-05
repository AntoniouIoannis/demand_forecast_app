INSERT OR IGNORE INTO holidays (
    country_code,
    event_name,
    event_type,
    start_date,
    end_date,
    importance_weight,
    category
) VALUES
-- Requested sample records
('EG', 'Ramadan', 'religious', '2026-02-17', '2026-03-18', 1.00, 'Faith & Fasting'),
('IN', 'Diwali', 'religious', '2026-11-08', '2026-11-12', 0.95, 'Festival Season'),
('GR', 'Orthodox Easter', 'religious', '2026-04-10', '2026-04-13', 0.92, 'Religious Holidays'),
('US', 'Black Friday', 'shopping', '2026-11-27', '2026-11-27', 1.00, 'Retail Peak'),
('CN', 'Chinese New Year', 'national', '2026-02-17', '2026-02-23', 1.00, 'National Week'),

-- Additional useful records
('US', 'Cyber Monday', 'shopping', '2026-11-30', '2026-11-30', 0.95, 'Retail Peak'),
('GR', 'Clean Monday', 'religious', '2026-02-23', '2026-02-23', 0.65, 'Religious Holidays'),
('EG', 'Eid al-Fitr', 'religious', '2026-03-19', '2026-03-21', 0.98, 'Faith & Fasting'),
('IN', 'Holi', 'religious', '2026-03-03', '2026-03-03', 0.75, 'Festival Season'),
('CN', 'Singles Day', 'shopping', '2026-11-11', '2026-11-11', 0.97, 'E-commerce Peak'),
('US', 'Thanksgiving', 'national', '2026-11-26', '2026-11-26', 0.90, 'National Holidays'),
('GR', 'Summer Tourism Peak', 'seasonal', '2026-07-01', '2026-08-31', 0.85, 'Tourism Season'),
('EG', 'Back to School', 'seasonal', '2026-09-01', '2026-09-20', 0.70, 'Education Cycle'),
('IN', 'Monsoon Demand Shift', 'seasonal', '2026-06-15', '2026-09-15', 0.60, 'Weather Seasonality'),
('CN', 'Golden Week', 'national', '2026-10-01', '2026-10-07', 0.94, 'National Week'),
('US', 'Flu Season Start', 'health', '2026-10-01', '2026-12-15', 0.55, 'Healthcare Demand'),
('GR', 'Flu Vaccination Campaign', 'health', '2026-10-01', '2026-11-30', 0.50, 'Healthcare Demand');
