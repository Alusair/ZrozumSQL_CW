/* Moduł 11 – Wydajność – Zadania Teoria SQL */

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
SELECT s.*,
	p.product_code,
	pmr.region_name
	FROM sales s
	JOIN products p 
	ON s.sal_prd_id = p.id
	JOIN product_manufactured_region pmr
	ON p.product_man_region = pmr.id
		WHERE s.sal_date BETWEEN NOW() - (INTERVAL '2 months') AND NOW()
		AND p.product_code = 'PRD8';


/* 2 */
EXPLAIN ANALYZE
SELECT s.*,
	p.product_code,
	pmr.region_name
	FROM sales s
	JOIN products p 
	ON s.sal_prd_id = p.id
	JOIN product_manufactured_region pmr
	ON p.product_man_region = pmr.id
		WHERE s.sal_date BETWEEN NOW() - (INTERVAL '2 months') AND NOW()
		AND p.product_code = 'PRD8';
		
/* Do połączenia tabel został wykorzytany Hash Join -> Hash Join  (cost=30.79..398.79 rows=142 width=154) (actual time=0.059..3.823 rows=2039 loops=1)
pobieranie danych sekwencyjne dla wszystkich tabel   ->  Seq Scan on sales s  (cost=0.00..329.00 rows=10000 width=48) (actual time=0.013..2.992 rows=10000 loops=1)
													->  Seq Scan on product_manufactured_region pmr  (cost=0.00..15.70 rows=570 width=72) (actual time=0.017..0.017 rows=5 loops=1)
													->  Seq Scan on products p  (cost=0.00..12.88 rows=1 width=46) (actual time=0.005..0.006 rows=2 loops=1)
Żadne indeksy nie zostały wykorzystanie, ponieważ nie ma utworzonych na żadnej z tych tabel indeksu 

Planning Time: 0.144 ms
Execution Time: 3.888 ms */

/* 3 */
SELECT COUNT(DISTINCT product_code) as distinct_prod_code,
		COUNT(product_code) as prod_code,
		(COUNT(DISTINCT product_code)::float / COUNT(product_code)) as selectivity
		FROM products;
		
/* distinct_prod_code = 7
prod_code = 10
selectivity = 0.7 */

/* 4 */
CREATE INDEX idx_products_prod_code ON products USING BTREE(product_code);

/* 5 */
DISCARD ALL;

EXPLAIN ANALYZE
SELECT s.*,
	p.product_code,
	pmr.region_name
	FROM sales s
	JOIN products p 
	ON s.sal_prd_id = p.id
	JOIN product_manufactured_region pmr
	ON p.product_man_region = pmr.id
		WHERE s.sal_date BETWEEN NOW() - (INTERVAL '2 months') AND NOW()
		AND p.product_code = 'PRD8';
		
/* Pomimo utworzenia indeksu na kolumnie product_code nie został on wykorzystany w tym zapytaniu */

/* 6 */
CREATE INDEX idx_sales_sal_date ON sales USING BTREE(sal_date);

/* 7 */
DISCARD ALL;

EXPLAIN ANALYZE
SELECT s.*,
	p.product_code,
	pmr.region_name
	FROM sales s
	JOIN products p 
	ON s.sal_prd_id = p.id
	JOIN product_manufactured_region pmr
	ON p.product_man_region = pmr.id
		WHERE s.sal_date BETWEEN NOW() - (INTERVAL '2 months') AND NOW()
		AND p.product_code = 'PRD8';

/* Pomimo utworzenia kolejnego indeksu, żaden z nich nie został użyty w zapytaniu */




/* CZĘŚC POTRZEBNA DO ZADANIA 8 Z TEORII SQL */
DROP TABLE IF EXISTS sales, sales_partitioned CASCADE;

CREATE TABLE sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);
 
 
CREATE TABLE sales_partitioned (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
) PARTITION BY RANGE (sal_date);

CREATE TABLE sales_y2018 PARTITION OF sales_partitioned
    FOR VALUES FROM ('2018-01-01') TO ('2019-01-01');

CREATE TABLE sales_y2019 PARTITION OF sales_partitioned
    FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');
   
CREATE TABLE sales_y2020 PARTITION OF sales_partitioned
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');
	
CREATE TABLE sales_y2021 PARTITION OF sales_partitioned
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');

EXPLAIN ANALYZE
INSERT INTO sales (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 1000000) s(i);     
	   
/* Insert on sales  (cost=0.00..77500.00 rows=1000000 width=100) (actual time=6755.897..6755.899 rows=0 loops=1)
Planning Time: 0.071 ms
Execution Time: 6758.872 ms */ 

EXPLAIN ANALYZE
INSERT INTO sales_partitioned (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 1000000) s(i);
	   
/* Insert on sales_partitioned  (cost=0.00..77500.00 rows=1000000 width=100) (actual time=6477.282..6477.282 rows=0 loops=1)
Planning Time: 0.052 ms
Execution Time: 6480.351 ms */

/* INSERT dla tabeli partycjonowanej odbywa się nieznacznie szybciej niż do zwykłej tabeli */


