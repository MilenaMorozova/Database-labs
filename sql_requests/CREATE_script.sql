------------------------CREATE TABLES-----------------------
--if not exists
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
--------------------------------------------------------