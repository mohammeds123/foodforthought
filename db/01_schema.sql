-- =============================================================================
-- 01_schema.sql
-- 19 relations from the FoodForThought RM / EERD.
-- Run after 00_create_database.sql, before 02_procedures.sql.
-- App_Account is not on the EERD; see the commented stub at the bottom.
-- =============================================================================

USE foodforthought;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS PACKED_FROM;
DROP TABLE IF EXISTS PICKUP;
DROP TABLE IF EXISTS DELIVERY;
DROP TABLE IF EXISTS FULFILLMENT;
DROP TABLE IF EXISTS INVENTORY_LOT;
DROP TABLE IF EXISTS SIGN_UP;
DROP TABLE IF EXISTS SHIFT;
DROP TABLE IF EXISTS VOLUNTEER_SKILL;
DROP TABLE IF EXISTS HAMPER;
DROP TABLE IF EXISTS TAGGED_AS;
DROP TABLE IF EXISTS REQUIRES;
DROP TABLE IF EXISTS DONATION;
DROP TABLE IF EXISTS DIETARY_NEED;
DROP TABLE IF EXISTS STORAGE_LOCATION;
DROP TABLE IF EXISTS FOOD_ITEM;
DROP TABLE IF EXISTS HOUSEHOLD;
DROP TABLE IF EXISTS VOLUNTEER;
DROP TABLE IF EXISTS STAFF;
DROP TABLE IF EXISTS DONOR;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------------
-- Independent entities
-- ---------------------------------------------------------------------------

CREATE TABLE DONOR (
    Donor_ID INT NOT NULL AUTO_INCREMENT,
    Donor_Name VARCHAR(100) NOT NULL,
    Donor_Type VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    CONSTRAINT pk_donor PRIMARY KEY (Donor_ID)
);

CREATE TABLE STAFF (
    Staff_ID INT NOT NULL AUTO_INCREMENT,
    Staff_Name VARCHAR(100) NOT NULL,
    Position VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    CONSTRAINT pk_staff PRIMARY KEY (Staff_ID)
);

CREATE TABLE VOLUNTEER (
    Volunteer_ID INT NOT NULL AUTO_INCREMENT,
    Volunteer_Name VARCHAR(100) NOT NULL,
    Start_Date DATE,
    Email VARCHAR(100),
    Phone VARCHAR(15),
    CONSTRAINT pk_volunteer PRIMARY KEY (Volunteer_ID)
);

CREATE TABLE HOUSEHOLD (
    Household_ID INT NOT NULL AUTO_INCREMENT,
    Contact_Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(15),
    Email VARCHAR(100),
    Street VARCHAR(255),
    City VARCHAR(100),
    Postal_Code VARCHAR(10),
    Registration_Date DATE,
    Duplicate_Flag BOOLEAN DEFAULT FALSE,
    Household_Size INT,
    CONSTRAINT pk_household PRIMARY KEY (Household_ID),
    CONSTRAINT chk_household_size CHECK (Household_Size IS NULL OR Household_Size > 0)
);

CREATE TABLE FOOD_ITEM (
    Item_ID INT NOT NULL AUTO_INCREMENT,
    Item_Name VARCHAR(100) NOT NULL,
    Food_Category VARCHAR(50),
    Storage_Type VARCHAR(50),
    Low_Stock_Threshold INT,
    CONSTRAINT pk_food_item PRIMARY KEY (Item_ID),
    CONSTRAINT chk_low_stock CHECK (Low_Stock_Threshold IS NULL OR Low_Stock_Threshold >= 0)
);

CREATE TABLE STORAGE_LOCATION (
    Location_ID INT NOT NULL AUTO_INCREMENT,
    Location_Name VARCHAR(100) NOT NULL,
    Storage_Type VARCHAR(50),
    CONSTRAINT pk_storage_location PRIMARY KEY (Location_ID)
);

CREATE TABLE DIETARY_NEED (
    Need_Name VARCHAR(50) NOT NULL,
    Need_Type VARCHAR(50),
    CONSTRAINT pk_dietary_need PRIMARY KEY (Need_Name)
);

-- ---------------------------------------------------------------------------
-- 1:N from Donor / Staff. Donor_ID and Staff_ID are NOT NULL (total participation).
-- Do not CASCADE-delete donations if a person row is removed.
-- ---------------------------------------------------------------------------

