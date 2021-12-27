/* Moduł 8 – Funkcje grupujące i analityczne – Zadania Teoria SQL */

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

/* 1 */
SELECT pmr.region_name, AVG(p.product_quantity)
	FROM products p
	JOIN product_manufactured_region pmr ON p.product_man_region = pmr.id
	GROUP BY pmr.region_name
	ORDER BY 2 DESC;

/* 2 */
SELECT pmr.region_name, STRING_AGG(p.product_name, '; ' ORDER BY p.product_name ASC)
	FROM products p
	JOIN product_manufactured_region pmr ON p.product_man_region = pmr.id
	GROUP BY pmr.region_name;
	
/* 3 */
SELECT pmr.region_name, p.product_name, COUNT(s.sal_prd_id)
	FROM sales s
	JOIN products p ON s.sal_prd_id = p.id
	JOIN product_manufactured_region pmr ON p.product_man_region = pmr.id
	WHERE pmr.region_name = 'EMEA'
	GROUP BY pmr.region_name, p.product_name;
	
/* 4 */
SELECT EXTRACT(YEAR FROM sal_date)||'_'||EXTRACT(MONTH FROM sal_date)  AS year_month_sales, COUNT(sal_prd_id)
	FROM sales
	GROUP BY 1
	ORDER BY 2 DESC;
	
/* 5 */
SELECT EXTRACT(YEAR FROM p.manufactured_date) manufactured_year, 
         p.product_code,
		 pmr.region_name,
         GROUPING(p.product_code,
			 	  EXTRACT(YEAR FROM p.manufactured_date),
				  pmr.region_name
         		  ),
         avg(p.product_quantity)
    FROM products p
	JOIN product_manufactured_region pmr ON p.product_man_region = pmr.id
GROUP BY GROUPING SETS (p.product_code,
						EXTRACT(YEAR FROM p.manufactured_date),
						pmr.region_name,
						()
					    );

/* 6 */
SELECT p.product_name, p.product_code, p.manufactured_date, p.product_man_region, pmr.region_name, SUM(p.product_quantity) OVER (PARTITION BY pmr.region_name) prod_sum
	FROM products p
	JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region; 

/* 7 */
WITH products_ranking AS (
	SELECT prod_quantity_region.*,
       	   dense_rank() OVER (ORDER BY prod_quantity_region.prod_sum DESC) prod_quantity_ranking
		FROM (   
			SELECT p.product_name, p.product_code, p.manufactured_date, p.product_man_region, pmr.region_name, SUM(p.product_quantity) OVER (PARTITION BY pmr.region_name) prod_sum
				FROM products p
				JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region
				) prod_quantity_region
		)
	SELECT * 
		FROM products_ranking 
		WHERE prod_quantity_ranking = 2;