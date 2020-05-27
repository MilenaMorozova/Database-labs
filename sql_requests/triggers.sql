/*CREATE USER non-root WITH PASSWORD '123';
CREATE DATABASE my_database OWNER non-root;
GRANT ALL PRIVILEGES ON my_database TO "non-root";
REVOKE UPDATE, INSERT ON total FROM orders*/
--DROP FUNCTION IF EXISTS create_tables;

CREATE OR REPLACE FUNCTION create_tables() RETURNS VOID AS $$
BEGIN
		CREATE TABLE consumers
	(
		id SERIAL PRIMARY KEY,
		name VARCHAR(30) NOT NULL,
		address TEXT NOT NULL
	);

	CREATE TABLE suppliers
	(
		id SERIAL PRIMARY KEY,
		sername VARCHAR(30) NOT NULL,
		address TEXT NOT NULL
	);

	CREATE TABLE details(
		id SERIAL PRIMARY KEY,
		name VARCHAR(30) NOT NULL,
		storage_address TEXT NOT NULL,
		quantity INTEGER DEFAULT 0 CHECK(quantity >= 0),
		price INTEGER NOT NULL CHECK(price >= 0)
	);

	CREATE TABLE orders(
		id SERIAL PRIMARY KEY,
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

--SELECT create_tables();
-----------------------TRIGGERS-------------------------
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
DROP FUNCTION create_database(text);

CREATE OR REPLACE FUNCTION create_database(name_database TEXT, _user TEXT, _password TEXT) RETURNS VOID AS $$
BEGIN
  CREATE EXTENSION IF NOT EXISTS dblink; -- enable extension 
  IF EXISTS (SELECT 1 FROM pg_database WHERE datname = name_database) THEN
    RAISE NOTICE 'Database already exists';
  ELSE
    PERFORM dblink_connect('host=localhost user=' || _user || ' password=' || _password || ' dbname=' || current_database());
    PERFORM dblink_exec('CREATE DATABASE ' || name_database);
  END IF;
END
$$ LANGUAGE plpgsql;

--SELECT create_database('mydatabase0123', 'postgres', 'SQL0!');

CREATE OR REPLACE FUNCTION drop_database(name_database TEXT) RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS (SELECT FROM pg_database WHERE datname = name_database) THEN
		RAISE NOTICE 'Database does not exists';  -- optional
	ELSE
		 PERFORM dblink_exec('DROP DATABASE '|| name_database);
	END IF;
END;
$$ LANGUAGE plpgsql;

--SELECT drop_database('mydatabase0123');
----------------------------SELECTS---------------------------------
---------------------------consumers--------------------------------
--DROP FUNCTION IF EXISTS get_consumers;

CREATE OR REPLACE FUNCTION get_consumers() RETURNS SETOF consumers AS $$
BEGIN
	RETURN QUERY SELECT * FROM consumers;
END;
$$ LANGUAGE plpgsql;

--SELECT get_consumers();
---------------------------suppliers--------------------------------
--DROP FUNCTION IF EXISTS get_suppliers;

CREATE OR REPLACE FUNCTION get_suppliers() RETURNS SETOF suppliers AS $$
BEGIN
	RETURN QUERY SELECT * FROM suppliers;
END;
$$ LANGUAGE plpgsql;

--SELECT get_suppliers();
-----------------------------details--------------------------------
--DROP FUNCTION IF EXISTS get_details;

CREATE OR REPLACE FUNCTION get_details() RETURNS SETOF details AS $$
BEGIN
	RETURN QUERY SELECT * FROM details;
END;
$$ LANGUAGE plpgsql;

--SELECT get_details();
-----------------------------orders--------------------------------
--DROP FUNCTION IF EXISTS get_orders;

CREATE OR REPLACE FUNCTION get_orders() RETURNS SETOF RECORD AS $$
BEGIN
	RETURN QUERY SELECT * FROM orders;
END;
$$ LANGUAGE plpgsql;

--SELECT get_orders();
-----------------------DELETE FROM TABLES------------------------------
CREATE OR REPLACE FUNCTION clear_table(table_name TEXT) RETURNS VOID AS $$
BEGIN
	EXECUTE 'TRUNCATE '|| $1 || ' CASCADE';
END;
$$ LANGUAGE plpgsql;
--SELECT clear_table('orders')
--DROP FUNCTION IF EXISTS clear_all_tables;

CREATE OR REPLACE FUNCTION clear_all_tables() RETURNS VOID AS $$
BEGIN
	TRUNCATE consumers, suppliers, details, orders;
END;
$$ LANGUAGE plpgsql;
--SELECT clear_all_tables()
--------------------------------------------------------------------
-------------------INSERT NEW RECORDS-------------------------------
--DROP FUNCTION IF EXISTS insert_into_consumers;
CREATE OR REPLACE FUNCTION insert_into_consumers(VARCHAR(30), TEXT) RETURNS VOID AS $$
BEGIN
	INSERT INTO consumers(name, address) VALUES ($1, $2);
END
$$ LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS insert_into_suppliers;
CREATE OR REPLACE FUNCTION insert_into_suppliers(VARCHAR(30), TEXT) RETURNS VOID AS $$
BEGIN
	INSERT INTO suppliers(sername, address) VALUES($1, $2);
END
$$ LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS insert_into_details;
CREATE OR REPLACE FUNCTION insert_into_details(VARCHAR(30), TEXT, INTEGER, INTEGER) RETURNS VOID AS $$
BEGIN
	INSERT INTO details(name, storage_address, quantity, price) VALUES($1, $2, $3, $4);
END
$$ LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS insert_into_orders;
CREATE OR REPLACE FUNCTION insert_into_orders(INTEGER, INTEGER, INTEGER, INTEGER) RETURNS VOID AS $$
BEGIN
	INSERT INTO orders(consumer_id, supplier_id, detail_id, number_of_details) VALUES($1, $2, $3, $4);
END
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------
-------------------SEARCH RECORDS BY TEXT FIELD---------------------
--DROP FUNCTION IF EXISTS search_consumers_by_address;
CREATE OR REPLACE FUNCTION search_consumers_by_address(TEXT) RETURNS SETOF consumers AS $$
BEGIN
	RETURN QUERY SELECT * FROM consumers WHERE address LIKE '%'||$1||'%';
END
$$ LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS search_suppliers_by_address;
CREATE OR REPLACE FUNCTION search_suppliers_by_address(TEXT) RETURNS SETOF suppliers AS $$
BEGIN
	RETURN QUERY SELECT * FROM suppliers WHERE address LIKE '%'||$1||'%';
END
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------
-----------------------UPDATE RECORDS-------------------------------
--DROP FUNCTION IF EXISTS update_consumers;
CREATE OR REPLACE FUNCTION update_consumers(record_id INTEGER, VARCHAR(30), TEXT) RETURNS VOID AS $$
BEGIN
	UPDATE consumers
	SET name = $2, address = $3
	WHERE id = record_id;
END;
$$ LANGUAGE plpgsql;

--DROP FUNCTION update_suppliers
CREATE OR REPLACE FUNCTION update_suppliers(record_id INTEGER, VARCHAR(30),TEXT) RETURNS VOID AS $$
BEGIN
	UPDATE suppliers
	SET sername = $2, address = $3
	WHERE id = record_id;
END;
$$ LANGUAGE plpgsql;
--SELECT update_suppliers(1, 'fgu', 'g')

CREATE OR REPLACE FUNCTION update_details(record_id INTEGER, VARCHAR(30), TEXT, INTEGER, INTEGER) RETURNS VOID AS $$
BEGIN
	UPDATE details
	SET name = $2, storage_address = $3, quantity = $4, price = $5
	WHERE id = record_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_orders(record_id INTEGER, INTEGER, INTEGER, INTEGER, INTEGER) RETURNS VOID AS $$
BEGIN
	UPDATE orders
	SET consumer_id = $2, supplier_id = $3, detail_id = $4, number_of_details = $5
	WHERE id = record_id;
END;
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------------
-----------------------DELETE BY TEXT FIELD-------------------------------
--DROP FUNCTION IF EXISTS delete_from_consumers_by_address;
CREATE OR REPLACE FUNCTION delete_from_consumers_by_address(TEXT) RETURNS VOID AS $$
BEGIN
	DELETE FROM consumers WHERE address LIKE '%'||$1||'%';
END
$$ LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS delete_from_suppliers_by_address;
CREATE OR REPLACE FUNCTION delete_from_suppliers_by_address(TEXT) RETURNS VOID AS $$
BEGIN
	DELETE FROM suppliers WHERE address LIKE '%'||$1||'%';
END
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------------
-----------------------DELETE BY TEXT FIELD-------------------------------
--DROP FUNCTION delete_record_from_table
CREATE OR REPLACE FUNCTION delete_record_from_table(record_id INTEGER, table_name TEXT) RETURNS VOID AS $$
BEGIN
	EXECUTE 'DELETE FROM '||table_name||' WHERE id = '|| record_id;
END;
$$ LANGUAGE plpgsql;
