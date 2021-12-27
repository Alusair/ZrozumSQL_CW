/* Moduł 12 – TIPS & TRICKS – Zadania Teoria SQL */

/* 1 */
SELECT schemaname,
		tablename AS object_name,
		't' AS object_type,
		tableowner AS object_owner		
	FROM pg_tables
	UNION ALL
	SELECT schemaname,
			viewname,
			'v' AS object_type,
			viewowner
		FROM pg_views
		UNION ALL
		SELECT schemaname,
				tablename,
				'i' AS object_type,
				indexname
			FROM pg_indexes;
			
/* 2 */
CREATE EXTENSION pgcrypto;

SELECT encrypt('ultraSilneHa3l0$567'::bytea, 'qwerty123!@#'::bytea, 'aes');

SELECT crypt('ultraSilneHa3l0$567', gen_salt('md5'));

SELECT encrypt('ultraSilneHa3l0$567', gen_salt('md5')::bytea, 'aes')

SELECT encrypt('ultraSilneHa3l0$567', gen_salt('md5')::bytea, 'aes'),  
	   decrypt(
	   	encrypt('ultraSilneHa3l0$567', gen_salt('md5')::bytea, 'aes'), 
	   	gen_salt('md5')::bytea,
	   	'aes');
		
/* 3 */
/* Dane ze skryptu */
DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
	id SERIAL,
	c_name TEXT,
	c_mail TEXT,
	c_phone VARCHAR(9),
	c_description TEXT
);

INSERT INTO customers (c_name, c_mail, c_phone, c_description)
	VALUES ('Krzysztof Bury', 'kbur@domein.pl', '123789456',  left(md5(random()::text), 15)),
			('Onufry Zagłoba', 'zagloba@ogniemimieczem.pl', '100000001', left(md5(random()::text), 15)),
			('Krzysztof Bury', 'kbur@domein.pl', '123789456', left(md5(random()::text), 15)),
			('Pan Wołodyjowski', 'p.wolodyj@polska.pl', '987654321', left(md5(random()::text), 15)),
			('Michał Skrzetuski', 'michal<at>zamek.pl', '654987231', left(md5(random()::text), 15)),
			('Bohun Tuhajbejowicz', NULL, NULL, left(md5(random()::text), 15));


SELECT DISTINCT
		c_name,
		CONCAT(SUBSTRING(c_mail, 1, 1), '@', SUBSTRING(REPLACE(c_mail, '<at>', '@') from '@(.*)$')) AS mail,
		'XXX-XXX-' || SUBSTRING(c_phone, LENGTH(c_phone) - 2) AS phone,
		c_description
		FROM customers
		
