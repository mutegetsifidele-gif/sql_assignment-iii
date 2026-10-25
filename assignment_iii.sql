-- ASSIGNMENT III: SQL TABLE MANIPULATION
-- Student ID: 202510585
-- DBMS: PostgreSQL

-- =====================================================
-- SECTION 1: DATABASE CREATION
-- =====================================================
CREATE DATABASE fidele_202510787_pharmacy_system;

-- =====================================================
-- SECTION 2: TABLE CREATION AND CONSTRAINTS
-- =====================================================
-- Parent table
CREATE TABLE suppliers (
    supplier_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    phone         VARCHAR(15) UNIQUE,
    city          VARCHAR(50)
);

-- Child of suppliers
CREATE TABLE medicines (
    medicine_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL,
    unit_price    NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    stock_qty     INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    expiry_date   DATE,
    supplier_id   INT NOT NULL,
    CONSTRAINT fk_medicines_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
);

-- Child of medicines
CREATE TABLE sales (
    sale_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    medicine_id   INT NOT NULL,
    quantity      INT NOT NULL CHECK (quantity > 0),
    sale_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    customer_name VARCHAR(100),
    CONSTRAINT fk_sales_medicine FOREIGN KEY (medicine_id) REFERENCES medicines (medicine_id)
);

-- =====================================================
-- SECTION 3: INITIAL DATA INSERTION (parents first, no manual PKs)
-- =====================================================
INSERT INTO suppliers (supplier_name, phone, city) VALUES
('Kigali Pharma Ltd',         '0788111111', 'Kigali'),
('Huye Medical Supplies',     '0788222222', 'Huye'),
('Musanze Health Distributors','0788333333', 'Musanze'),
('Rubavu Pharma Depot',       '0788444444', 'Rubavu'),
('Rwanda Medico Group',       '0788555555', 'Kigali');

INSERT INTO medicines (medicine_name, unit_price, stock_qty, expiry_date, supplier_id) VALUES
('Paracetamol 500mg',  300.00, 200, '2028-03-01', 1),
('Amoxicillin 500mg', 1500.00,  40, '2027-01-15', 2),
('Ibuprofen 400mg',    500.00, 120, '2027-12-31', 1),
('ORS Sachet',         250.00,  25, '2026-12-20', 3),
('Vitamin C 1000mg',   800.00,  90, '2028-06-30', 2),
('Cough Syrup',       2500.00,  15, '2027-01-10', 5);

INSERT INTO sales (medicine_id, quantity, sale_date, customer_name) VALUES
(1, 10, '2026-10-01', 'Uwase Aline'),
(2,  3, '2026-10-03', 'Kalisa Jean'),
(1,  5, '2026-10-05', 'Mukamana Grace'),
(3,  4, '2026-10-07', 'Habimana Eric'),
(4, 12, '2026-10-10', 'Uwase Aline'),
(2,  2, '2026-10-12', 'Niyonzima Paul');

-- Verification: row counts and generated keys
SELECT 'suppliers' AS table_name, COUNT(*) AS rows FROM suppliers
UNION ALL SELECT 'medicines', COUNT(*) FROM medicines
UNION ALL SELECT 'sales', COUNT(*) FROM sales;
SELECT * FROM suppliers;
SELECT * FROM medicines;
SELECT * FROM sales;
-- =====================================================
-- SECTION 4: SELECT TASKS
-- =====================================================
-- Q1.1 Basic retrieval: medicine names and prices
SELECT medicine_name, unit_price FROM medicines;

-- Q1.2 Conditional retrieval: low-stock medicines (stock below 50)
SELECT medicine_name, stock_qty FROM medicines WHERE stock_qty < 50;

-- Q1.3 Sorted retrieval: medicines from most to least expensive
SELECT medicine_name, unit_price FROM medicines ORDER BY unit_price DESC;

-- =====================================================
-- SECTION 5: JOIN TASKS
-- =====================================================
-- Q2.1 INNER JOIN: each medicine with its supplier (only matches)
SELECT m.medicine_name, s.supplier_name, s.city
FROM medicines m
INNER JOIN suppliers s ON m.supplier_id = s.supplier_id;

-- Q2.2 LEFT JOIN: all medicines, with sales where available (NULL = never sold)
SELECT m.medicine_name, sa.sale_id, sa.quantity
FROM medicines m
LEFT JOIN sales sa ON m.medicine_id = sa.medicine_id
ORDER BY m.medicine_id;

