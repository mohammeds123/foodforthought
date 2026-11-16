-- =============================================================================
-- 04_seed.sql
-- Sample DML for Progress Report 3: INSERT (referential order), then example
-- UPDATE / DELETE. Expand to ~10 rows per table before the PDF if the rubric
-- asks for that volume. Parents first; PICKUP and DELIVERY never share an id.
-- =============================================================================

USE foodforthought;

-- Wipe child-to-parent so this file can be re-run after 01_schema.sql.
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE PACKED_FROM;
TRUNCATE TABLE PICKUP;
TRUNCATE TABLE DELIVERY;
TRUNCATE TABLE FULFILLMENT;
TRUNCATE TABLE INVENTORY_LOT;
TRUNCATE TABLE SIGN_UP;
TRUNCATE TABLE SHIFT;
TRUNCATE TABLE VOLUNTEER_SKILL;
TRUNCATE TABLE HAMPER;
TRUNCATE TABLE TAGGED_AS;
TRUNCATE TABLE REQUIRES;
TRUNCATE TABLE DONATION;
TRUNCATE TABLE DIETARY_NEED;
TRUNCATE TABLE STORAGE_LOCATION;
TRUNCATE TABLE FOOD_ITEM;
TRUNCATE TABLE HOUSEHOLD;
TRUNCATE TABLE VOLUNTEER;
TRUNCATE TABLE STAFF;
TRUNCATE TABLE DONOR;
SET FOREIGN_KEY_CHECKS = 1;

-- ----- independent entities -----
INSERT INTO DONOR (Donor_Name, Donor_Type, Email, Phone) VALUES
    ('Calgary Food Bank Partner', 'Organization', 'give@example.org', '4035550101'),
    ('Amina Khan', 'Individual', 'amina@example.com', '4035550102');

INSERT INTO STAFF (Staff_Name, Position, Email, Phone) VALUES
    ('Jordan Lee', 'Coordinator', 'jordan@fft.local', '4035550201'),
    ('Sam Patel', 'Warehouse', 'sam@fft.local', '4035550202');

INSERT INTO VOLUNTEER (Volunteer_Name, Start_Date, Email, Phone) VALUES
    ('Riley Chen', '2026-01-15', 'riley@example.com', '4035550301'),
    ('Morgan Diaz', '2026-03-01', 'morgan@example.com', '4035550302');

INSERT INTO HOUSEHOLD (Contact_Name, Phone, Email, Street, City, Postal_Code, Registration_Date, Duplicate_Flag, Household_Size) VALUES
    ('Taylor Nguyen', '4035550401', 'taylor@example.com', '12 Centre St', 'Calgary', 'T2E2R2', '2026-02-01', FALSE, 4),
    ('Chris Walsh', '4035550402', 'chris@example.com', '88 4 Ave SW', 'Calgary', 'T2P0H5', '2026-04-10', FALSE, 2);

INSERT INTO FOOD_ITEM (Item_Name, Food_Category, Storage_Type, Low_Stock_Threshold) VALUES
    ('2% Milk 2L', 'Dairy', 'Cooler', 10),
    ('Brown Rice 1kg', 'Grain', 'Dry', 8),
    ('Canned Beans', 'Protein', 'Dry', 12);

INSERT INTO STORAGE_LOCATION (Location_Name, Storage_Type) VALUES
    ('Cooler A', 'Cooler'),
    ('Dry Shelf 1', 'Dry');

INSERT INTO DIETARY_NEED (Need_Name, Need_Type) VALUES
    ('Halal', 'Religion'),
    ('Gluten-free', 'Allergy'),
    ('Dairy-free', 'Allergy');

-- ----- 1:N and M:N -----
INSERT INTO DONATION (Date_Received, Donation_Type, Fund_Amount, Donor_ID, Staff_ID) VALUES
    ('2026-10-01', 'Food', NULL, 1, 1),
    ('2026-10-15', 'Funds', 250.00, 2, 1);

INSERT INTO REQUIRES (Household_ID, Need_Name) VALUES
    (1, 'Halal'),
    (1, 'Gluten-free'),
    (2, 'Dairy-free');

INSERT INTO TAGGED_AS (Item_ID, Need_Name) VALUES
    (2, 'Halal'),
    (2, 'Gluten-free'),
    (3, 'Halal');

INSERT INTO VOLUNTEER_SKILL (Volunteer_ID, Skill) VALUES
    (1, 'Driving'),
    (1, 'Sorting'),
    (2, 'Customer service');

INSERT INTO SHIFT (Shift_Date, Start_Time, End_Time, Duty, Staff_ID) VALUES
    ('2026-11-14', '09:00:00', '13:00:00', 'Warehouse sort', 2),
    ('2026-11-15', '13:00:00', '17:00:00', 'Hamper pack', 1);

INSERT INTO SIGN_UP (Volunteer_ID, Shift_ID) VALUES
    (1, 1),
    (2, 1),
    (2, 2);

-- Weak entity lots: line numbers are 1, 2 under donation 1
INSERT INTO INVENTORY_LOT (Donation_ID, Lot_Line_No, Quantity_On_Hand, Expiry_Date, Lot_Status, Item_ID, Location_ID) VALUES
    (1, 1, 24, '2026-12-01', 'Available', 1, 1),
    (1, 2, 40, '2027-06-01', 'Available', 2, 2),
    (1, 3, 30, '2027-01-15', 'Available', 3, 2);

INSERT INTO HAMPER (Build_Date, Household_ID, Staff_ID) VALUES
    ('2026-11-10', 1, 1),
    ('2026-11-11', 2, 2);

-- Hamper 1 packed from two lots (satisfies "at least one lot per hamper")
INSERT INTO PACKED_FROM (Hamper_ID, Donation_ID, Lot_Line_No, Quantity_Taken) VALUES
    (1, 1, 2, 2),
    (1, 1, 3, 4),
    (2, 1, 1, 1);

INSERT INTO FULFILLMENT (Status, Scheduled_Date, Hamper_ID) VALUES
    ('Scheduled', '2026-11-16', 1),
    ('Scheduled', '2026-11-17', 2);

-- Fulfillment 1 = pickup, fulfillment 2 = delivery (disjoint)
INSERT INTO PICKUP (Fulfillment_ID, Pickup_Time, Collector_Type, Proxy_Name) VALUES
    (1, '14:00:00', 'Household', NULL);

INSERT INTO DELIVERY (Fulfillment_ID, Departure_Time, Arrival_Time, Driver_Staff_ID, Driver_Volunteer_ID) VALUES
    (2, '09:30:00', NULL, NULL, 1);

-- ----- example UPDATE (PR3: include update/delete, not only CREATE TABLE) -----
-- Record that milk was used after packing hamper 2.
UPDATE INVENTORY_LOT
SET Quantity_On_Hand = Quantity_On_Hand - 1
WHERE Donation_ID = 1 AND Lot_Line_No = 1;

UPDATE FULFILLMENT
SET Status = 'Succeeded'
WHERE Fulfillment_ID = 1;

-- ----- example DELETE -----
-- Remove a volunteer from one shift; the other SIGN_UP rows stay.
DELETE FROM SIGN_UP
WHERE Volunteer_ID = 2 AND Shift_ID = 2;

-- This should fail if uncommented: Staff 1 still recorded donations (ON DELETE RESTRICT).
-- DELETE FROM STAFF WHERE Staff_ID = 1;
