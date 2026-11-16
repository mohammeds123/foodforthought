-- =============================================================================
-- 03_events.sql
-- Nightly job: mark lots expired. Run after 01_schema.sql (and 02 if you want).
-- Check: SHOW VARIABLES LIKE 'event_scheduler';  -- should be ON (MySQL 8.4+ default)
-- If it is OFF: SET GLOBAL event_scheduler = ON;  (needs SUPER / SYSTEM_VARIABLES_ADMIN)
-- =============================================================================

USE foodforthought;

DROP EVENT IF EXISTS ev_mark_expired_lots;

-- Runs every night at 00:15. UPDATE only; do not delete lots (Packed_From still
-- needs the identifying key).
CREATE EVENT ev_mark_expired_lots
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 15 MINUTE)
DO
    UPDATE INVENTORY_LOT
    SET Lot_Status = 'Expired'
    WHERE Expiry_Date IS NOT NULL
      AND Expiry_Date < CURRENT_DATE
      AND (Lot_Status IS NULL OR Lot_Status <> 'Expired');

-- Manual test (same statement the event uses):
-- UPDATE INVENTORY_LOT
-- SET Lot_Status = 'Expired'
-- WHERE Expiry_Date < CURRENT_DATE
--   AND (Lot_Status IS NULL OR Lot_Status <> 'Expired');
