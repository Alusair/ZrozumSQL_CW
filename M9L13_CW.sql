/* Moduł 9 – Pozostałe Struktury Danych – Zadania Teoria SQL */

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
CREATE OR REPLACE VIEW products_manufactured_in_2020_4 AS
	SELECT s.id,
		   s.sal_description,
		   s.sal_value,
		   s.sal_prd_id,
		   EXTRACT(YEAR FROM s.sal_date) || '-' || EXTRACT(QUARTER FROM s.sal_date) as sal_y_q
     FROM sales s
	 JOIN products p
	 ON s.sal_prd_id = p.id
	 JOIN product_manufactured_region pmr 
	 ON p.product_man_region = pmr.id
     WHERE EXTRACT(YEAR FROM s.sal_date) = 2021
	 AND EXTRACT(QUARTER FROM s.sal_date) = 4
	 AND pmr.region_name = 'EMEA';

/* Dla roku 2020 widok był pusty więc utworzyłam widok dla roku 2021 */

/* 2 */
CREATE MATERIALIZED VIEW products_manufactured_in_2020_4_v2 AS
	SELECT s.id,
		   s.sal_description,
		   sum(s.sal_value) over(PARTITION BY p.product_code ORDER BY s.sal_date) AS sal_value_prod_code,
		   s.sal_prd_id,
		   EXTRACT(YEAR FROM s.sal_date) || '-' || EXTRACT(QUARTER FROM s.sal_date) as sal_y_q
     FROM sales s
	 JOIN products p
	 ON s.sal_prd_id = p.id
	 JOIN product_manufactured_region pmr 
	 ON p.product_man_region = pmr.id
     WHERE EXTRACT(YEAR FROM s.sal_date) = 2021
	 AND EXTRACT(QUARTER FROM s.sal_date) = 4
	 AND pmr.region_name = 'EMEA'
	 WITH DATA;
	 
CREATE UNIQUE INDEX idx_products_manufactured_in_2020_4_v2 ON products_manufactured_in_2020_4_v2 (id);

REFRESH MATERIALIZED VIEW CONCURRENTLY products_manufactured_in_2020_4_v2;

/* 3 */
SELECT p.product_code,
		pmr.region_name,
     	array_agg(p.product_name) AS products_list_for_code_and_region
		FROM products p
		JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region 
		GROUP BY p.product_code, pmr.region_name;
		
/* 4 */
CREATE TABLE IF NOT EXISTS products_region AS
	SELECT p.product_code,
			pmr.region_name,
			array_agg(p.product_name) AS products_list_for_code_and_region,
			CASE array_length(array_agg(p.product_name),1) > 1 
				WHEN TRUE 
					THEN TRUE
					ELSE FALSE
				END multiple_products
			FROM products p
			JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region 
			GROUP BY p.product_code, pmr.region_name;
			
/* 5 */
DROP TABLE IF EXISTS sales_archive CASCADE;

CREATE TABLE sales_archive (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	operation_type VARCHAR(1) NOT NULL,
	archived_at TIMESTAMP DEFAULT now()
);

/* 6 */
DROP FUNCTION products_archive_function CASCADE;
CREATE FUNCTION products_archive_function() 
   RETURNS TRIGGER 
   LANGUAGE plpgsql
	AS $$
		BEGIN
	        IF (TG_OP = 'DELETE') THEN
	            INSERT INTO sales_archive (sal_description, sal_date, sal_value, sal_prd_id, operation_type)
	                 VALUES (OLD.sal_description, OLD.sal_date, OLD.sal_value, OLD.sal_prd_id, 'D');
	        ELSIF (TG_OP = 'UPDATE') THEN
	            INSERT INTO sales_archive (sal_description, sal_date, sal_value, sal_prd_id, operation_type)
	                 VALUES (OLD.sal_description, OLD.sal_date, OLD.sal_value, OLD.sal_prd_id, 'U');
	        END IF;
	        RETURN NULL; -- rezultat zignoruj
		END;
	$$;
		
CREATE TRIGGER products_archive_trigger 
	AFTER UPDATE OR DELETE
   	ON sales
	FOR EACH ROW 
    EXECUTE PROCEDURE products_archive_function();
	
DELETE FROM sales WHERE EXTRACT(YEAR FROM sal_date) || '-' || EXTRACT(MONTH FROM sal_date) = '2021-10' RETURNING *;

SELECT * FROM sales WHERE EXTRACT(YEAR FROM sal_date) || '-' || EXTRACT(MONTH FROM sal_date) = '2021-10';

SELECT * FROM sales_archive;