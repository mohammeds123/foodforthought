-- =============================================================================
-- 03_events.sql
-- Nightly MySQL event (run after 01_schema.sql and 02_procedures.sql).
-- =============================================================================
-- Put the CREATE EVENT statement here that marks expired lots.
-- Confirm the scheduler is on: SHOW VARIABLES LIKE 'event_scheduler';
--
-- Do not put tables, procedures, or seed data in this file.
-- =============================================================================

USE foodforthought;

-- CREATE EVENT statement goes below this line.
