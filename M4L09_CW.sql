/* Moduł 4 Data Control Language – Zadania Teoria SQL */
/* 1 */
CREATE ROLE user_training WITH LOGIN PASSWORD 'si1neh4s10';

/* 2 */
CREATE SCHEMA training AUTHORIZATION user_training;

/* 3 */
DROP ROLE user_training;

/* 4 */
REASSIGN OWNED BY user_training TO postgres;

/* 5 */
CREATE ROLE reporting_ro;
GRANT CONNECT ON DATABASE postgres TO reporting_ro;
GRANT USAGE, CREATE ON SCHEMA training TO reporting_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA training TO reporting_ro;

/* 6 */
CREATE ROLE reporting_user WITH LOGIN PASSWORD 'si1neh4s10nr2';
GRANT reporting_ro TO reporting_user;

/* 7 */
CREATE TABLE training.test (
	id int
);

/* 8 */
REVOKE CREATE ON SCHEMA training FROM reporting_ro;

/* 9 */
CREATE TABLE training.test2 (
	id int
);

CREATE TABLE public.test (
	id int
);