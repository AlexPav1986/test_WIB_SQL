CREATE TABLE Users( 
user_id INT NOT NULL PRIMARY KEY,
age INT
 )

CREATE TABLE Items( 
item_id INT NOT NULL PRIMARY KEY,
price INT NOT NULL
 )

CREATE TABLE Purchases( 
purchases_id INT NOT NULL PRIMARY KEY,
user_id INT NOT NULL,
item_id INT NOT NULL,
date_purchase DATE,
FOREIGN KEY (user_id) REFERENCES Users (user_id),
FOREIGN KEY (item_id) REFERENCES Items (item_id))

INSERT INTO Users
VALUES (1, 18),
       (2, 25),
       (3, 40),
       (4, 55),
       (5, 19),
       (6, 21),
       (7, 21),
       (8, 15),
       (9, 25),
       (10, 65)
       
INSERT INTO Items
VALUES (1, 1800),
       (2, 2500),
       (3, 4000),
       (4, 5500),
       (5, 1900),
       (6, 2100),
       (7, 2100),
       (8, 1500),
       (9, 2500),
       (10, 6500)

INSERT INTO Purchases
VALUES (1, 1, 1,'2020-02-02'),
       (2, 2, 8,'2020-02-10'),
       (3, 3, 10,'2020-02-18'),
       (4, 3, 2,'2020-02-20'),
       (5, 10, 5,'2020-03-02'),
       (6, 9, 5,'2020-03-08'),
       (7, 9, 2,'2020-03-16'),
       (8, 5, 2,'2020-03-16'),
       (9, 7, 4,'2020-03-25'),
       (10, 2, 8,'2020-03-30')
       

       
-- A1 age from 18 to 35
     
WITH combined_table AS (
		SELECT *
		FROM Users u
		RIGHT JOIN Purchases p ON p.user_id = u.user_id
		LEFT JOIN Items i ON i.item_id = p.item_id
		)
SELECT date_purchase,  AVG(price) OVER (PARTITION BY DATE_TRUNC('months', date_purchase)::date) AS price_avg
FROM combined_table
WHERE age >= 18 AND age <=25


-- A2 age from 26 to 35 (result - will be empty)

WITH combined_table AS (
		SELECT *
		FROM Users u
		RIGHT JOIN Purchases p ON p.user_id = u.user_id
		LEFT JOIN Items i ON i.item_id = p.item_id
		)
SELECT date_purchase,  AVG(price) OVER (PARTITION BY DATE_TRUNC('months', date_purchase)::date) AS price_avg
FROM combined_table
WHERE age >= 26 AND age <=35


-- B  month with the biggest revenue
WITH combined_table AS (
		SELECT *
		FROM Users u
		RIGHT JOIN Purchases p ON p.user_id = u.user_id
		LEFT JOIN Items i ON i.item_id = p.item_id
		)
SELECT DATE_TRUNC('months', date_purchase)::date, SUM(price)
FROM combined_table
WHERE age >= 35
GROUP BY DATE_TRUNC('months', date_purchase)::date
ORDER BY SUM(price) DESC 
LIMIT 1


-- C  item with the biggest revenue for the last year

SELECT item_id, SUM(price), DATE_TRUNC('year', date_purchase)::date AS last_year
FROM    (SELECT i.item_id, price, date_purchase
		FROM Users u
		RIGHT JOIN Purchases p ON p.user_id = u.user_id
		LEFT JOIN Items i ON i.item_id = p.item_id
		) a
GROUP BY item_id, date_purchase
-- use only last year
HAVING DATE_TRUNC('year', date_purchase)::date IN 
				-- choose the last year
				(SELECT DATE_TRUNC('year', date_purchase)::date AS last_year
				FROM Users u
				RIGHT JOIN Purchases p ON p.user_id = u.user_id
				LEFT JOIN Items i ON i.item_id = p.item_id
				ORDER BY date_purchase  DESC
				LIMIT 1)
ORDER BY SUM(price) DESC
LIMIT 1


--D  TOP-3 items by revenue and their share in total revenue for any year

SELECT item_id, SUM(price), SUM(price)*100/(SELECT SUM(price) -- devide on total revenue for 2020 year
											FROM    (SELECT i.item_id, price, date_purchase
													FROM Users u
													RIGHT JOIN Purchases p ON p.user_id = u.user_id
													LEFT JOIN Items i ON i.item_id = p.item_id
													) a
											WHERE DATE_TRUNC('year', date_purchase)::date = '2020-01-01') AS perc_per_year
FROM    (SELECT i.item_id, price, date_purchase
		FROM Users u
		RIGHT JOIN Purchases p ON p.user_id = u.user_id
		LEFT JOIN Items i ON i.item_id = p.item_id
		) a
WHERE DATE_TRUNC('year', date_purchase)::date = '2020-01-01'
GROUP BY item_id
ORDER BY perc_per_year DESC
LIMIT 3



