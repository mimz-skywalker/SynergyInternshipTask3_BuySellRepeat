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
        SELECT Retailer_Type FROM Retailer 
        INTO old_type 
        WHERE Retailer_EIK = new_eik;
                      
        SELECT Retailer_Type FROM Retailer 
        INTO check_type
        WHERE Retailer_EIK = new_eik AND new_type = 'Legal';
        
        IF(old_type = 'Agriculturalist') 
        THEN
        
            UPDATE Retailer SET Reitailer_Type = 'AgriculturalistIndividual' WHERE Retailer_EIK = old_type;
        
        END IF;
        IF(check_type IS NOT NULL) 
        THEN
        
            INSERT INTO Violation VALUES (new_id, new_eik, new_name);
        
        END IF;
    ELSIF (NEW.Retailer_Type = 'Legal') 
    THEN
    
        SELECT * FROM Suspicious
        INTO old_type
        WHERE Retailer_EIK = NEW.Retailer_EIK;
        IF(old_type IS NOT NULL) 
        THEN
        
            INSERT INTO MaliciuosRetailer VALUES (new_id, new_type, new_name, new_eik, new_owner);
        
        END IF;
    END IF;
END;

INSERT INTO Retailer VALUES (6, 'Individual', 'Poli Ivanova', '32974943', 'Ivan');


--trigger when making sales 
CREATE OR REPLACE TRIGGER Sale
BEFORE INSERT ON Successful_Sale
FOR EACH ROW
DECLARE 
	quantity_needed NUMBER(10) = NEW.Quantity;
	sale_id NUMBER(15) = NEW.Sale_ID;
	eik VARCHAR(100) = NEW.Retailer_EIK;
	item_id NUMBER(15) = NEW.Item_ID;
	quantity_check NUMBER(10);
BEGIN 
	SELECT Quantity 
	FROM Inventory
	INTO quantity_check
	WHERE Quantity.Retailer_EIK = eik;

	IF (quantity_needed > quantity_check)
	THEN	
		INSERT INTO Unsuccessful_Sale VALUES (sale_id, eik, item_id, quantity_needed);
	ELSE
		INSERT INTO Successful_Sale VALUES (sale_id, eik, item_id, quantity_needed);

		UPDATE Inventory 
		SET Quantity = (quantity_check - quantity_needed);
		WHERE Inventory.Retailer_EIK = eik AND Inventory.Item_ID = item_id;
	END IF;
END;

--create table accountancy
CREATE TABLE Accountancy_Table(
	Entry_ID NUMBER(15) NOT NULL,
	Retailer_EIK VARCHAR(100) NOT NULL,
	Sum_Sale NUMBER(10) NOT NULL,
	Tax NUMBER(10) NOT NULL,
	Tax_Date DATE NOT NULL,
	CONSTRAINT Accountancy_PK PRIMARY KEY (Entry_ID),
	CONSTRAINT Accountancy_FK FOREIGN KEY (Retailer_EIK) REFERENCES Retailer(Retailer_EIK)
);

--create table tax free retailers
CREATE TABLE Tax_Free(
	Entry_ID NUMBER(15) NOT NULL,
	Retailer_EIK VARCHAR(100) NOT NULL,
	CONSTRAINT Tax_Free_PK PRIMARY KEY (Entry_ID),
	CONSTRAINT Tax_Free_FK FOREIGN KEY (Retailer_EIK) REFERENCES Retaielr(Retailer_EIK)
);

--accountancy procedure
DECLARE 
	sum_sale NUMBER(10) = 0;
	tax NUMBER(10);
	check_eik VARCHAR(100);
BEGIN
	FOR I IN (SELECT Inv.Retailer_EIK, Inv.Price, S.Quantity, S.Sale_ID, Inv.Update_date, R.Retailer_type
			  FROM Inventory Inv
			  INNER JOIN Successful_Sale S
			  ON Inv.Item_ID = S.Item_ID AND Inv.Retailer_EIK = S.Retailer_EIK
			  INNER JOIN Retailer R
			  ON R.Retailer_EIK = S.Retailer_EIK) LOOP

			  sum_sale = I.Price * I.Quantity
			  
			  IF(I.Retailer_type = 'Individual')
			  THEN
				sum_sale = sum_sale - 2500;
			  END IF;

			  IF (I.Retailer_type = 'Legal')
			  THEN 
				SELECT T.Retailer_EIK FROM Tax_free T INTO check_eik 
				WHERE I.Retailer_EIK = T.Retailer_EIK;

				IF (check_eik IS NOT NULL) 
				THEN
					sum_sale = 0;
				END IF;
			   END IF;

			  IF (sum_sale > 0 AND sum_sale < 5000)
			  THEN 
				INSERT INTO Accountancy_Table VALUES (I.Sale_ID, I.Retailer_EIK, sum_sale, 0, I.Update_date);

			  ELSIF (sum_sale >= 5000 AND sum_sale < 7500)
			  THEN
				INSERT INTO Accountancy_Table VALUES (I.Sale_ID, I.Retailer_EIK, sum_sale, 0.05*sum_sale, I.Update_date);

			  ELSIF (sum_sale >= 7500 AND sum_sale < 10000)
			  THEN 
				INSERT INTO Accountancy_Table VALUES (I.Sale_ID, I.Retailer_EIK, sum_sale, 0.07*sum_sale, I.Update_date);

			  ELSE (sum_sale >= 10000)
			  THEN
				INSERT INTO Accountancy_Table VALUES (I.Sale_ID, I.Retailer_EIK, sum_sale, 0.1*sum_sale, I.Update_date);
			  END IF;
	END LOOP;
END;


CREATE VIEW MontlyReport
	SELECT T.Retailer_EIK, SUM(T.sum_sale) as Sum_Sales, sum(T.tax) as Sum_Taxes, count(S.sale_ID) as Sales_Count 
	FROM Accountancy_Table T
	INNER JOIN Successful_Sale S
	ON T.Retailer_EIK = S.Retailer_EIK;
			  
			


	

    
    
    
    
    
    
    
    
    
    