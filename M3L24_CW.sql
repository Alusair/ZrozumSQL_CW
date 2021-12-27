/* 1 */
CREATE SCHEMA training;

/* 2 */
ALTER SCHEMA training RENAME TO training_zs;

/* 3 */
CREATE TABLE training_zs.products (
	id int,
	production_qty numeric(10, 2),
	product_name varchar(100),
	product_code varchar(10),
	description text,
	manufacturing_date date
);

/* 4 */
ALTER TABLE training_zs.products ADD CONSTRAINT pk_products PRIMARY KEY (id);

/* 5 */
DROP TABLE IF EXISTS training_zs.sales;

/* 6 */
CREATE TABLE training_zs.sales (
	id int PRIMARY KEY,
	sales_date timestamp NOT NULL,
	sales_amount numeric(38, 2),
	sales_qty numeric(10, 2),
	product_id int,
	added_by text DEFAULT 'admin',
	CONSTRAINT sales_over_1k CHECK (sales_amount > 1000)	
);

/* 7 */
ALTER TABLE training_zs.sales ADD FOREIGN KEY (product_id) REFERENCES training_zs.products (id) ON DELETE CASCADE;

/* 8 */
DROP SCHEMA training_zs CASCADE;