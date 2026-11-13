-- FoodForThought: one-time local MySQL setup (run as root).
-- In VS Code / Cursor: open this file, pick the "FoodForThought" SQLTools
-- connection (root), then Run on Active Connection.
--
-- After this script, run 01_schema.sql, 02_procedures.sql, 03_events.sql,
-- then 04_seed.sql, in that order.

CREATE DATABASE IF NOT EXISTS foodforthought;

CREATE USER IF NOT EXISTS 'fft_app'@'localhost' IDENTIFIED BY 'change-me';
CREATE USER IF NOT EXISTS 'fft_app'@'127.0.0.1' IDENTIFIED BY 'change-me';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON foodforthought.* TO 'fft_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON foodforthought.* TO 'fft_app'@'127.0.0.1';

FLUSH PRIVILEGES;
