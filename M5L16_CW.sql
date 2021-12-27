/* Moduł 5 Data Manipulation Language – Zadania Teoria SQL */
/* 1 */
CREATE SCHEMA dml_exercises;

/* 2 */
CREATE TABLE dml_exercises.sales (
	id SERIAL PRIMARY KEY,
	sales_date timestamp NOT NULL,
	sales_amount numeric(38, 2),
	sales_qty numeric (10, 2),
	added_by text DEFAULT 'admin',
	CONSTRAINT sales_less_1k CHECK (sales_amount <= 1000)
);

/* 3 */
INSERT INTO dml_exercises.sales (sales_date, sales_amount, sales_qty, added_by) VALUES ('05.11.2021 2:33:25 PM', 888, 2, NULL), ('05.11.2021 2:33:25 PM', 444, 2, NULL), ('05.11.2021 2:33:25 PM', 111, 2, NULL);
INSERT INTO dml_exercises.sales (sales_date, sales_amount, sales_qty, added_by) VALUES ('05.11.2021 2:33:25 PM', 888, 2, NULL), ('05.11.2021 2:33:25 PM', 444, 2, NULL), ('05.11.2021 2:33:25 PM', 1111, 2, NULL);

/* 4 */
INSERT INTO dml_exercises.sales (sales_date, sales_amount,sales_qty, added_by) VALUES ('20/11/2019', 101, 50, NULL); /* jak nie zostanie podana godzina to automatycznie wstawi się 00:00:00 dla HH:MM:SS */

/* 5 */
INSERT INTO dml_exercises.sales (sales_date, sales_amount,sales_qty, added_by) VALUES ('04/04/2020', 101, 50, NULL);  /* użyć komendy SHOW datestyle; do sprawdzenia daty */

SHOW datestyle;

/* 6 */
INSERT INTO dml_exercises.sales (sales_date, sales_amount, sales_qty,added_by)
	SELECT NOW() + (random() * (interval '90 days')) + '30 days',
	random() * 500 + 1,
	random() * 100 + 1,
	NULL
	FROM generate_series(1, 20000) s(i);
	
/* 7 */
UPDATE dml_exercises.sales SET added_by = 'sales_over_200' WHERE sales_amount >= 200;

/* 8 */
DELETE FROM dml_exercises.sales WHERE added_by = NULL;
DELETE FROM dml_exercises.sales WHERE added_by IS NULL;

/* 9 */
TRUNCATE dml_exercises.sales RESTART IDENTITY;

/* 10 */
INSERT INTO dml_exercises.sales (sales_date, sales_amount, sales_qty,added_by)
	SELECT NOW() + (random() * (interval '90 days')) + '30 days',
	random() * 500 + 1,
	random() * 100 + 1,
	NULL
	FROM generate_series(1, 20000) s(i);