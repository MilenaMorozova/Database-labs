INSERT INTO consumers(
	name, address)
VALUES ('АО ВАРЯ', 'Сормовский'),
	('ГАЗ', 'Автозаводский'),
	('МП ВЕРА', 'Канавинский'),
	('МП', 'Канавинский'),
	('АО СТАЛЬ', 'Советский')
;

INSERT INTO suppliers(
	sername, address)
VALUES('Артюхина', 'Сормовский'),
	('Щепин', 'Приокский'),
	('Власов', 'Канавинский'),
	('Кузнецова', 'Советский'),
	('Цепилева', 'Нижегородский'),
	('Корнилов', 'Нижегородский')
;

INSERT INTO details(
	name, storage_address, quantity, price)
VALUES('Втулка', 'Сормовский', 20000, 5000),
	('Болт', 'Сормовский', 40000, 1000),
	('Ключ гаечный', 'Канавинский', 5000, 3000),
	('Шпилька', 'Автозаводский', 10000, 900),
	('Винт', 'Сормовский', 50000, 1500),
	('Молоток', 'Канавинский', 1200, 2000),
	('Шуруп', 'Сормовский', 30000, 1200)
;
INSERT INTO orders(
	consumer_id, supplier_id, detail_id, number_of_details, total)
VALUES(5, 4, 3, 7, 21000),
	(3, 3, 3, 2, 6000),
	(4, 5, 4, 200, 180000),
	(5, 4, 2, 50, 50000),
	(1, 6, 7, 110, 132000),
	(4, 4,	1, 150, 750000),
	(2, 4, 6, 20, 40000),
	(1, 3, 7, 2000,	2400000),
	(2, 5, 7, 10000, 12000000),
	(3, 6, 1, 5, 25000),
	(4, 3, 3, 1, 3000),
	(4, 4, 1, 10, 50000),
	(1, 6, 6, 3, 6000),
	(2, 1, 2, 1000, 1000000),
	(2, 2, 1, 100, 5000000),
	(5, 1, 5, 100, 15000),
	(1, 4, 7, 12000, 24400000)
;