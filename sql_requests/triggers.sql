/*CREATE USER non-root WITH PASSWORD '123';
CREATE DATABASE my_database OWNER non-root;
GRANT ALL PRIVILEGES ON my_database TO "non-root";
REVOKE UPDATE, INSERT ON total FROM orders*/

--triggers for update orders.total
--update details.price
CREATE OR REPLACE FUNCTION update_total_by_detail_price()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE orders
	SET total = orders.number_of_details * NEW.price
	WHERE orders.detail_id = NEW.id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_total ON details;

CREATE TRIGGER t_total 
AFTER UPDATE OF price ON details
FOR EACH ROW
EXECUTE PROCEDURE update_total_by_detail_price();

--update orders.number_of_details
CREATE OR REPLACE FUNCTION update_total_by_number_of_details()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'UPDATE' OR TG_OP = 'INSERT' THEN
		NEW.total = NEW.number_of_details * (SELECT price FROM details WHERE id = NEW.detail_id);
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_total ON orders;

CREATE TRIGGER t_total 
BEFORE UPDATE OF number_of_details ON orders
FOR EACH ROW
EXECUTE PROCEDURE update_total_by_number_of_details();

--insert into orders-------------------------------
DROP TRIGGER IF EXISTS t_insert_orders ON orders;

CREATE TRIGGER t_insert_orders
BEFORE INSERT ON orders
FOR EACH ROW
EXECUTE PROCEDURE update_total_by_number_of_details();
------------------------------------------------
-----------------FUNCTIONS----------------------
/*CREATE EXTENSION dblink;

CREATE OR REPLACE FUNCTION create_database(name_database TEXT) RETURNS VOID AS $$
BEGIN
   IF EXISTS (SELECT FROM pg_database WHERE datname = name_database) THEN
      RAISE NOTICE 'Database already exists';  -- optional
   ELSE
      PERFORM dblink_exec('dbname=' || current_database()  -- current db
                        , 'CREATE DATABASE '|| name_database);
   END IF;
END
$$LANGUAGE plpgsql;

SELECT create_database('uhfih');*/

/*CREATE OR REPLACE FUNCTION drop_database(name_database TEXT) RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS (SELECT FROM pg_database WHERE datname = name_database) THEN
		RAISE NOTICE 'Database does not exists';  -- optional
	ELSE
		DROP DATABASE name_database;
	END IF;
END;
$$ LANGUAGE plpgsql;*/


CREATE OR REPLACE FUNCTION create_tables() RETURNS VOID AS $$
BEGIN
		CREATE TABLE consumers
	(
		id INTEGER NOT NULL UNIQUE PRIMARY KEY,
		name VARCHAR(30) NOT NULL,
		address TEXT NOT NULL
	);

	CREATE TABLE suppliers
	(
		id INTEGER NOT NULL UNIQUE PRIMARY KEY,
		sername VARCHAR(30) NOT NULL,
		address TEXT NOT NULL
	);

	CREATE TABLE details(
		id INTEGER NOT NULL UNIQUE PRIMARY KEY,
		name VARCHAR(30) NOT NULL,
		storage_address TEXT NOT NULL,
		quantity INTEGER DEFAULT 0 CHECK(quantity >= 0),
		price INTEGER NOT NULL CHECK(price >= 0)
	);

	CREATE TABLE orders(
		id INTEGER NOT NULL UNIQUE PRIMARY KEY,
		date timestamp DEFAULT date_trunc('second', now()),
		consumer_id INTEGER NOT NULL 
		REFERENCES consumers (id) ON DELETE CASCADE ON UPDATE CASCADE,
		supplier_id INTEGER NOT NULL 
		REFERENCES suppliers (id) ON DELETE CASCADE ON UPDATE CASCADE,
		detail_id INTEGER NOT NULL 
		REFERENCES details (id) ON DELETE CASCADE ON UPDATE CASCADE,
		number_of_details INTEGER NOT NULL CHECK(number_of_details > 0),
		total BIGINT NOT NULL
	);
	CREATE INDEX ON consumers(address);
	CREATE INDEX ON suppliers(address);
END;
$$ LANGUAGE plpgsql;
----------------------------SELECTS---------------------------------
---------------------------consumers--------------------------------
DROP FUNCTION IF EXISTS get_consumers;

CREATE OR REPLACE FUNCTION get_consumers() RETURNS SETOF consumers AS $$
BEGIN
	RETURN QUERY SELECT * FROM consumers;
END;
$$ LANGUAGE plpgsql;

--SELECT get_consumers();
---------------------------suppliers--------------------------------
DROP FUNCTION IF EXISTS get_suppliers;

CREATE OR REPLACE FUNCTION get_suppliers() RETURNS SETOF suppliers AS $$
BEGIN
	RETURN QUERY SELECT * FROM suppliers;
END;
$$ LANGUAGE plpgsql;

--SELECT get_suppliers();
-----------------------------details--------------------------------
DROP FUNCTION IF EXISTS get_details;

CREATE OR REPLACE FUNCTION get_details() RETURNS SETOF details AS $$
BEGIN
	RETURN QUERY SELECT * FROM details;
END;
$$ LANGUAGE plpgsql;

--SELECT get_details();
-----------------------------orders--------------------------------
DROP FUNCTION IF EXISTS get_orders;

CREATE OR REPLACE FUNCTION get_orders() RETURNS SETOF RECORD AS $$
BEGIN
	RETURN QUERY SELECT * FROM orders;
END;
$$ LANGUAGE plpgsql;

--SELECT get_orders();
-----------------------DELETE FROM TABLES------------------------------
DROP FUNCTION IF EXISTS clear_table;

/*CREATE TABLE TY(ID SERIAL, Y INTEGER);
INSERT INTO TY(Y) VALUES(1), (2), (3);
SELECT * FROM TY;*/

CREATE OR REPLACE FUNCTION clear_table(table_name TEXT) RETURNS VOID AS $$
BEGIN
	EXECUTE 'DELETE FROM '|| $1;
END;
$$ LANGUAGE plpgsql;

--SELECT clear_table('TY')
DROP FUNCTION IF EXISTS clear_all_tables;

CREATE OR REPLACE FUNCTION clear_all_tables() RETURNS VOID AS $$
BEGIN
	EXECUTE 'DELETE FROM consumers';
	EXECUTE 'DELETE FROM suppliers';
	EXECUTE 'DELETE FROM details';
	EXECUTE 'DELETE FROM orders';
END;
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------
-------------------INSERT NEW RECORDS-------------------------------