-- Q2.3 Multi-table JOIN: sales report with medicine, supplier and total value
SELECT sa.sale_id, sa.sale_date, sa.customer_name, m.medicine_name, s.supplier_name,
       sa.quantity, (sa.quantity * m.unit_price) AS total_amount
FROM sales sa
JOIN medicines m ON sa.medicine_id = m.medicine_id
JOIN suppliers s ON m.supplier_id = s.supplier_id
ORDER BY sa.sale_id;

-- =====================================================
-- SECTION 6: UPDATE TASKS AND VERIFICATION
-- =====================================================
-- Q3.1 Update one record: change Paracetamol price to 350
SELECT medicine_id, medicine_name, unit_price FROM medicines WHERE medicine_name = 'Paracetamol 500mg';
UPDATE medicines SET unit_price = 350.00 WHERE medicine_name = 'Paracetamol 500mg';
SELECT medicine_id, medicine_name, unit_price FROM medicines WHERE medicine_name = 'Paracetamol 500mg';

-- Q3.2 Update multiple records: restock +50 for all medicines of supplier 2
SELECT medicine_id, medicine_name, stock_qty FROM medicines WHERE supplier_id = 2;
UPDATE medicines SET stock_qty = stock_qty + 50 WHERE supplier_id = 2;
SELECT medicine_id, medicine_name, stock_qty FROM medicines WHERE supplier_id = 2;

-- Q3.3 Conditional update: 10% discount on in-stock medicines expiring by 2027-01-31
SELECT medicine_name, unit_price, expiry_date FROM medicines WHERE expiry_date <= '2027-01-31' AND stock_qty > 0;
UPDATE medicines SET unit_price = ROUND(unit_price * 0.90, 2)
WHERE expiry_date <= '2027-01-31' AND stock_qty > 0;
SELECT medicine_name, unit_price, expiry_date FROM medicines WHERE expiry_date <= '2027-01-31' AND stock_qty > 0;
-- =====================================================
-- SECTION 7: ALTER TABLE TASKS AND VERIFICATION
-- =====================================================
-- Q4.1 Rename column: sales.customer_name -> buyer_name
ALTER TABLE sales RENAME COLUMN customer_name TO buyer_name;
SELECT column_name FROM information_schema.columns WHERE table_name = 'sales' ORDER BY ordinal_position;
SELECT sale_id, buyer_name FROM sales;

-- Q4.2 Change data type: suppliers.phone VARCHAR(15) -> VARCHAR(20)
ALTER TABLE suppliers ALTER COLUMN phone TYPE VARCHAR(20);
SELECT column_name, data_type, character_maximum_length FROM information_schema.columns
WHERE table_name = 'suppliers' AND column_name = 'phone';
SELECT supplier_id, phone FROM suppliers;

-- Q4.3 Add column: medicines.manufacturer (useful product detail)
ALTER TABLE medicines ADD COLUMN manufacturer VARCHAR(100) DEFAULT 'Unknown';
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'medicines' ORDER BY ordinal_position;
SELECT medicine_id, medicine_name, manufacturer FROM medicines;

-- =====================================================
-- SECTION 8: ADDITIONAL INSERT TASKS AND VERIFICATION
-- =====================================================
-- Q5.1 Insert a single record
INSERT INTO medicines (medicine_name, unit_price, stock_qty, expiry_date, supplier_id, manufacturer)
VALUES ('Aspirin 100mg', 200.00, 80, '2028-02-28', 4, 'Generic Pharma');
SELECT * FROM medicines WHERE medicine_name = 'Aspirin 100mg';

-- Q5.2 Insert multiple records (two new suppliers)
INSERT INTO suppliers (supplier_name, phone, city) VALUES
('Nyagatare Health Store', '0788666666', 'Nyagatare'),
('Rusizi Medical Centre',  '0788777777', 'Rusizi');
SELECT * FROM suppliers ORDER BY supplier_id;

-- Q5.3 Insert a related record (child row with a valid foreign key)
INSERT INTO sales (medicine_id, quantity, sale_date, buyer_name)
VALUES ((SELECT medicine_id FROM medicines WHERE medicine_name = 'Aspirin 100mg'), 6, '2026-10-24', 'Ishimwe Claire');
SELECT sa.sale_id, m.medicine_name, sa.quantity, sa.buyer_name
FROM sales sa JOIN medicines m ON sa.medicine_id = m.medicine_id
WHERE m.medicine_name = 'Aspirin 100mg';
