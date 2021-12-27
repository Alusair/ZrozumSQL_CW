/* Moduł 6 Data Query Language – Zadania Teoria SQL */

DROP TABLE IF EXISTS products;

CREATE TABLE products (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),
	manufactured_date DATE,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

INSERT INTO products (product_name, product_code, product_quantity, manufactured_date)
 SELECT 'Product '||floor(random() * 10 + 1)::int,
 'PRD'||floor(random() * 10 + 1)::int,
 random() * 10 + 1,
 CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date)
 FROM generate_series(1, 10) s(i);

DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_qty NUMERIC(10,2),
	sal_product_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

INSERT INTO sales (sal_description, sal_date, sal_value, sal_qty, sal_product_id)
 SELECT left(md5(i::text), 15),
 CAST((NOW() - (random() * (interval '60 days'))) AS DATE),
 random() * 100 + 1,
 floor(random() * 10 + 1)::int,
 floor(random() * 10)::int
 FROM generate_series(1, 10000) s(i);
 
/* 1 */
SELECT DISTINCT manufactured_date FROM products;

/* 2 */
SELECT COUNT(product_code) FROM products;  --wynik: 10
SELECT COUNT(DISTINCT product_code) FROM products;  --wynik: 8

/* 3 */
SELECT product_name, product_code FROM products WHERE product_code IN ('PRD1', 'PRD9');

/* 4 */
SELECT * 
	FROM sales
	WHERE sal_date >= '2021-10-01'
	AND sal_date <= '2021-10-31'
	ORDER BY sal_value DESC, sal_date ASC;
	
/* 5 */
SELECT p.* 
	FROM products p 
	WHERE NOT EXISTS (SELECT 1
 				FROM sales s 
 				WHERE s.sal_product_id = p.id);

/* 6 */
SELECT * 
	FROM products
	WHERE id = ANY(SELECT sal_product_id
 				FROM sales
 				WHERE sal_value > 100);

/* 7 */
DROP TABLE IF EXISTS products_old_warehouse;

CREATE TABLE products_old_warehouse (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),
	manufactured_date DATE,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

INSERT INTO products_old_warehouse (product_name, product_code, product_quantity, manufactured_date)
	SELECT 'Product '||floor(random() * 10 + 2)::int,
	'PRD'||floor(random() * 10 + 2)::int,
	random() * 10 + 2,
	CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date)
	FROM generate_series(1, 10) s(i);
 
 /* 8 */
SELECT product_name
	FROM products_old_warehouse
	UNION
	(SELECT product_name
		FROM products
		LIMIT 5);
		
SELECT product_name
	FROM products_old_warehouse
	UNION ALL
	(SELECT product_name
		FROM products
		LIMIT 5);
		
/* Tak, jest różnica w ilości zwróconych wierszy */

/* 9 */
SELECT product_name
	FROM products_old_warehouse
	EXCEPT
	SELECT product_name
		FROM products;
		
/* 10 */
SELECT *
	FROM sales
	ORDER BY sal_value DESC
	LIMIT 10;
	
/* 11 */
SELECT SUBSTRING('sal_description', 1, 3) AS sub_sal_desc
	FROM sales
	LIMIT 3;

/* 12 */
SELECT sal_description
	FROM sales
	WHERE sal_description LIKE 'c4c%';