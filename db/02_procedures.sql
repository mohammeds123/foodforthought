-- =============================================================================
-- 02_procedures.sql
-- Run after 01_schema.sql. These are the planned stored procedures for the
-- final project. Bodies are stubs with the steps you still need to fill in.
-- Express should only CALL these; it should not implement the same rules.
--
-- Total-participation rules a FK cannot enforce (from the RM):
--   * a Hamper must have at least one PACKED_FROM row
--   * a Shift must have at least one SIGN_UP row
--   * every Fulfillment_ID is in exactly one of PICKUP or DELIVERY
--   * at most one successful fulfillment per hamper
-- =============================================================================

USE foodforthought;

DROP PROCEDURE IF EXISTS sp_build_hamper;
DROP PROCEDURE IF EXISTS sp_create_pickup;
DROP PROCEDURE IF EXISTS sp_create_delivery;
DROP PROCEDURE IF EXISTS sp_record_pickup;
DROP PROCEDURE IF EXISTS sp_record_delivery;
DROP PROCEDURE IF EXISTS sp_confirm_shift;
DROP PROCEDURE IF EXISTS sp_low_stock;

DELIMITER $$

-- Staff builds a hamper for a household
CREATE PROCEDURE sp_build_hamper(
    IN p_household_id INT,
    IN p_staff_id INT
)
BEGIN
    DECLARE v_hamper_id INT;

    -- Roll back if error occurs
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Check whether household and staff exists
    IF NOT EXISTS (SELECT 1 FROM HOUSEHOLD WHERE Household_ID = p_household_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'household does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM STAFF WHERE Staff_ID = p_staff_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'staff does not exist';
    END IF;

    -- Start transaction
    START TRANSACTION;

    INSERT INTO HAMPER (Build_Date, Household_ID, Staff_ID)
    VALUES (CURDATE(), p_household_id, p_staff_id);

    SET v_hamper_id = LAST_INSERT_ID();

    -- Add eligible inventory lots to hamper
    INSERT INTO PACKED_FROM (Hamper_ID, Donation_ID, Lot_Line_No, Quantity_Taken)

    SELECT v_hamper_id, IL.Donation_ID, IL.Lot_Line_No, 1
    FROM INVENTORY_LOT AS IL
    JOIN FOOD_ITEM AS FI ON IL.Item_ID = FI.Item_ID
    WHERE IL.Quantity_On_Hand > 0
    AND IL.Lot_Status = 'Available'
    AND (IL.Expiry_Date IS NULL OR IL.Expiry_Date > CURDATE())

    -- Checking dietary requirements
    AND NOT EXISTS ( -- Checks whether there are missing dietary requirements for household
        SELECT 1 
        FROM REQUIRES AS R
        WHERE R.Household_ID = p_household_id
        AND NOT EXISTS ( -- Checks whether food item is missing dietary tag required by household
            SELECT 1
            FROM TAGGED_AS AS T
            WHERE T.Item_ID = FI.Item_ID
            AND T.Need_Name = R.Need_Name
        )
    );

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No eligible inventory available';
    END IF;

    -- Reducing inventory quantity after packing hamper
    UPDATE INVENTORY_LOT AS IL
    JOIN PACKED_FROM AS PF ON IL.Donation_ID = PF.Donation_ID AND IL.Lot_Line_No = PF.Lot_Line_No
    SET IL.Lot_Status = CASE
            WHEN IL.Quantity_On_Hand - PF.Quantity_Taken = 0
            THEN 'Depleted'
            ELSE IL.Lot_Status
        END,
        IL.Quantity_On_Hand = IL.Quantity_On_Hand - PF.Quantity_Taken
    WHERE PF.Hamper_ID = v_hamper_id;

    COMMIT; -- Commit transaction if all operations succeed (Permanent changes to the database)

END $$

-- Creates a FULFILLMENT row plus the PICKUP subclass 
CREATE PROCEDURE sp_create_pickup(
    IN p_hamper_id INT,
    IN p_scheduled_date DATE,
    IN p_pickup_time TIME,
    IN p_collector_type VARCHAR(50),
    IN p_proxy_name VARCHAR(100)
)
BEGIN
    DECLARE v_pickup_id INT; -- local variable to store the generated Fulfillment_ID

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; -- Roll back the transaction if an error occurs
        RESIGNAL; -- Re-throw the exception to propagate the error
    END;

    START TRANSACTION;

    INSERT INTO FULFILLMENT (Status, Scheduled_Date, Hamper_ID)
    VALUES ('Scheduled', p_scheduled_date, p_hamper_id);

    SET v_pickup_id = LAST_INSERT_ID();

    INSERT INTO PICKUP (Fulfillment_ID, Pickup_Time, Collector_Type, Proxy_Name)
    VALUES (v_pickup_id, p_pickup_time, p_collector_type, p_proxy_name);

    COMMIT;

END $$

-- Creates a FULFILLMENT row plus the DELIVERY subclass
CREATE PROCEDURE sp_create_delivery(
    IN p_hamper_id INT,
    IN p_scheduled_date DATE,
    IN p_departure_time TIME,
    IN p_arrival_time TIME,
    IN p_driver_staff_id INT,
    IN p_driver_volunteer_id INT
)
BEGIN

    DECLARE v_fulfillment_id INT; -- local variable to store the generated Fulfillment_ID
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; -- Roll back the transaction if an error occurs
        RESIGNAL; -- Re-throw the exception to propagate the error
    END;

    -- Check that exactly one driver is provided
    IF (p_driver_staff_id IS NULL AND p_driver_volunteer_id IS NULL) OR (p_driver_staff_id IS NOT NULL AND p_driver_volunteer_id IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'exactly one driver must be provided';
    END IF;

    -- Check if hamper exists
    IF NOT EXISTS (SELECT 1 FROM HAMPER WHERE Hamper_ID = p_hamper_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'hamper does not exist';
    END IF;

    START TRANSACTION;

    -- Insert into FULFILLMENT table
    INSERT INTO FULFILLMENT (Status, Scheduled_Date, Hamper_ID)
    VALUES ('Scheduled', p_scheduled_date, p_hamper_id);

    SET v_fulfillment_id = LAST_INSERT_ID(); -- Get the generated Fulfillment_ID

    INSERT INTO DELIVERY (Fulfillment_ID, Departure_Time, Arrival_Time, Driver_Staff_ID, Driver_Volunteer_ID)
    VALUES (v_fulfillment_id, p_departure_time, p_arrival_time, p_driver_staff_id, p_driver_volunteer_id);

    COMMIT; -- Commit transaction

END $$

-- Marks a pickup attempt succeeded/failed -> CALL sp_record_pickup(1, 'Succeeded')
CREATE PROCEDURE sp_record_pickup(
    IN p_fulfillment_id INT,
    IN p_status VARCHAR(50)
)
BEGIN

    DECLARE v_hamper_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Validate Status (Might change later, if we decide to use ENUM for p_status )
    IF p_status IS NULL OR p_status NOT IN ('Succeeded', 'Failed') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid pickup status';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM FULFILLMENT AS F
        JOIN PICKUP AS P 
        ON F.Fulfillment_ID = P.Fulfillment_ID
        WHERE F.Fulfillment_ID = p_fulfillment_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pickup fulfillment does not exist';
    END IF;

    START TRANSACTION;

    SELECT Hamper_ID
    INTO v_hamper_id
    FROM FULFILLMENT
    WHERE Fulfillment_ID = p_fulfillment_id;

    -- If marking pickup as successful, check whether hamper is already marked as 'Successful' in db
    IF p_status = 'Succeeded' THEN
        IF EXISTS (
            SELECT 1 
            FROM FULFILLMENT 
            WHERE Hamper_ID = v_hamper_id
                AND Status = 'Succeeded'
                AND Fulfillment_ID <> p_fulfillment_id -- '<>'' is ' not equal to != '
                -- Exclude current fulfillment attempt, and check whether the same hamper exists in fulfillment table with status 'Succeeded'
            ) THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Hamper already fulfilled successfully';
        END IF;
    END IF;

      
    
    UPDATE FULFILLMENT
    SET Status = p_status
    WHERE Fulfillment_ID = p_fulfillment_id;

    COMMIT;
END $$

CREATE PROCEDURE sp_record_delivery(
    IN p_fulfillment_id INT,
    IN p_status VARCHAR(50),
    IN p_arrival_time TIME
)
BEGIN
    DECLARE v_hamper_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Check if Fulfillment_ID exists in DELIVERY Table
    IF NOT EXISTS (
        SELECT 1
        FROM DELIVERY
        WHERE Fulfillment_ID = p_fulfillment_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Fulfillment ID does not exist';
    END IF;

    START TRANSACTION;

    SELECT Hamper_ID
    INTO v_hamper_id
    FROM FULFILLMENT
    WHERE Fulfillment_ID = p_fulfillment_id;

    -- If marking delivery as successful, check whether hamper is already marked as 'Succeeded' in db
    IF p_status = 'Succeeded' THEN
        IF EXISTS (
            SELECT 1 
            FROM FULFILLMENT 
            WHERE Hamper_ID = v_hamper_id
                AND Status = 'Succeeded'
                AND Fulfillment_ID <> p_fulfillment_id -- '<>'' is ' not equal to != '
                -- Exclude current fulfillment attempt, and check whether the same hamper exists in fulfillment table with status 'Succeeded'
            ) THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Hamper already fulfilled successfully';
        END IF;
    END IF;

    -- update delivery arrival time with given arrival time
    UPDATE DELIVERY
    SET Arrival_Time = p_arrival_time
    WHERE Fulfillment_ID = p_fulfillment_id;

    -- update fulfillment status with given status
    UPDATE FULFILLMENT
    SET Status = p_status
    WHERE Fulfillment_ID = p_fulfillment_id;

    COMMIT;
END $$


-- CALL sp_confirm_shift(1, 1);
CREATE PROCEDURE sp_confirm_shift(
    IN p_volunteer_id INT,
    IN p_shift_id INT
)
BEGIN
    DECLARE v_shift_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Check whether volunteer id is valid
    IF NOT EXISTS (
        SELECT 1
        FROM VOLUNTEER
        WHERE Volunteer_ID = p_volunteer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Volunteer does not exist';
    END IF;

    -- Check whether shift id is valid
    IF NOT EXISTS (
        SELECT 1
        FROM SHIFT
        WHERE Shift_ID = p_shift_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Shift does not exist';
    END IF;

    START TRANSACTION;

    -- Check whether volunteer is already assigned to this same shift
    IF EXISTS (
        SELECT 1 FROM SIGN_UP
        WHERE Volunteer_ID = p_volunteer_id AND Shift_ID = p_shift_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Volunteer already assigned to this shift';
    END IF;

    INSERT INTO SIGN_UP (Volunteer_ID, Shift_ID)
    VALUES (p_volunteer_id, p_shift_id);

    COMMIT;

END $$


-- CALL sp_low_stock()

-- Returns all food items whose total quantity on hand is below the low-stock threshold.
CREATE PROCEDURE sp_low_stock()
BEGIN
    SELECT
        fi.Item_ID,
        fi.Item_Name,
        fi.Food_Category,
        fi.Low_Stock_Threshold,
        COALESCE(SUM(il.Quantity_On_Hand), 0) AS Quantity_On_Hand
    FROM FOOD_ITEM AS fi
    LEFT JOIN INVENTORY_LOT AS il
        ON il.Item_ID = fi.Item_ID
        AND (il.Lot_Status IS NULL OR il.Lot_Status <> 'Expired')
    GROUP BY fi.Item_ID, fi.Item_Name, fi.Food_Category, fi.Low_Stock_Threshold
    HAVING fi.Low_Stock_Threshold IS NOT NULL
       AND COALESCE(SUM(il.Quantity_On_Hand), 0) < fi.Low_Stock_Threshold;
END $$

DELIMITER ;
