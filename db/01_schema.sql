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
    Phone VARCHAR(15),
);

CREATE TABLE STAFF (
    Staff_ID INT PRIMARY KEY AUTO_INCREMENT,
    Staff_Name VARCHAR(100),
    Position VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(15),
);

CREATE TABLE VOLUNTEER (
    Volunteer_ID INT PRIMARY KEY AUTO_INCREMENT,
    Volunteer_Name VARCHAR(100),
    Start_Date DATE,
    Email VARCHAR(100),
    Phone VARCHAR(15),
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
    Household_Size INT,
);

CREATE TABLE FOOD_ITEM (
    Item_ID INT PRIMARY KEY AUTO_INCREMENT,
    Item_Name VARCHAR(100),
    Food_Category VARCHAR(50),
    Storage_Type VARCHAR(50),
    Low_Stock_Threshold INT,
);

CREATE TABLE STORAGE_LOCATION (
    Location_ID INT PRIMARY KEY AUTO_INCREMENT,
    Location_Name VARCHAR(100),
    Storage_Type VARCHAR(50),
);

CREATE TABLE DIETARY_NEED (
    Need_Name VARCHAR(50) PRIMARY KEY,
    Need_Type VARCHAR(50),
);

CREATE TABLE DONATION (
    Donation_ID INT PRIMARY KEY AUTO_INCREMENT,
    Date_Received DATE,
    Donation_Type VARCHAR(50),
    Fund_Amount DECIMAL(10, 2),
    Donor_ID INT,
    FOREIGN KEY (Donor_ID) REFERENCES DONOR(Donor_ID) ON UPDATE CASCADE ON DELETE SET NULL
);

