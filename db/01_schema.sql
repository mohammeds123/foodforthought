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

-- CREATE TABLE statements go below this line.

CREATE TABLE DONOR (
    Donor_ID INT NOT NULL AUTO_INCREMENT,
    Donor_Name VARCHAR(100),
    Donor_Type VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(15),



);

CREATE TABLE DONATION (
    Donation_ID INT PRIMARY KEY AUTO_INCREMENT,
    Date_Received DATE,
    Donation_Type VARCHAR(50),
    Fund_Amount DECIMAL(10, 2),
    Donor_ID INT,
    FOREIGN KEY (Donor_ID) REFERENCES DONOR(Donor_ID) ON UPDATE CASCADE ON DELETE SET NULL
)