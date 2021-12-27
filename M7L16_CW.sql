/* Moduł 7 – Złączenia - JOINS – Zadania Teoria SQL */

/* Dane ze skryptu */
DROP TABLE IF EXISTS products, sales, product_manufactured_region CASCADE;

CREATE TABLE products (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),	
	manufactured_date DATE,
	product_man_region INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

CREATE TABLE sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

CREATE TABLE product_manufactured_region (
	id SERIAL,
	region_name VARCHAR(25),
	region_code VARCHAR(10),
	established_year INTEGER
);

INSERT INTO product_manufactured_region (region_name, region_code, established_year)
	  VALUES ('EMEA', 'E_EMEA', 2010),
	  		 ('EMEA', 'W_EMEA', 2012),
	  		 ('APAC', NULL, 2019),
	  		 ('North America', NULL, 2012),
	  		 ('Africa', NULL, 2012);

INSERT INTO products (product_name, product_code, product_quantity, manufactured_date, product_man_region)
     SELECT 'Product '||floor(random() * 10 + 1)::int,
            'PRD'||floor(random() * 10 + 1)::int,
            random() * 10 + 1,
            CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date),
            CEIL(random()*(10-5))::int
       FROM generate_series(1, 10) s(i);  
      
INSERT INTO sales (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 10000) s(i);     
	   
	   
/*1 */
SELECT sal_description, sal_date, sal_value, sal_prd_id, product_name, product_code, product_man_region
	FROM sales as s
	JOIN products as p
	ON s.sal_prd_id = p.id
	WHERE p.product_man_region IN (SELECT id
								  FROM product_manufactured_region
								  WHERE region_name = 'EMEA')
	LIMIT 100;
	
/* 2 */
SELECT p.*, pmr.region_name
	FROM products as p
	LEFT JOIN product_manufactured_region as pmr
	ON p.product_man_region = pmr.id
	AND pmr.established_year > 2012;
	
/* 3 */
SELECT p.*, pmr.region_name
	FROM products as p
	LEFT JOIN product_manufactured_region as pmr
	ON p.product_man_region = pmr.id
	WHERE pmr.established_year > 2012;
	
/* Zapytanie 2 przypisało wartości NULL dla region_name ale wyświetliło wszystkie dane z tabeli products, natomiast zapytane 3 nie wyświetliło żadnych wyników ponieważ dla wszystkich wartości zmienna established_year jest mniejsza lub równa 2012 */

/* 4 */
SELECT p.product_name, EXTRACT(YEAR FROM s.sal_date)||'_'||EXTRACT(MONTH FROM s.sal_date) AS sal_year_month
	FROM sales s
	RIGHT JOIN (SELECT p.* 
                FROM products p
                WHERE p.product_quantity > 5) p
	ON s.sal_prd_id = p.id
	ORDER BY 1 DESC;

/* 5 */
INSERT INTO product_manufactured_region (region_name, region_code, established_year)
	  VALUES ('Europe', NULL, NULL);
	  
SELECT p.*, pmr.*
	FROM products p
	FULL JOIN product_manufactured_region pmr
	ON p.product_man_region = pmr.id;
	
SELECT p.*,
       pmr.*
    FROM products p  
    JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region
    UNION 
		SELECT p.*,
               pmr.*
        FROM products p  
  	    LEFT JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region
        WHERE pmr.id IS NULL
        UNION 
			SELECT p.*,
				   pmr.*
				FROM products p  
				RIGHT JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region     
				WHERE p.id IS NULL;
				
/* 6 */
WITH prod_q_5 AS (
	SELECT p.* 
    	FROM products p
        WHERE p.product_quantity > 5
) SELECT p.product_name, EXTRACT(YEAR FROM s.sal_date)||'_'||EXTRACT(MONTH FROM s.sal_date) AS sal_year_month
	FROM sales s
	RIGHT JOIN prod_q_5 p
	ON s.sal_prd_id = p.id
	ORDER BY 1 DESC;
	
/* 7 */
DELETE FROM products p
        WHERE EXISTS (SELECT 1
						FROM products p1 
						JOIN product_manufactured_region pmr 
						ON p.id = p1.id
						AND pmr.id = p1.product_man_region 
						AND pmr.region_code = 'E_EMEA'
						AND pmr.region_name = 'EMEA')
    RETURNING *;