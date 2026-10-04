-- ============================================================
-- E-COMMERCE DATA MANAGEMENT SYSTEM
-- MYSQL 8.0
-- PART 1 OF 2
-- ============================================================

-- ============================================================
-- 1. CREATE DATABASE
-- ============================================================

DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- ============================================================
-- 2. CREATE TABLES
-- ============================================================

-- TABLE 1: CUSTOMER

CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY AUTO_INCREMENT,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50),
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15) UNIQUE,
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    Postal_Code VARCHAR(10),
    Age INT,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (Age IS NULL OR Age >= 13)
);

-- TABLE 2: CATEGORY

CREATE TABLE Category (
    Category_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

-- TABLE 3: SUPPLIER

CREATE TABLE Supplier (
    Supplier_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15),
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50)
);

-- TABLE 4: PRODUCT

CREATE TABLE Product (
    Product_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(150) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL,
    Brand VARCHAR(100),
    Stock_Quantity INT NOT NULL DEFAULT 0,
    Category_ID INT NOT NULL,
    Supplier_ID INT NOT NULL,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CHECK (Price >= 0),
    CHECK (Stock_Quantity >= 0),

    FOREIGN KEY (Category_ID)
        REFERENCES Category(Category_ID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (Supplier_ID)
        REFERENCES Supplier(Supplier_ID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- TABLE 5: ORDERS

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Order_Date DATETIME DEFAULT CURRENT_TIMESTAMP,

    Status ENUM(
        'Pending',
        'Confirmed',
        'Shipped',
        'Delivered',
        'Cancelled'
    ) DEFAULT 'Pending',

    Delivery_Address VARCHAR(255) NOT NULL,
    Total_Amount DECIMAL(12,2) NOT NULL DEFAULT 0,

    CHECK (Total_Amount >= 0),

    FOREIGN KEY (Customer_ID)
        REFERENCES Customer(Customer_ID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- TABLE 6: ORDER ITEM

CREATE TABLE Order_Item (
    OrderItem_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Unit_Price DECIMAL(10,2) NOT NULL,

    Subtotal DECIMAL(12,2)
        GENERATED ALWAYS AS
        (Quantity * Unit_Price) STORED,

    CHECK (Quantity > 0),
    CHECK (Unit_Price >= 0),

    FOREIGN KEY (Order_ID)
        REFERENCES Orders(Order_ID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (Product_ID)
        REFERENCES Product(Product_ID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- TABLE 7: CART

CREATE TABLE Cart (
    Cart_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL UNIQUE,
    Created_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Cart_Total DECIMAL(12,2) NOT NULL DEFAULT 0,

    CHECK (Cart_Total >= 0),

    FOREIGN KEY (Customer_ID)
        REFERENCES Customer(Customer_ID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- TABLE 8: PAYMENT

CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL UNIQUE,

    Method ENUM(
        'UPI',
        'Credit Card',
        'Debit Card',
        'Net Banking',
        'Cash on Delivery'
    ) NOT NULL,

    Status ENUM(
        'Pending',
        'Paid',
        'Failed',
        'Refunded'
    ) DEFAULT 'Pending',

    Transaction_ID VARCHAR(100) UNIQUE,
    Payment_Date DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (Order_ID)
        REFERENCES Orders(Order_ID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- TABLE 9: SHIPMENT

CREATE TABLE Shipment (
    Shipment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL UNIQUE,
    Courier VARCHAR(100),
    Tracking_Number VARCHAR(100) UNIQUE,

    Shipment_Status ENUM(
        'Preparing',
        'Shipped',
        'In Transit',
        'Delivered',
        'Returned'
    ) DEFAULT 'Preparing',

    Shipment_Date DATETIME,
    Delivery_Date DATETIME,

    FOREIGN KEY (Order_ID)
        REFERENCES Orders(Order_ID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- TABLE 10: REVIEW

CREATE TABLE Review (
    Review_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Rating INT NOT NULL,
    Comment TEXT,
    Review_Date DATETIME DEFAULT CURRENT_TIMESTAMP,

    CHECK (Rating BETWEEN 1 AND 5),

    FOREIGN KEY (Customer_ID)
        REFERENCES Customer(Customer_ID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (Product_ID)
        REFERENCES Product(Product_ID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    UNIQUE (Customer_ID, Product_ID)
);

-- ============================================================
-- 3. CREATE INDEXES
-- ============================================================

CREATE INDEX idx_product_category
ON Product(Category_ID);

CREATE INDEX idx_product_supplier
ON Product(Supplier_ID);

CREATE INDEX idx_order_customer
ON Orders(Customer_ID);

CREATE INDEX idx_order_date
ON Orders(Order_Date);

CREATE INDEX idx_orderitem_order
ON Order_Item(Order_ID);

CREATE INDEX idx_orderitem_product
ON Order_Item(Product_ID);

CREATE INDEX idx_review_product
ON Review(Product_ID);

-- ============================================================
-- 4. INSERT CUSTOMER DATA
-- ============================================================

INSERT INTO Customer
(First_Name, Last_Name, Email, Phone, Address, City, State, Postal_Code, Age)
VALUES
('Rahul','Sharma','rahul@example.com','9876543210','12 MG Road','Kakinada','Andhra Pradesh','533001',20),
('Ananya','Reddy','ananya@example.com','9876543211','25 Main Road','Rajahmundry','Andhra Pradesh','533101',21),
('Arjun','Kumar','arjun@example.com','9876543212','18 College Road','Vijayawada','Andhra Pradesh','520001',22),
('Priya','Sai','priya@example.com','9876543213','44 Market Road','Visakhapatnam','Andhra Pradesh','530001',20),
('Kiran','Rao','kiran@example.com','9876543214','8 Beach Road','Visakhapatnam','Andhra Pradesh','530002',23);

-- ============================================================
-- 5. INSERT CATEGORY DATA
-- ============================================================

INSERT INTO Category (Name, Description)
VALUES
('Electronics','Electronic devices and accessories'),
('Fashion','Clothing and fashion products'),
('Books','Books and educational materials'),
('Home Appliances','Appliances for home use'),
('Sports','Sports equipment and accessories');

-- ============================================================
-- 6. INSERT SUPPLIER DATA
-- ============================================================

INSERT INTO Supplier
(Name, Email, Phone, Address, City, State)
VALUES
('ABC Supplies','abc@supplies.com','9000000001','Industrial Area','Kakinada','Andhra Pradesh'),
('Tech World Suppliers','tech@suppliers.com','9000000002','Tech Park','Hyderabad','Telangana'),
('Fashion Hub','fashion@hub.com','9000000003','Market Street','Bengaluru','Karnataka'),
('Book House','books@house.com','9000000004','College Road','Vijayawada','Andhra Pradesh'),
('Sports Zone','sports@zone.com','9000000005','Stadium Road','Chennai','Tamil Nadu');

-- ============================================================
-- 7. INSERT PRODUCT DATA
-- ============================================================

INSERT INTO Product
(Name, Description, Price, Brand, Stock_Quantity, Category_ID, Supplier_ID)
VALUES
('Wireless Mouse','2.4GHz wireless mouse',799,'Logitech',50,1,2),
('Mechanical Keyboard','RGB mechanical keyboard',2499,'Redragon',30,1,2),
('USB-C Charger','Fast charging USB-C adapter',999,'Samsung',40,1,2),
('Casual Shirt','Cotton casual shirt',899,'Roadster',60,2,3),
('Programming in C++','C++ programming textbook',650,'Tech Books',25,3,4),
('Cricket Bat','English willow cricket bat',3499,'SS',15,5,5),
('Mixer Grinder','750W kitchen mixer grinder',3299,'Philips',20,4,1),
('Sports Shoes','Lightweight running shoes',1899,'Adidas',35,5,5);

-- ============================================================
-- 8. INSERT ORDER DATA
-- ============================================================

INSERT INTO Orders
(Customer_ID, Status, Delivery_Address, Total_Amount)
VALUES
(1,'Confirmed','12 MG Road, Kakinada',3298),
(2,'Shipped','25 Main Road, Rajahmundry',3499),
(3,'Delivered','18 College Road, Vijayawada',1549),
(4,'Pending','44 Market Road, Visakhapatnam',1899);

-- ============================================================
-- 9. INSERT ORDER ITEM DATA
-- ============================================================

INSERT INTO Order_Item
(Order_ID, Product_ID, Quantity, Unit_Price)
VALUES
(1,1,1,799),
(1,2,1,2499),
(2,6,1,3499),
(3,1,1,799),
(3,5,1,650),
(4,8,1,1899);

-- ============================================================
-- 10. INSERT CART DATA
-- ============================================================

INSERT INTO Cart (Customer_ID, Cart_Total)
VALUES
(1,0),
(2,0),
(3,0),
(4,0),
(5,0);

-- ============================================================
-- 11. INSERT PAYMENT DATA
-- ============================================================

INSERT INTO Payment
(Order_ID, Method, Status, Transaction_ID)
VALUES
(1,'UPI','Paid','TXN10001'),
(2,'Credit Card','Paid','TXN10002'),
(3,'Debit Card','Paid','TXN10003'),
(4,'Cash on Delivery','Pending',NULL);

-- ============================================================
-- 12. INSERT SHIPMENT DATA
-- ============================================================

INSERT INTO Shipment
(Order_ID, Courier, Tracking_Number, Shipment_Status,
 Shipment_Date, Delivery_Date)
VALUES
(1,'BlueDart','BD10001','In Transit',NOW(),NULL),
(2,'DTDC','DT10002','Shipped',NOW(),NULL),
(3,'Delhivery','DL10003','Delivered',
 DATE_SUB(NOW(),INTERVAL 4 DAY),
 DATE_SUB(NOW(),INTERVAL 1 DAY));

-- ============================================================
-- 13. INSERT REVIEW DATA
-- ============================================================

INSERT INTO Review
(Customer_ID, Product_ID, Rating, Comment)
VALUES
(1,1,5,'Good quality and smooth performance.'),
(2,6,4,'Good bat for practice.'),
(3,5,5,'Useful book for learning C++.'),
(4,8,4,'Comfortable for running.');

-- ============================================================
-- 14. BASIC SELECT OPERATIONS
-- ============================================================

SELECT * FROM Customer;
SELECT * FROM Product;
SELECT * FROM Category;
SELECT * FROM Supplier;
SELECT * FROM Orders;
SELECT * FROM Payment;
SELECT * FROM Shipment;
SELECT * FROM Review;

-- ============================================================
-- 15. WHERE CONDITION
-- ============================================================

SELECT *
FROM Product
WHERE Price > 1000;

-- ============================================================
-- 16. ORDER BY
-- ============================================================

SELECT Product_ID, Name, Price
FROM Product
ORDER BY Price DESC;

-- ============================================================
-- 17. LIKE
-- ============================================================

SELECT *
FROM Product
WHERE Name LIKE '%Mouse%';

-- ============================================================
-- 18. BETWEEN
-- ============================================================

SELECT *
FROM Product
WHERE Stock_Quantity BETWEEN 20 AND 50;

-- ============================================================
-- 19. IN
-- ============================================================

SELECT *
FROM Category
WHERE Category_ID IN (1,3,5);

-- ============================================================
-- 20. CRUD OPERATIONS
-- ============================================================

-- CREATE

INSERT INTO Customer
(First_Name, Last_Name, Email, Phone,
 Address, City, State, Postal_Code, Age)
VALUES
('Vikram','Reddy','vikram@example.com','9876543299',
 '10 New Street','Kakinada','Andhra Pradesh','533002',21);

-- READ

SELECT *
FROM Customer
WHERE Email = 'vikram@example.com';

-- UPDATE

UPDATE Customer
SET Phone = '9999999999',
    Address = '20 Updated Street'
WHERE Email = 'vikram@example.com';

-- READ AFTER UPDATE

SELECT *
FROM Customer
WHERE Email = 'vikram@example.com';

-- DELETE

DELETE FROM Customer
WHERE Email = 'vikram@example.com';

-- ============================================================
-- 21. UPDATE OPERATIONS
-- ============================================================

UPDATE Product
SET Price = Price + 100
WHERE Product_ID = 1;

UPDATE Product
SET Stock_Quantity = Stock_Quantity + 10
WHERE Product_ID = 1;

UPDATE Orders
SET Status = 'Shipped'
WHERE Order_ID = 1;

UPDATE Payment
SET Status = 'Paid'
WHERE Payment_ID = 4;

-- ============================================================
-- 22. DELETE OPERATION
-- ============================================================

DELETE FROM Review
WHERE Review_ID = 4;

-- ============================================================
-- 23. INNER JOIN
-- ============================================================

SELECT
    o.Order_ID,
    CONCAT(c.First_Name,' ',c.Last_Name) AS Customer_Name,
    o.Order_Date,
    o.Status,
    o.Total_Amount
FROM Orders o
INNER JOIN Customer c
ON o.Customer_ID = c.Customer_ID;

-- ============================================================
-- 24. PRODUCT + CATEGORY + SUPPLIER JOIN
-- ============================================================

SELECT
    p.Product_ID,
    p.Name AS Product_Name,
    p.Price,
    c.Name AS Category,
    s.Name AS Supplier
FROM Product p
INNER JOIN Category c
ON p.Category_ID = c.Category_ID
INNER JOIN Supplier s
ON p.Supplier_ID = s.Supplier_ID;

-- ============================================================
-- 25. ORDER + PRODUCT JOIN
-- ============================================================

SELECT
    o.Order_ID,
    p.Name AS Product_Name,
    oi.Quantity,
    oi.Unit_Price,
    oi.Subtotal
FROM Orders o
INNER JOIN Order_Item oi
ON o.Order_ID = oi.Order_ID
INNER JOIN Product p
ON oi.Product_ID = p.Product_ID;

-- ============================================================
-- END OF PART 1
-- ============================================================


-- ============================================================
-- E-COMMERCE DATA MANAGEMENT SYSTEM
-- MYSQL 8.0
-- PART 2 OF 2
-- ============================================================

USE ecommerce_db;

-- ============================================================
-- 26. REVIEW JOIN
-- ============================================================

SELECT
    CONCAT(c.First_Name,' ',c.Last_Name) AS Customer_Name,
    p.Name AS Product_Name,
    r.Rating,
    r.Comment
FROM Review r
INNER JOIN Customer c
ON r.Customer_ID = c.Customer_ID
INNER JOIN Product p
ON r.Product_ID = p.Product_ID;

-- ============================================================
-- 27. LEFT JOIN
-- ============================================================

SELECT
    c.Customer_ID,
    CONCAT(c.First_Name,' ',c.Last_Name) AS Customer_Name,
    o.Order_ID,
    o.Status
FROM Customer c
LEFT JOIN Orders o
ON c.Customer_ID = o.Customer_ID;

-- ============================================================
-- 28. COUNT
-- ============================================================

SELECT COUNT(*) AS Total_Products
FROM Product;

SELECT COUNT(*) AS Total_Customers
FROM Customer;

-- ============================================================
-- 29. SUM
-- ============================================================

SELECT SUM(Stock_Quantity) AS Total_Stock
FROM Product;

SELECT SUM(Total_Amount) AS Total_Order_Value
FROM Orders
WHERE Status <> 'Cancelled';

-- ============================================================
-- 30. AVG
-- ============================================================

SELECT ROUND(AVG(Price),2) AS Average_Product_Price
FROM Product;

-- ============================================================
-- 31. MIN AND MAX
-- ============================================================

SELECT
    MIN(Price) AS Minimum_Price,
    MAX(Price) AS Maximum_Price
FROM Product;

-- ============================================================
-- 32. GROUP BY
-- ============================================================

SELECT
    c.Name AS Category,
    COUNT(p.Product_ID) AS Product_Count
FROM Category c
LEFT JOIN Product p
ON c.Category_ID = p.Category_ID
GROUP BY c.Category_ID, c.Name
ORDER BY Product_Count DESC;

-- ============================================================
-- 33. GROUP BY + AVG
-- ============================================================

SELECT
    c.Name AS Category,
    ROUND(AVG(p.Price),2) AS Average_Price
FROM Category c
JOIN Product p
ON c.Category_ID = p.Category_ID
GROUP BY c.Category_ID, c.Name;

-- ============================================================
-- 34. HAVING
-- ============================================================

SELECT
    Category_ID,
    COUNT(*) AS Product_Count
FROM Product
GROUP BY Category_ID
HAVING COUNT(*) >= 1;

-- ============================================================
-- 35. CUSTOMER SPENDING + HAVING
-- ============================================================

SELECT
    c.Customer_ID,
    CONCAT(c.First_Name,' ',c.Last_Name) AS Customer_Name,
    SUM(o.Total_Amount) AS Total_Spending
FROM Customer c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.First_Name, c.Last_Name
HAVING SUM(o.Total_Amount) > 2000;

-- ============================================================
-- 36. SUBQUERY
-- ============================================================

SELECT Product_ID, Name, Price
FROM Product
WHERE Price >
(
    SELECT AVG(Price)
    FROM Product
);

-- ============================================================
-- 37. MAXIMUM ORDER SUBQUERY
-- ============================================================

SELECT
    c.Customer_ID,
    CONCAT(c.First_Name,' ',c.Last_Name) AS Customer_Name,
    o.Order_ID,
    o.Total_Amount
FROM Customer c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
WHERE o.Total_Amount =
(
    SELECT MAX(Total_Amount)
    FROM Orders
);

-- ============================================================
-- 38. CREATE VIEW
-- ============================================================

CREATE OR REPLACE VIEW Order_Details_View AS
SELECT
    o.Order_ID,
    CONCAT(c.First_Name,' ',c.Last_Name) AS Customer_Name,
    p.Name AS Product_Name,
    oi.Quantity,
    oi.Unit_Price,
    oi.Subtotal,
    o.Status,
    o.Order_Date
FROM Orders o
JOIN Customer c
ON o.Customer_ID = c.Customer_ID
JOIN Order_Item oi
ON o.Order_ID = oi.Order_ID
JOIN Product p
ON oi.Product_ID = p.Product_ID;

-- Display View

SELECT *
FROM Order_Details_View;

-- ============================================================
-- 39. STORED PROCEDURE
-- ============================================================

DELIMITER //

CREATE PROCEDURE GetCustomerOrders(
    IN p_Customer_ID INT
)
BEGIN
    SELECT
        Order_ID,
        Order_Date,
        Status,
        Total_Amount
    FROM Orders
    WHERE Customer_ID = p_Customer_ID
    ORDER BY Order_Date DESC;
END //

DELIMITER ;

-- Execute Procedure

CALL GetCustomerOrders(1);

-- ============================================================
-- 40. PRODUCT SEARCH PROCEDURE
-- ============================================================

DELIMITER //

CREATE PROCEDURE SearchProducts(
    IN p_Name VARCHAR(150)
)
BEGIN
    SELECT
        Product_ID,
        Name,
        Price,
        Brand,
        Stock_Quantity
    FROM Product
    WHERE Name LIKE CONCAT('%',p_Name,'%');
END //

DELIMITER ;

-- Execute Procedure

CALL SearchProducts('Mouse');

-- ============================================================
-- 41. TRIGGER
-- Automatically updates order total after inserting item
-- ============================================================

DELIMITER //

CREATE TRIGGER trg_after_order_item_insert
AFTER INSERT ON Order_Item
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET Total_Amount =
    (
        SELECT COALESCE(SUM(Subtotal),0)
        FROM Order_Item
        WHERE Order_ID = NEW.Order_ID
    )
    WHERE Order_ID = NEW.Order_ID;
END //

DELIMITER ;

-- ============================================================
-- 42. TRIGGER
-- Automatically updates order total after updating item
-- ============================================================

DELIMITER //

CREATE TRIGGER trg_after_order_item_update
AFTER UPDATE ON Order_Item
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET Total_Amount =
    (
        SELECT COALESCE(SUM(Subtotal),0)
        FROM Order_Item
        WHERE Order_ID = NEW.Order_ID
    )
    WHERE Order_ID = NEW.Order_ID;

    IF OLD.Order_ID <> NEW.Order_ID THEN
        UPDATE Orders
        SET Total_Amount =
        (
            SELECT COALESCE(SUM(Subtotal),0)
            FROM Order_Item
            WHERE Order_ID = OLD.Order_ID
        )
        WHERE Order_ID = OLD.Order_ID;
    END IF;
END //

DELIMITER ;

-- ============================================================
-- 43. TRANSACTION
-- ============================================================

START TRANSACTION;

UPDATE Product
SET Stock_Quantity = Stock_Quantity - 1
WHERE Product_ID = 1
AND Stock_Quantity > 0;

INSERT INTO Orders
(
    Customer_ID,
    Status,
    Delivery_Address,
    Total_Amount
)
VALUES
(
    5,
    'Confirmed',
    '8 Beach Road, Visakhapatnam',
    799
);

COMMIT;

-- If an error occurs before COMMIT:
-- ROLLBACK;

-- ============================================================
-- 44. SHOW DATABASE INFORMATION
-- ============================================================

SHOW TABLES;

SELECT DATABASE();

-- ============================================================
-- 45. DESCRIBE TABLES
-- ============================================================

DESCRIBE Customer;
DESCRIBE Category;
DESCRIBE Supplier;
DESCRIBE Product;
DESCRIBE Orders;
DESCRIBE Order_Item;
DESCRIBE Cart;
DESCRIBE Payment;
DESCRIBE Shipment;
DESCRIBE Review;

-- ============================================================
-- 46. FINAL PRODUCT REPORT
-- ============================================================

SELECT
    p.Product_ID,
    p.Name,
    c.Name AS Category,
    s.Name AS Supplier,
    p.Price,
    p.Stock_Quantity
FROM Product p
JOIN Category c
ON p.Category_ID = c.Category_ID
JOIN Supplier s
ON p.Supplier_ID = s.Supplier_ID
ORDER BY p.Name;

-- ============================================================
-- 47. COMPLETE ORDER REPORT
-- ============================================================

SELECT
    o.Order_ID,
    CONCAT(c.First_Name,' ',c.Last_Name) AS Customer_Name,
    p.Name AS Product_Name,
    oi.Quantity,
    oi.Subtotal,
    o.Status,
    pay.Method AS Payment_Method,
    pay.Status AS Payment_Status
FROM Orders o
JOIN Customer c
ON o.Customer_ID = c.Customer_ID
JOIN Order_Item oi
ON o.Order_ID = oi.Order_ID
JOIN Product p
ON oi.Product_ID = p.Product_ID
LEFT JOIN Payment pay
ON o.Order_ID = pay.Order_ID
ORDER BY o.Order_ID;

-- ============================================================
-- 48. SHIPMENT REPORT
-- ============================================================

SELECT
    o.Order_ID,
    CONCAT(c.First_Name,' ',c.Last_Name) AS Customer_Name,
    s.Courier,
    s.Tracking_Number,
    s.Shipment_Status,
    s.Delivery_Date
FROM Shipment s
JOIN Orders o
ON s.Order_ID = o.Order_ID
JOIN Customer c
ON o.Customer_ID = c.Customer_ID;

-- ============================================================
-- 49. REVIEW REPORT
-- ============================================================

SELECT
    p.Name AS Product,
    ROUND(AVG(r.Rating),2) AS Average_Rating,
    COUNT(r.Review_ID) AS Number_Of_Reviews
FROM Product p
LEFT JOIN Review r
ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Name
ORDER BY Average_Rating DESC;

-- ============================================================
-- 50. LOW STOCK REPORT
-- ============================================================

SELECT
    Product_ID,
    Name,
    Stock_Quantity
FROM Product
WHERE Stock_Quantity < 20
ORDER BY Stock_Quantity ASC;

-- ============================================================
-- END OF E-COMMERCE DATA MANAGEMENT SYSTEM
-- ============================================================