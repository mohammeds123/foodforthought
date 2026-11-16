-- FoodForThought: one-time local MySQL setup (run as root).
-- Paste CREATE DATABASE into the Progress Report 3 DDL section as well.
--
-- Order: 00_create_database.sql → 01_schema.sql → 02_procedures.sql
--        → 03_events.sql → 04_seed.sql
-- SQLTools: connection "FoodForThought" (root, 127.0.0.1:33060, xprotocol).

CREATE DATABASE IF NOT EXISTS foodforthought;

CREATE USER IF NOT EXISTS 'fft_app'@'localhost' IDENTIFIED BY 'change-me';
CREATE USER IF NOT EXISTS 'fft_app'@'127.0.0.1' IDENTIFIED BY 'change-me';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON foodforthought.* TO 'fft_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON foodforthought.* TO 'fft_app'@'127.0.0.1';

FLUSH PRIVILEGES;
