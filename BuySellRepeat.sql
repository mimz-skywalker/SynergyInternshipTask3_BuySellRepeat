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



--new table to save violations
CREATE TABLE Violation(
Violation_ID number(10) NOT NULL,
Retailer_EIK varchar(100) NOT NULL,
Retailer_Name varchar(50) NOT NULL,
CONSTRAINT Violation_PK PRIMARY KEY (Violation_ID),
CONSTRAINT Violation_FK FOREIGN KEY (Retailer_EIK) REFERENCES Retailer(Retailer_EIK)
);




--trigger to register new retailers
CREATE OR REPLACE TRIGGER Regsiter_Retailers
BEFORE INSERT ON Retailer
FOR EACH ROW 
DECLARE 
    old_type varchar(25);
    new_id number := NEW.Retailer_Id;
    new_type varchar(25) := NEW.Retailer_Type;
    new_name varchar(50) := NEW.Retailer_Name;
    new_eik varchar(100) := NEW.Retailer_EIK;
    new_owner varchar(50) := NEW.Retail_Owner;
    check_type varchar(25);
BEGIN
    IF (new_type = 'Individual')
    THEN
    {
        
        old_type :=    (SELECT Retailer_Type FROM Retailer 
                       WHERE Retailer_EIK = new_eik);
                      
        check_type := (SELECT Retailer_Type FROM Retailer 
                      WHERE Retailer_EIK = new_eik AND new_type = 'Legal');
        IF(old_type = 'Agriculturalist') 
        THEN
        {
            UPDATE Retailer SET Reitailer_Type = 'AgriculturalistIndividual' WHERE Retailer_EIK = old_type
        }
        END IF;
        IF(check_type IS NOT NULL) 
        THEN
        {
            INSERT INTO Violation VALUES (new_id, new_eik, new_name);
        }
        END IF;
        
    }
    ELSIF (NEW.Retailer_Type = 'Legal') 
    THEN
    {
        old_type = (SELECT * FROM Suspicious
                     WHERE Retailer_EIK = NEW.Retailer_EIK);
        IF(old_type IS NOT NULL) 
        THEN
        {
            INSERT INTO MaliciuosRetailer VALUES (new_id, new_type, new_name, new_eik, new_owner);
        }
        
        END IF;
        
    }
    END IF;
END;

INSERT INTO Retailer VALUES (6, 'Individual', 'Poli Ivanova', '32974943', 'Ivan')
    
    
    
    
    
    
    
    
    
    