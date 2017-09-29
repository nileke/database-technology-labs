
CREATE FUNCTION decstock() RETURNS trigger AS $pname$
	BEGIN
		IF ((SELECT stock FROM stock WHERE stock.isbn=NEW.isbn) = 0)
			THEN RAISE EXCEPTION 'Book (isbn: %) not in stock', NEW.isbn;
		ELSE
			UPDATE stock SET stock = stock-1 WHERE isbn=NEW.isbn;
			RETURN NEW;
		END IF;
	END;

$pname$ LANGUAGE plpgsql;

CREATE TRIGGER pname
AFTER INSERT ON shipments
	FOR EACH ROW EXECUTE PROCEDURE decstock();


SELECT * FROM stock;

INSERT INTO shipments VALUES(2000, 860, '0394900014', '2012-12-07');

INSERT INTO shipments VALUES(2001, 860, '044100590X', '2012-12-07');

SELECT * FROM shipments WHERE shipment_id > 1999;

SELECT * FROM stock;

DELETE FROM shipments WHERE shipment_id > 1999;

UPDATE stock SET stock = 89 WHERE isbn = '044100590X';

DROP FUNCTION decstock() CASCADE ;