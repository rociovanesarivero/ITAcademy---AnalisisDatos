
-- Nivell 1
-- Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:

-- CREAMOS LA BASE DE DATOS QUE ALMACENARA NUESTRAS TABLAS
CREATE DATABASE database_operations;
USE database_operations;

-- CREACION TABLA USERS
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(150),
    birth_date VARCHAR(20), --  DATE
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255)
);

-- CREACION TABLA CREDIT_CARDS
CREATE TABLE credit_cards (
    id VARCHAR(20) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(34),
    pan VARCHAR(30),
    pin INT,
    cvv INT,
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(30)
);

-- CREACION TABLA COMPANIES
CREATE TABLE companies (
    company_id VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(150),
    country VARCHAR(100),
    website VARCHAR(255)
);

-- CREACION TABLA TRANSACTIONS
CREATE TABLE transactions (
    id VARCHAR(50) PRIMARY KEY,
    card_id VARCHAR(20),
    business_id VARCHAR(10),
    timestamp TIMESTAMP,
    amount DECIMAL (10,2),
    declined BOOLEAN,
    product_ids VARCHAR(30),
    user_id INT,
    lat VARCHAR(50), 
    longitude VARCHAR(50), 
    FOREIGN KEY (card_id) REFERENCES credit_cards(id),
    FOREIGN KEY (business_id) REFERENCES companies(company_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

 -- CARGA DE LOS CSV A LAS TABLAS CON LOAD FILE
 -- TABLA COMPANIES
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv' 
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ARGAMOS LOS DATOS DE USERS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'  
INTO TABLE users  
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\r\n'  
IGNORE 1 ROWS ;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv'  
INTO TABLE users  
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\r\n'  
IGNORE 1 ROWS ;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'  
INTO TABLE users  
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\r\n'  
IGNORE 1 ROWS ;

-- CARGAMOS DATOS A LA TABLA CREDIT CARDS
LOAD DATA -- LOCAL-- 
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv' 
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- (id, name, surname, phone,email, @birth_date,country,city,postal_code,address)  
-- SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

-- CARGAMOS DATOS A LA TABLA TRANSACTIONS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv' 
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- - Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.

-- CON SUBQUERY
SELECT u.id, u.name
FROM users u
WHERE (SELECT COUNT(*) FROM transactions t WHERE t.user_id = u.id) > 30;

-- CON JOIN
SELECT u.name,u.id, 
COUNT(t.id) AS CantTransactions
FROM users u
JOIN transactions t ON t.user_id=u.id
GROUP BY u.name,u.id
HAVING COUNT(t.id) > 30; 

-- - Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
SELECT cc.iban, c.company_name, round(avg(t.amount),2) AS Media_Amount
FROM credit_cards cc
JOIN transactions t ON cc.id=t.card_id
JOIN companies c ON c.company_id=t.business_id
WHERE c.company_name ="Donec Ltd"
GROUP BY cc.iban;

-- Nivell 2

-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:

-- CREAMOS LA TABLA CARD_STATUS
CREATE TABLE card_status (
	card_id VARCHAR(20) PRIMARY KEY, 
	active_status VARCHAR(20),
	FOREIGN KEY (card_id) REFERENCES credit_cards(id)
);

-- CARGAMOS LOS DATOS A LA TABLA QUE CREAMOS
-- INSERT INTO card_status (card_id, active_status)
-- SELECT 
--     cc.id,
--     CASE 
--         WHEN COALESCE((
--             SELECT SUM(t.declined)
--             FROM transactions t
--             WHERE t.card_id = cc.id 
--             ORDER BY t.timestamp DESC 
--             LIMIT 3
--         ), 0) = 3 THEN 'No Active'
--         ELSE 'Active'
--     END AS active_status
-- FROM credit_cards cc; -- ESTE CODIGO LO HICE PRIMERO Ç

INSERT INTO card_status (card_id, active_status)
SELECT 
    cc.id,
    CASE 
        WHEN COALESCE(a.sum_declined, 0) = 3 THEN 'No Activo'
        ELSE 'Activo'
    END AS active_status
FROM credit_cards cc
LEFT JOIN (
    SELECT 
        card_id,
        SUM(declined) AS sum_declined
    FROM (
        SELECT 
            card_id,
            declined,
            ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS rn
        FROM transactions
    ) AS last_three
    WHERE rn <= 3
    GROUP BY card_id
) AS a ON a.card_id = cc.id;

-- Exercici 1
-- Quantes targetes estan actives?
SELECT COUNT(*) AS ActiveCards
FROM card_status cs
WHERE cs.active_status = 'active';

-- Nivell 3
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
-- tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

-- CREACION TABLA PRODUCTS
CREATE TABLE products (
    id VARCHAR(30) PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL (10,2),
    colour VARCHAR (20),
    weight VARCHAR (20),
    warehouse_id VARCHAR (20)
);

-- CREACION TABLA INTERMEDIA TRANSACTION-PRODUCTS
CREATE TABLE transaction_products (
    transaction_id VARCHAR(50),
    product_id VARCHAR(30),
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- CARGAMOS DATOS A LA TABLA PRODUCTS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv' 
INTO TABLE products
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\n'  
IGNORE 1 ROWS 
(id,product_name,@priceWithCurrency,colour,weight,warehouse_id)
SET price = CAST(REPLACE(@priceWithCurrency,'$','') AS DECIMAL(10,2));


-- INSERTAMOS DATOS A LA TABLA INTERMEDIA TRANSACTION_PRODUCTS
INSERT INTO transaction_products (transaction_id, product_id)
SELECT t.id, p.id
FROM transactions t
JOIN products p ON FIND_IN_SET(p.id, REPLACE (t.product_ids,' ','' )) > 0;

-- Exercici 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT p.product_name, COUNT(tp.product_id) AS total_ventas
FROM transaction_products tp
JOIN products p ON tp.product_id = p.id
GROUP BY p.product_name
ORDER BY total_ventas DESC;
