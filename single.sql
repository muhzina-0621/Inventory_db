create database inventory_db;
 use inventory_db;
 
CREATE TABLE Categories (
  category_id   INT          NOT NULL,
  category_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (category_id)
);

CREATE TABLE Suppliers (
  supplier_id   INT          NOT NULL,
  supplier_name VARCHAR(255) NOT NULL,
  contact_email VARCHAR(320),
  PRIMARY KEY (supplier_id)
);

CREATE TABLE Products (
  product_id   INT          NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  category_id  INT,
  supplier_id  INT,
  price        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (product_id),
  INDEX idx_products_category (category_id),
  INDEX idx_products_supplier (supplier_id),
  CONSTRAINT fk_products_category FOREIGN KEY (category_id)
    REFERENCES Categories(category_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id)
    REFERENCES Suppliers(supplier_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ;

CREATE TABLE Inventory (
  inventory_id INT       NOT NULL AUTO_INCREMENT,
  product_id   INT       NOT NULL,
  quantity     INT       NOT NULL DEFAULT 0,
  last_updated DATE,
  PRIMARY KEY (inventory_id),
  INDEX idx_inventory_product (product_id),
  CONSTRAINT fk_inventory_product FOREIGN KEY (product_id)
    REFERENCES Products(product_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Orders (
  order_id         INT          NOT NULL AUTO_INCREMENT,
  product_id       INT          NOT NULL,
  order_date       DATE         NOT NULL,
  quantity_ordered INT          NOT NULL,
  total_price      DECIMAL(10,2) NOT NULL, -- could also be computed as quantity_ordered * unit_price
  PRIMARY KEY (order_id),
  INDEX idx_orders_product (product_id),
  CONSTRAINT fk_orders_product FOREIGN KEY (product_id)
    REFERENCES Products(product_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO Categories (category_id, category_name) VALUES
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Books');
INSERT INTO Suppliers (supplier_id, supplier_name, contact_email) VALUES
(1, 'TechWorld Ltd', 'contact@techworld.com'),
(2, 'FashionHub', 'sales@fashionhub.com'),
(3, 'BookBarn', 'info@bookbarn.com');

INSERT INTO Products (product_id, product_name, category_id, supplier_id, price) VALUES
(101, 'Smartphone', 1, 1, 699.99),
(102, 'Laptop', 1, 1, 1200.00),
(103, 'T-Shirt', 2, 2, 19.99);

INSERT INTO Inventory (product_id, quantity, last_updated) VALUES
(101, 50, '2025-09-01'),
(102, 20, '2025-09-02');
INSERT INTO Orders (product_id, order_date, quantity_ordered, total_price) VALUES
(101, '2025-09-01', 2, 1399.98),  
(101, '2025-09-02', 1, 699.99);
#Task 1
SELECT p.product_id,
       p.product_name,
       c.category_id,
       c.category_name
FROM Products p
INNER JOIN Categories c
  ON p.category_id = c.category_id;

#Task 2
SELECT p.product_id,
       p.product_name,
       p.price,
       s.supplier_id,
       s.supplier_name
FROM Products p
LEFT JOIN Suppliers s
  ON p.supplier_id = s.supplier_id;

#Task 3
SELECT s.supplier_id,
       s.supplier_name,
       p.product_id,
       p.product_name,
       p.price
FROM Products p
RIGHT JOIN Suppliers s
  ON p.supplier_id = s.supplier_id
ORDER BY s.supplier_id, p.product_id;


#Task 4
SELECT p.product_id,
       p.product_name,
       s.supplier_id,
       s.supplier_name
FROM Products p
LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id

UNION

SELECT p.product_id,
       p.product_name,
       s.supplier_id,
       s.supplier_name
FROM Products p
RIGHT JOIN Suppliers s ON p.supplier_id = s.supplier_id;


#Task 5

SELECT p.product_id,
       p.product_name,
       s.supplier_name,
       i.quantity,
       i.last_updated
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id
WHERE i.quantity > 0;


SELECT p.product_id,
       p.product_name,
       s.supplier_name,
       SUM(i.quantity) AS total_quantity_in_stock
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id
GROUP BY p.product_id, p.product_name, s.supplier_name
HAVING SUM(i.quantity) > 0;

#Task 6
SELECT p.product_id,
       p.product_name,
       SUM(o.quantity_ordered) AS total_quantity_ordered,
       SUM(o.total_price)       AS total_revenue
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

#Task 7
SELECT o.order_id,
       o.order_date,
       p.product_id,
       p.product_name,
       c.category_id,
       c.category_name,
       s.supplier_id,
       s.supplier_name,
       o.quantity_ordered,
       o.total_price
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
LEFT JOIN Categories c ON p.category_id = c.category_id
LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id
ORDER BY o.order_date, o.order_id;

#Task 8
SELECT p.product_id,
       p.product_name,
       s.supplier_name,
       i.quantity
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id
WHERE i.quantity < 10;


SELECT p.product_id,
       p.product_name,
       s.supplier_name,
       SUM(i.quantity) AS total_quantity
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id
GROUP BY p.product_id, p.product_name, s.supplier_name
HAVING SUM(i.quantity) < 10;

#Task 9:
SELECT s.supplier_id,
       s.supplier_name,
       COUNT(DISTINCT p.category_id) AS distinct_category_count
FROM Suppliers s
JOIN Products p ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.supplier_name
HAVING COUNT(DISTINCT p.category_id) > 1;

#9b

SELECT p.product_id,
       p.product_name
FROM Products p
WHERE NOT EXISTS (
  SELECT 1 FROM Orders o WHERE o.product_id = p.product_id
);

#9c
SELECT c.category_id,
       c.category_name,
       SUM(o.total_price) AS total_sales
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_sales DESC
LIMIT 1;
