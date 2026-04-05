CREATE TABLE IF NOT EXISTS holidays (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    country_code TEXT NOT NULL,
    event_name TEXT NOT NULL,
    event_type TEXT NOT NULL CHECK (
        event_type IN ('religious', 'national', 'shopping', 'seasonal', 'health')
    ),
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    importance_weight REAL NOT NULL DEFAULT 1.0,
    category TEXT NOT NULL,
    UNIQUE(country_code, event_name, start_date)
);

CREATE INDEX IF NOT EXISTS idx_holidays_country ON holidays(country_code);
CREATE INDEX IF NOT EXISTS idx_holidays_type ON holidays(event_type);
CREATE INDEX IF NOT EXISTS idx_holidays_date ON holidays(start_date, end_date);
