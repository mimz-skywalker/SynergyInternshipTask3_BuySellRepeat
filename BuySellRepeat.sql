--created
CREATE TABLE Retailer(
    Retailer_ID NUMBER(15) NOT NULL,
    Retailer_Type VARCHAR(25) NOT NULL,
    Retailer_Name VARCHAR(50) NOT NULL,
    Retailer_EIK VARCHAR(100) UNIQUE NOT NULL,
    Retail_Owner VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT Retailer_PK PRIMARY KEY (Retailer_ID),
    CONSTRAINT Retailer_FK FOREIGN KEY (Retailer_Type) REFERENCES Retailer_Type (Retailer_Type) 
        ON DELETE CASCADE 
)

--created
CREATE TABLE Lot(
    Lot_ID NUMBER(15) NOT NULL,
    Retailer_EIK VARCHAR(100) NOT NULL,
    Balance NUMBER(15) NOT NULL,
    Date_Open DATE NOT NULL,
    CONSTRAINT Lot_PK PRIMARY KEY(Retailer_EIK, Date_Open),
    CONSTRAINT Lot_FK FOREIGN KEY(Retailer_EIK) REFERENCES Retailer (Retailer_EIK )
);

--created 
CREATE TABLE Retailer_Type(
    Type_ID NUMBER(15) NOT NULL,
    Retailer_Type VARCHAR(25) UNIQUE NOT NULL,
    CONSTRAINT Retailer_Type_PK PRIMARY KEY (Type_ID)    
);

--created
CREATE TABLE Inventory(
    Item_ID NUMBER(15) NOT NULL,
    Item_Name VARCHAR(20) NOT NULL,
    Retailer_EIK VARCHAR(100) UNIQUE NOT NULL,
    Quantity_ID VARCHAR(20) NOT NULL,
    Price DECIMAL(15) NOT NULL,
    Quantity NUMBER(10) NOT NULL,
    Update_Date DATE NOT NULL,
    CONSTRAINT Inventory_PK PRIMARY KEY (Item_ID),
    CONSTRAINT Inventory_FK FOREIGN KEY(Retailer_EIK) REFERENCES Retailer (Retailer_EIK)
);

--created
CREATE TABLE MaliciousRetailer(
    Retailer_ID NUMBER(15) NOT NULL,
    Retailer_Type VARCHAR(25) NOT NULL,
    Retailer_Name VARCHAR(50) NOT NULL,
    Retailer_EIK VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT MaliciousRetailer_PK PRIMARY KEY (Retailer_ID),
    CONSTRAINT MaliciousRetailer_FK FOREIGN KEY (Retailer_EIK) REFERENCES Retailer (Retailer_EIK)
);

--created
CREATE TABLE Unsuccessful_Sale(
    Sale_ID NUMBER(15) NOT NULL,
    Retailer_EIK VARCHAR(100) UNIQUE NOT NULL,
    Item_ID NUMBER(15) UNIQUE NOT NULL,
    Quantity NUMBER(10) UNIQUE NOT NULL,
    CONSTRAINT UnsuccessfulSale_PK PRIMARY KEY (Sale_ID),
    CONSTRAINT UnsuccessfulSale_FK1 FOREIGN KEY (Retailer_EIK) REFERENCES Retailer (Retailer_EIK),
    CONSTRAINT UnsuccessfulSale_FK2 FOREIGN KEY (Item_ID) REFERENCES Inventory (Item_ID)
);

--created
CREATE TABLE Successful_Sale(
    Sale_ID NUMBER(15) NOT NULL,
    Retailer_EIK VARCHAR(100) UNIQUE NOT NULL,
    Item_ID NUMBER(15) UNIQUE NOT NULL,
    Quantity NUMBER(10) UNIQUE NOT NULL,
    CONSTRAINT Sale_PK PRIMARY KEY (Sale_ID),
    CONSTRAINT Sale_FK1 FOREIGN KEY (Retailer_EIK) REFERENCES Retailer (Retailer_EIK),
    CONSTRAINT Sale_FK2 FOREIGN KEY (Item_ID) REFERENCES Inventory (Item_ID)
);


--UPDATE TABLE Lot 
--DROP TABLE Lot;


--Creating a table Suspicious 
--created
CREATE TABLE Suspicious(
    Retailer_ID NUMBER(15) NOT NULL,
    Retailer_Type VARCHAR(25) NOT NULL,
    Retailer_Name VARCHAR(50) NOT NULL,
    Retailer_EIK VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT Suspicious_PK PRIMARY KEY (Retailer_ID),
    CONSTRAINT Suspicious_FK FOREIGN KEY (Retailer_EIK) REFERENCES Retailer (Retailer_EIK)

);

--Creating a lot for each new retailer
--ran successfully
DECLARE 
BEGIN 
    FOR I IN (SELECT Retailer_ID, Retailer_EIK FROM Retailer) LOOP
    INSERT INTO Lot (Lot_ID, Retailer_EIK, Date_Open, Balance) 
    VALUES (I.Retailer_ID, I.Retailer_EIK, CURRENT_DATE, 0);
    END LOOP;
END;

DECLARE
BEGIN 
    SELECT * FROM Retailer 
    WHERE Retailer_Type = "Individual"
        
    
    
    
    
    
    
    
    