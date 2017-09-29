


/** 1. Who wrote 'The Shining' */

SELECT 
	last_name, 
	first_name 
FROM authors t1, books t2
WHERE t1.author_id=t2.author_id AND lower(t2.title)='the shining';



/** 2. Which titles are written by Paulette Bourgeois */

SELECT title FROM books t1, authors t2
WHERE t1.author_id=t2.author_id AND lower(t2.last_name)='bourgeois';


/** 3. Who Bought books about "Horror"? */

SELECT 
	last_name, 
	first_name 
FROM customers t1, shipments t2, editions t3, books t4, subjects t5
WHERE t2.isbn=t3.isbn AND t1.customer_id=t2.customer_id AND t3.book_id=t4.book_id AND 
t4.subject_id=t5.subject_id AND  lower(t5.subject)='horror';


/** 4. Which book has the largest stock? */

SELECT title FROM books t1, stock t2, editions t3
WHERE t2.isbn=t3.isbn AND t1.book_id=t3.book_id 
ORDER BY stock DESC LIMIT 1;


/** 5. How much money has Booktown collected for the books about Science Fiction?
They collect the retail price of each book shiped. */

SELECT 
SUM(retail_price) 
	FROM stock t1, shipments t2, editions t3, books t4, subjects t5
WHERE t1.isbn=t2.isbn AND t2.isbn=t3.isbn AND t3.book_id=t4.book_id AND t4.subject_id=t5.subject_id
AND lower(subject)='science fiction';


/** 6. Which books have been sold to only two people? 
Note that some people buy more than one copy and some books appear as
several editions.*/


SELECT 
	title
FROM books t1, editions t2, shipments t3
WHERE t2.isbn=t3.isbn AND t2.book_id=t1.book_id
GROUP BY title
HAVING count(customer_id)=2;



/** 7. Which publisher has sold the most to Booktown?
Note that all shipped books were sold at ‘cost’ to as well as all the books in the
stock */



CREATE VIEW sales AS
SELECT
	publishers.name,
	(stock.cost*stock.stock) AS sum_sales,
	count(shipments.shipment_id)*stock.cost as sum_shipments
FROM shipments
JOIN editions on editions.isbn=shipments.isbn
JOIN stock on editions.isbn=stock.isbn
JOIN publishers on editions.publisher_id=publishers.publisher_id
GROUP BY publishers.name, stock.cost, stock.stock
ORDER BY sum_sales DESC;

SELECT 
	publishers.name,
	SUM(sum_sales)+SUM(sum_shipments) as total_sales
FROM publishers
JOIN sales on publishers.name=sales.name
GROUP BY publishers.name
ORDER BY total_sales DESC 
LIMIT 1;

DROP VIEW sales;


/**
SELECT 
	publishers.name, 
	SUM(stock.cost * (stock.stock+shipment_count.books_shipped)) AS total_sales
FROM stock JOIN (SELECT 
	isbn, 
	count(isbn) as books_shipped
	FROM shipments
	GROUP BY isbn) AS shipment_count ON shipment_count.isbn=stock.isbn

JOIN editions on editions.isbn=stock.isbn
JOIN publishers on editions.publisher_id=publishers.publisher_id
GROUP BY publishers.name
ORDER BY total_sales DESC
LIMIT 1;

*/

/** 8. How much money has Booktown earned (so far)? (Explain to the teacher how
you reason about the incomes and costs of Booktown) */


--Intäkt
SELECT 
	SUM(stock.retail_price) as total_earnings,
	SUM(stock.retail_price-stock.cost) as total_margin
FROM stock INNER JOIN shipments ON shipments.isbn=stock.isbn;



/** 9. Which customers have bought books about at least three different subjects? */

SELECT 
	last_name,
	first_name
FROM customers
	JOIN shipments USING(customer_id)
	JOIN (SELECT
			customer_id,
			count(subject_id) as count
			FROM books 
			JOIN editions ON books.book_id=editions.book_id
			JOIN shipments ON editions.isbn=shipments.isbn
			GROUP BY customer_id
			HAVING count(subject_id) >= 3
			) as customer_sales ON shipments.customer_id=customer_sales.customer_id
	GROUP BY last_name, first_name;



/** 10. Which subjects have not sold any books? */


SELECT
	subjects.subject
FROM subjects
WHERE subjects.subject NOT IN (SELECT 
	subject
FROM shipments 
JOIN editions ON shipments.isbn=editions.isbn
JOIN books ON books.book_id=editions.book_id
JOIN subjects ON subjects.subject_id=books.subject_id
GROUP BY subject);


/** Tables
PGPASSWORD=UKZTM5nD psql -h nestor2.csc.kth.se < lab1.sql -U nilsek

books((book_id), title, author_id, subject_id)
publishers((publisher_id), name, address)
authors((author_id), last_name, first_name)
stock((isbn), cost, retail_price, stock)
shipments((shipment_id), customer_id, isbn, ship_date)
customers((customer_id), last_name, first_name)
editions((isbn), book_id, edition, publisher_id, publication_date)
subjects((subject_id), subject, location)
*/