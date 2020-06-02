----------------------------SELECTS---------------------------------
---------------------------consumers--------------------------------
CREATE OR REPLACE FUNCTION get_consumers() RETURNS SETOF consumers AS $$
BEGIN
	RETURN QUERY SELECT * FROM consumers;
END;
$$ LANGUAGE plpgsql;
---------------------------suppliers--------------------------------

CREATE OR REPLACE FUNCTION get_suppliers() RETURNS SETOF suppliers AS $$
BEGIN
	RETURN QUERY SELECT * FROM suppliers;
END;
$$ LANGUAGE plpgsql;
-----------------------------details--------------------------------

CREATE OR REPLACE FUNCTION get_details() RETURNS SETOF details AS $$
BEGIN
	RETURN QUERY SELECT * FROM details;
END;
$$ LANGUAGE plpgsql;

-----------------------------orders--------------------------------

CREATE OR REPLACE FUNCTION get_orders() RETURNS SETOF orders AS $$
BEGIN
	RETURN QUERY SELECT * FROM orders;
END;
$$ LANGUAGE plpgsql;
-----------------------get record by id--------------------------------
CREATE OR REPLACE FUNCTION get_record_by_id(table_name TEXT, record_id integer) RETURNS record AS $$
DECLARE
r_Return record;
BEGIN
EXECUTE 'SELECT * FROM '|| $1 ||' WHERE id = ' || $2 INTO r_Return;

RETURN r_Return;
END;
$$ LANGUAGE plpgsql;
-----------------------DELETE FROM TABLES------------------------------

CREATE OR REPLACE FUNCTION clear_table(table_name TEXT) RETURNS VOID AS $$
BEGIN
	EXECUTE 'TRUNCATE '|| $1 || ' CASCADE';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION clear_all_tables() RETURNS VOID AS $$
BEGIN
	TRUNCATE consumers, suppliers, details, orders;
END;
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------
-------------------INSERT NEW RECORDS-------------------------------

CREATE OR REPLACE FUNCTION insert_into_consumers(VARCHAR(30), TEXT) RETURNS VOID AS $$
BEGIN
	INSERT INTO consumers(name, address) VALUES ($1, $2);
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_into_suppliers(VARCHAR(30), TEXT) RETURNS VOID AS $$
BEGIN
	INSERT INTO suppliers(sername, address) VALUES($1, $2);
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_into_details(VARCHAR(30), TEXT, INTEGER, INTEGER) RETURNS VOID AS $$
BEGIN
	INSERT INTO details(name, storage_address, quantity, price) VALUES($1, $2, $3, $4);
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_into_orders(INTEGER, INTEGER, INTEGER, INTEGER) RETURNS VOID AS $$
BEGIN
	INSERT INTO orders(consumer_id, supplier_id, detail_id, number_of_details) VALUES($1, $2, $3, $4);
END
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------
-------------------SEARCH RECORDS BY TEXT FIELD---------------------

CREATE OR REPLACE FUNCTION search_consumers_by_address(TEXT) RETURNS SETOF consumers AS $$
BEGIN
	RETURN QUERY SELECT * FROM consumers WHERE address LIKE '%'||$1||'%';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_suppliers_by_address(TEXT) RETURNS SETOF suppliers AS $$
BEGIN
	RETURN QUERY SELECT * FROM suppliers WHERE address LIKE '%'||$1||'%';
END
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------
-----------------------UPDATE RECORDS-------------------------------

CREATE OR REPLACE FUNCTION update_consumers(record_id INTEGER, VARCHAR(30), TEXT) RETURNS VOID AS $$
BEGIN
	UPDATE consumers
	SET name = $2, address = $3
	WHERE id = record_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_suppliers(record_id INTEGER, VARCHAR(30), TEXT) RETURNS VOID AS $$
BEGIN
	UPDATE suppliers
	SET sername = $2, address = $3
	WHERE id = record_id;
END;
$$ LANGUAGE plpgsql;


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

CREATE OR REPLACE FUNCTION delete_from_consumers_by_address(TEXT) RETURNS VOID AS $$
BEGIN
	DELETE FROM consumers WHERE address LIKE '%'||$1||'%';
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_from_suppliers_by_address(TEXT) RETURNS VOID AS $$
BEGIN
	DELETE FROM suppliers WHERE address LIKE '%'||$1||'%';
END
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------------
-----------------------DELETE RECORD FROM TABLE---------------------------

CREATE OR REPLACE FUNCTION delete_record_from_table(record_id INTEGER, table_name TEXT) RETURNS VOID AS $$
BEGIN
	EXECUTE 'DELETE FROM '||table_name||' WHERE id = '|| record_id;
END;
$$ LANGUAGE plpgsql;
