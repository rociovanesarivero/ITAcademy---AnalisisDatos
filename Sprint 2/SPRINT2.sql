
SELECT distinct country
FROM company 
JOIN transaction ON company.id=transaction.company_id;

SELECT count(DISTINCT company.country)
FROM company 
JOIN transaction ON company.id=transaction.company_id;

SELECT company.company_name, AVG (transaction.amount) AS company_sales
FROM company
JOIN transaction on company_id=transaction.company_id
GROUP BY company_name
ORDER BY company_sales DESC
LIMIT 1;


SELECT * 
FROM transaction
WHERE company_id IN (
	select id from company where country = "Germany"
    );


SELECT company_name 
FROM company  
WHERE id IN (  
    SELECT company_id FROM transaction  
    WHERE amount > (SELECT AVG(amount) FROM transaction)  
    );
    
SELECT company_name 
FROM company
WHERE id NOT IN (
SELECT DISTINCT company_id FROM transaction
);


SELECT DATE(timestamp) AS data, 
SUM(amount) AS total_vendes  
FROM transaction  
GROUP BY data  
ORDER BY total_vendes DESC  
LIMIT 5;

SELECT company.country, 
AVG (transaction.amount) AS media_ventas
FROM transaction
JOIN company ON transaction.company_id=company.id
GROUP BY country
ORDER BY media_ventas DESC;


SELECT * 
FROM transaction
JOIN company ON transaction.company_id=company.id
WHERE company.country = (
select country from company where company_name = 'Non Institute')
-- and company_name != 'Non Institute'
;

SELECT * 
FROM transaction
WHERE transaction.company_id IN (
	SELECT id 
    FROM company 
    WHERE company.country = (
		SELECT country FROM company WHERE company_name = 'Non Institute')
    -- and company_name != 'Non Institute'
);

SELECT company.company_name, 
company.phone,
 company.country,
 company.email,
 company.website,
DATE(transaction.timestamp) AS fecha , transaction.amount
FROM transaction
JOIN company ON transaction.company_id=company.id
WHERE transaction.amount BETWEEN 100 AND 200
AND DATE (transaction.timestamp) IN ('2021-04-29', '2021-07-20','2022-03-13')
ORDER BY transaction.amount DESC;

-- SELECT
-- 	company_name,
--     cant_transactions,
-- 	IF (TransactionsPerComp.cant_transactions > 4, 'Si', 'No') as MoreThanFour
-- FROM
-- 	(SELECT
-- 		company_name, 
-- 		count(transaction.id) AS cant_transactions
-- 	FROM transaction 
-- 	JOIN company 
-- 		ON transaction.company_id=company.id
-- 	GROUP BY company_name) AS TransactionsPerComp;
    
SELECT company.company_name,  
       COUNT(transaction.id) AS num_transaccions,  
       CASE  
           WHEN COUNT(transaction.id) > 4 THEN 'Més de 4 transaccions'  
           ELSE '4 transaccions o menys'  
       END AS classificacio  
FROM company  
LEFT JOIN transaction ON company.id = transaction.company_id  
GROUP BY company.company_name  
ORDER BY num_transaccions DESC;
    