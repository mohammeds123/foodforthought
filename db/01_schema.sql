-- =============================================================================
-- 01_schema.sql
-- SQL DDL for the FoodForThought database (run against foodforthought).
-- =============================================================================
-- Put CREATE TABLE statements here: one table per relation from the EERD /
-- relational model (19 relations), plus App_Account for logins (not on the EERD).
-- Include PRIMARY KEY, FOREIGN KEY, UNIQUE, and CHECK constraints with each table.
--
-- Example shape only — replace with the real tables when the schema is written:
--
-- CREATE TABLE Example (
--   example_id INT NOT NULL AUTO_INCREMENT,
--   CONSTRAINT pk_example PRIMARY KEY (example_id)
-- );
--
-- Do not put stored procedures, events, or seed INSERTs in this file.
-- =============================================================================

USE foodforthought;

-- CREATE TABLE statements for standalone tables (Tables without Foreign Keys)

CREATE TABLE DONOR (
    Donor_ID INT PRIMARY KEY AUTO_INCREMENT,
    Donor_Name VARCHAR(100),
    Donor_Type VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(15)
);

CREATE TABLE STAFF (
    Staff_ID INT PRIMARY KEY AUTO_INCREMENT,
    Staff_Name VARCHAR(100),
    Position VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(15)
);

CREATE TABLE VOLUNTEER (
    Volunteer_ID INT PRIMARY KEY AUTO_INCREMENT,
    Volunteer_Name VARCHAR(100),
    Start_Date DATE,
    Email VARCHAR(100),
    Phone VARCHAR(15)
);

CREATE TABLE HOUSEHOLD (
    Household_ID INT PRIMARY KEY AUTO_INCREMENT,
    Contact_Name VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100),
    -- Composite Attribute 'Address' split into separate fields: Street, City, and Postal_Code
    Street VARCHAR(255),
    City VARCHAR(100),
    Postal_Code VARCHAR(10),
    Registration_Date DATE,
    Duplicate_Flag BOOLEAN,
    Household_Size INT
);

CREATE TABLE FOOD_ITEM (
    Item_ID INT PRIMARY KEY AUTO_INCREMENT,
    Item_Name VARCHAR(100),
    Food_Category VARCHAR(50),
    Storage_Type VARCHAR(50),
    Low_Stock_Threshold INT
);

CREATE TABLE STORAGE_LOCATION (
    Location_ID INT PRIMARY KEY AUTO_INCREMENT,
    Location_Name VARCHAR(100),
    Storage_Type VARCHAR(50)
);

CREATE TABLE DIETARY_NEED (
    Need_Name VARCHAR(50) PRIMARY KEY,
    Need_Type VARCHAR(50)
);

CREATE TABLE DONATION (
    Donation_ID INT PRIMARY KEY,
    Date_Received DATE,
    Donation_Type VARCHAR(50),
    Fund_Amount DECIMAL(10, 2),
    Donor_ID INT,
    Staff_ID INT,
    FOREIGN KEY (Donor_ID) REFERENCES DONOR(Donor_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Staff_ID) REFERENCES STAFF(Staff_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE REQUIRES (
    Household_ID INT,
    Need_Name VARCHAR(50),
    PRIMARY KEY (Household_ID, Need_Name),
    FOREIGN KEY (Household_ID) REFERENCES HOUSEHOLD(Household_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Need_Name) REFERENCES DIETARY_NEED(Need_Name) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TAGGED_AS (
    Item_ID INT,
    Need_Name VARCHAR(50),
    PRIMARY KEY (Item_ID, Need_Name),
    FOREIGN KEY (Item_ID) REFERENCES FOOD_ITEM(Item_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Need_Name) REFERENCES DIETARY_NEED(Need_Name) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE HAMPER (
    Hamper_ID INT PRIMARY KEY AUTO_INCREMENT,
    Household_ID INT,
    Staff_ID INT,
    Build_Date DATE,
    FOREIGN KEY (Household_ID) REFERENCES HOUSEHOLD(Household_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Staff_ID) REFERENCES STAFF(Staff_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE VOLUNTEER_SKILL (
    Volunteer_ID INT,
    Skill_Name VARCHAR(50),
    PRIMARY KEY (Volunteer_ID, Skill_Name),
    FOREIGN KEY (Volunteer_ID) REFERENCES VOLUNTEER(Volunteer_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE SHIFT (
    Shift_ID INT PRIMARY KEY AUTO_INCREMENT,
    Staff_ID INT,
    Shift_Date DATE,
    Start_Time TIME,
    End_Time TIME,
    Duty VARCHAR(100),
    FOREIGN KEY (Staff_ID) REFERENCES STAFF(Staff_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE SIGN_UP (
    Volunteer_ID INT,
    Shift_ID INT,
    PRIMARY KEY (Volunteer_ID, Shift_ID),
    FOREIGN KEY (Volunteer_ID) REFERENCES VOLUNTEER(Volunteer_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Shift_ID) REFERENCES SHIFT(Shift_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE FULFILLMENT (
    Fullfillment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Hamper_ID INT,
    Status VARCHAR(50),
    Scheduled_Date DATE,
    FOREIGN KEY (Hamper_ID) REFERENCES HAMPER(Hamper_ID) ON UPDATE
);

CREATE TABLE DELIVERY (
    Fulfillment_ID INT PRIMARY KEY,
    Driver_Staff_ID INT,
    Driver_Volunteer_ID INT,
    Departure_Time TIME,
    Arrival_Time TIME,
    FOREIGN KEY (Fulfillment_ID) REFERENCES FULFILLMENT(Fulfillment_ID),
    FOREIGN KEY (Driver_Staff_ID) REFERENCES STAFF(Staff_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Driver_Volunteer_ID) REFERENCES VOLUNTEER(Volunteer_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE INVENTORY_LOT (
    Donation_ID INT,
    Lot_Line_No INT,
    Item_ID INT,
    Location_ID INT,
    Quantity_On_Hand INT,
    Expiry_Date DATE,
    Lot_Status VARCHAR(50),
    PRIMARY KEY (Donation_ID, Lot_Line_No),
    FOREIGN KEY (Donation_ID) REFERENCES DONATION(Donation_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Item_ID) REFERENCES FOOD_ITEM(Item_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Location_ID) REFERENCES STORAGE_LOCATION(Location_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PACKED_FROM (
    Hamper_ID INT,
    Donation_ID INT,
    Lot_Line_No INT,
    Quantity_Taken INT,
    PRIMARY KEY (Hamper_ID, Donation_ID, Lot_Line_No),
    FOREIGN KEY (Hamper_ID) REFERENCES HAMPER(Hamper_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Donation_ID, Lot_Line_No) REFERENCES INVENTORY_LOT(Donation_ID, Lot_Line_No) ON UPDATE CASCADE ON DELETE CASCADE
);