CREATE TABLE DONATION (
    Donation_ID INT NOT NULL AUTO_INCREMENT,
    Date_Received DATE,
    Donation_Type VARCHAR(50),
    Fund_Amount DECIMAL(10, 2),
    Donor_ID INT NOT NULL,
    Staff_ID INT NOT NULL,
    CONSTRAINT pk_donation PRIMARY KEY (Donation_ID),
    CONSTRAINT fk_donation_donor
        FOREIGN KEY (Donor_ID) REFERENCES DONOR (Donor_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_donation_staff
        FOREIGN KEY (Staff_ID) REFERENCES STAFF (Staff_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_fund_amount CHECK (Fund_Amount IS NULL OR Fund_Amount >= 0)
);

CREATE TABLE REQUIRES (
    Household_ID INT NOT NULL,
    Need_Name VARCHAR(50) NOT NULL,
    CONSTRAINT pk_requires PRIMARY KEY (Household_ID, Need_Name),
    CONSTRAINT fk_requires_household
        FOREIGN KEY (Household_ID) REFERENCES HOUSEHOLD (Household_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_requires_need
        FOREIGN KEY (Need_Name) REFERENCES DIETARY_NEED (Need_Name)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TAGGED_AS (
    Item_ID INT NOT NULL,
    Need_Name VARCHAR(50) NOT NULL,
    CONSTRAINT pk_tagged_as PRIMARY KEY (Item_ID, Need_Name),
    CONSTRAINT fk_tagged_item
        FOREIGN KEY (Item_ID) REFERENCES FOOD_ITEM (Item_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tagged_need
        FOREIGN KEY (Need_Name) REFERENCES DIETARY_NEED (Need_Name)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE HAMPER (
    Hamper_ID INT NOT NULL AUTO_INCREMENT,
    Build_Date DATE,
    Household_ID INT NOT NULL,
    Staff_ID INT NOT NULL,
    CONSTRAINT pk_hamper PRIMARY KEY (Hamper_ID),
    CONSTRAINT fk_hamper_household
        FOREIGN KEY (Household_ID) REFERENCES HOUSEHOLD (Household_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_hamper_staff
        FOREIGN KEY (Staff_ID) REFERENCES STAFF (Staff_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Multivalued Skills on VOLUNTEER -> Volunteer_Skill(Volunteer_ID, Skill)
CREATE TABLE VOLUNTEER_SKILL (
    Volunteer_ID INT NOT NULL,
    Skill VARCHAR(50) NOT NULL,
    CONSTRAINT pk_volunteer_skill PRIMARY KEY (Volunteer_ID, Skill),
    CONSTRAINT fk_skill_volunteer
        FOREIGN KEY (Volunteer_ID) REFERENCES VOLUNTEER (Volunteer_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE SHIFT (
    Shift_ID INT NOT NULL AUTO_INCREMENT,
    Shift_Date DATE,
    Start_Time TIME,
    End_Time TIME,
    Duty VARCHAR(100),
    Staff_ID INT NOT NULL,
    CONSTRAINT pk_shift PRIMARY KEY (Shift_ID),
    CONSTRAINT fk_shift_staff
        FOREIGN KEY (Staff_ID) REFERENCES STAFF (Staff_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE SIGN_UP (
    Volunteer_ID INT NOT NULL,
    Shift_ID INT NOT NULL,
    CONSTRAINT pk_sign_up PRIMARY KEY (Volunteer_ID, Shift_ID),
    CONSTRAINT fk_signup_volunteer
        FOREIGN KEY (Volunteer_ID) REFERENCES VOLUNTEER (Volunteer_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_signup_shift
        FOREIGN KEY (Shift_ID) REFERENCES SHIFT (Shift_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- Weak entity: identifying owner Donation + partial key Lot_Line_No.
-- Item_ID and Location_ID are NOT NULL (total participation).
CREATE TABLE INVENTORY_LOT (
    Donation_ID INT NOT NULL,
    Lot_Line_No INT NOT NULL,
    Quantity_On_Hand INT NOT NULL,
    Expiry_Date DATE,
    Lot_Status VARCHAR(50),
    Item_ID INT NOT NULL,
    Location_ID INT NOT NULL,
    CONSTRAINT pk_inventory_lot PRIMARY KEY (Donation_ID, Lot_Line_No),
    CONSTRAINT fk_lot_donation
        FOREIGN KEY (Donation_ID) REFERENCES DONATION (Donation_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lot_item
        FOREIGN KEY (Item_ID) REFERENCES FOOD_ITEM (Item_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_lot_location
        FOREIGN KEY (Location_ID) REFERENCES STORAGE_LOCATION (Location_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_qty_on_hand CHECK (Quantity_On_Hand >= 0)
);

CREATE TABLE PACKED_FROM (
    Hamper_ID INT NOT NULL,
    Donation_ID INT NOT NULL,
    Lot_Line_No INT NOT NULL,
    Quantity_Taken INT NOT NULL,
    CONSTRAINT pk_packed_from PRIMARY KEY (Hamper_ID, Donation_ID, Lot_Line_No),
    CONSTRAINT fk_packed_hamper
        FOREIGN KEY (Hamper_ID) REFERENCES HAMPER (Hamper_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_packed_lot
        FOREIGN KEY (Donation_ID, Lot_Line_No)
        REFERENCES INVENTORY_LOT (Donation_ID, Lot_Line_No)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_qty_taken CHECK (Quantity_Taken > 0)
);

CREATE TABLE FULFILLMENT (
    Fulfillment_ID INT NOT NULL AUTO_INCREMENT,
    Status VARCHAR(50),
    Scheduled_Date DATE,
    Hamper_ID INT NOT NULL,
    CONSTRAINT pk_fulfillment PRIMARY KEY (Fulfillment_ID),
    CONSTRAINT fk_fulfillment_hamper
        FOREIGN KEY (Hamper_ID) REFERENCES HAMPER (Hamper_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Disjoint total specialization (Option 8A): every Fulfillment_ID is in
-- exactly one of PICKUP or DELIVERY. The XOR across tables is enforced in
-- 02_procedures.sql (sp_create_pickup / sp_create_delivery), not by a FK.

CREATE TABLE PICKUP (
    Fulfillment_ID INT NOT NULL,
    Pickup_Time TIME,
    Collector_Type VARCHAR(50),
    Proxy_Name VARCHAR(100),
    CONSTRAINT pk_pickup PRIMARY KEY (Fulfillment_ID),
    CONSTRAINT fk_pickup_fulfillment
        FOREIGN KEY (Fulfillment_ID) REFERENCES FULFILLMENT (Fulfillment_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_proxy_name CHECK (
        (Collector_Type = 'Proxy' AND Proxy_Name IS NOT NULL)
        OR (Collector_Type = 'Household' AND Proxy_Name IS NULL)
        OR Collector_Type IS NULL
    )
);

CREATE TABLE DELIVERY (
    Fulfillment_ID INT NOT NULL,
    Departure_Time TIME,
    Arrival_Time TIME,
    Driver_Staff_ID INT,
    Driver_Volunteer_ID INT,
    CONSTRAINT pk_delivery PRIMARY KEY (Fulfillment_ID),
    CONSTRAINT fk_delivery_fulfillment
        FOREIGN KEY (Fulfillment_ID) REFERENCES FULFILLMENT (Fulfillment_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_delivery_staff
        FOREIGN KEY (Driver_Staff_ID) REFERENCES STAFF (Staff_ID)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_delivery_volunteer
        FOREIGN KEY (Driver_Volunteer_ID) REFERENCES VOLUNTEER (Volunteer_ID)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_one_driver CHECK (
        (Driver_Staff_ID IS NULL) <> (Driver_Volunteer_ID IS NULL)
    )
);

-- Planned extra (not on the RM) for login
-- CREATE TABLE APP_ACCOUNT (
--     Username VARCHAR(50) NOT NULL,
--     Password_Hash VARCHAR(255) NOT NULL,
--     Role ENUM('staff', 'volunteer', 'household', 'donor') NOT NULL,
--     Staff_ID INT NULL,
--     Volunteer_ID INT NULL,
--     Household_ID INT NULL,
--     Donor_ID INT NULL,
--     CONSTRAINT pk_app_account PRIMARY KEY (Username),
--     CONSTRAINT fk_account_staff FOREIGN KEY (Staff_ID) REFERENCES STAFF (Staff_ID),
--     CONSTRAINT fk_account_volunteer FOREIGN KEY (Volunteer_ID) REFERENCES VOLUNTEER (Volunteer_ID),
--     CONSTRAINT fk_account_household FOREIGN KEY (Household_ID) REFERENCES HOUSEHOLD (Household_ID),
--     CONSTRAINT fk_account_donor FOREIGN KEY (Donor_ID) REFERENCES DONOR (Donor_ID)
-- );
