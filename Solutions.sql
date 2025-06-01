SELECT * FROM books
LIMIT 5;
SELECT * FROM branch
LIMIT 5;
SELECT * FROM employees
LIMIT 5;
SELECT * FROM issued_status
LIMIT 5;
SELECT * FROM return_status
LIMIT 5;
SELECT * FROM members
LIMIT 5;

--Project tasks
--## CRUD Tasks
--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books
VALUES
	(
	'978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'
	)
SELECT * FROM books
WHERE isbn='978-1-60129-456-2';

--Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members 
WHERE member_id = 'C101';

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_member_id, COUNT(issued_book_isbn) AS no_of_books FROM issued_status
GROUP BY 1
HAVING 
	 COUNT(issued_book_isbn)>1;

--## CTAS Task
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE issue_counts AS
SELECT 
	b.isbn,b.book_title,COUNT(ists.issued_id) AS no_of_issued
FROM books AS b
JOIN issued_status AS ists
ON b.isbn = ists.issued_book_isbn
GROUP BY 1,2
ORDER BY COUNT(ists.issued_book_isbn) DESC;
SELECT * FROM issue_counts
LIMIT 5;

ALTER TABLE issue_counts
RENAME no_of_issued TO issue_count;

--## Data Analysis & Findings
--Task 7. Retrieve All Books in a Specific Category:
SELECT book_title, isbn
FROM books
WHERE category = 'Classic'

--Task 8: Find Total Rental Income by Category:
SELECT b.category, SUM(b.rental_price) AS rental_revenue
FROM books AS b
JOIN issued_status AS ists
ON b.isbn = ists.issued_book_isbn
GROUP BY 1;

--Task 9: List Members Who Registered in the Last 180 Days:
SELECT * FROM members
WHERE reg_date>=CURRENT_DATE - INTERVAL '180 days'
--Method 2
SELECT * FROM members
WHERE CURRENT_DATE - reg_date <= 180;

/*Task 10: List Employees with Their Branch Manager's Name and their branch details: branch id, mngr id, brnch add----emp id, emp name, position, salary, 
branch id*/
SELECT b.branch_id, e1.emp_id, e1.emp_name, e1.position, e1.salary, e2.emp_name as manager_name
FROM branch as b
JOIN employees AS e1
ON b.branch_id = e1.branch_id
JOIN employees AS e2
ON b.manager_id = e2.emp_id
ORDER BY b.branch_id, e1.emp_id ASC

--Task 11: Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price >=7.5

--Task 12. Retrieve the List of Books Not Yet Returned
WITH not_returned AS 
(SELECT issued_id FROM issued_status
EXCEPT
SELECT issued_id FROM return_status)
SELECT 
ists.issued_id AS not_returned_book_id, ists.issued_book_name, ists.issued_date, ists.issued_book_isbn
FROM issued_status AS ists
JOIN not_returned AS nr
ON ists.issued_id = nr.issued_id
ORDER BY 1
--Method 2
WITH not_returned AS 
(SELECT issued_id FROM issued_status
EXCEPT
SELECT issued_id FROM return_status)
SELECT 
issued_id AS not_returned_book_id, issued_book_name, issued_date, issued_book_isbn
FROM issued_status
WHERE issued_id IN (SELECT issued_id FROM not_returned);

/*Task 13: Identify Members with Overdue Books. Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue*/

WITH overdue_members AS
(SELECT issued_id, issued_member_id, issued_book_name, issued_date
FROM issued_status
WHERE CURRENT_DATE - INTERVAL '30 days' > issued_date)
SELECT m.member_id,m.member_name,om.issued_book_name,om.issued_date, CURRENT_DATE - om.issued_date AS overdue_days
FROM overdue_members AS om
JOIN members AS m
ON om.issued_member_id = m.member_id
WHERE 
om.issued_id NOT IN (SELECT issued_id FROM return_status)
ORDER BY 1

--Method 2
SELECT 
	m.member_id, 
	m.member_name,
	bk.book_title,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date AS overdue_days
FROM
issued_status AS ist
JOIN 
members AS m
ON ist.issued_member_id = m.member_id
JOIN 
books AS bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE 
	return_date IS NULL
	AND 
	CURRENT_DATE - ist.issued_date > 30
ORDER BY 1 

/*Task 14. Update Book Status on Return. Write a query to update the status of books in the books table to "Yes" when they are returned 
(based on entries in the return_status table).*/

CREATE OR REPLACE PROCEDURE add_return_record(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(18);
	v_book_name VARCHAR(60);
BEGIN
	--inserting into return_status table
	INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
	VALUES
	(p_return_id,p_issued_id,CURRENT_DATE,p_book_quality);

	--Extracting isbn and book_name of the book being returned
	SELECT 
	issued_book_isbn, issued_book_name INTO v_isbn, v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;

	--Updating status in book table
	UPDATE books
	SET status = 'yes'
	WHERE
	isbn = v_isbn;

	RAISE NOTICE 'Return details recorded, book name: %',v_book_name;
END;
$$

--Not returned book 
-- issued_id = IS122 and isbn = 978-0-451-52993-5
CALL add_return_record('RS120','IS122','Good')

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch,
showing the number of books issued, the number of books returned,
and the total revenue generated from book rentals.
*/
CREATE TABLE branch_report AS
(SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) AS total_issued_book,
	COUNT(rs.return_id) AS total_returned_book,
	SUM(bk.rental_price) AS revenue
FROM branch AS b
JOIN employees AS e
ON b.branch_id = e.branch_id
JOIN issued_status AS ist
ON ist.issued_emp_id = e.emp_id
LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
JOIN books as bk
ON bk.isbn = ist.issued_book_isbn
Group BY 1, 2);

/*Task 16: Identify Members Issuing High-Risk Books Write a query to identify members who have issued books more than twice with the status "damaged" in the 
books table. Display the member name, book title, and the number of times they've issued damaged books.*/

SELECT ist.issued_member_id, COUNT(rs.book_quality) AS no_of_damage_book
FROM issued_status AS ist
JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE rs.book_quality = 'Damaged'
GROUP BY 1
HAVING COUNT(rs.book_quality) >=2

/*Task 17: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that 
updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an 
input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the 
books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is 
currently not available.
*/

CREATE OR REPLACE PROCEDURE issuing_book(p_book_isbn VARCHAR(18),p_issued_id VARCHAR(10),p_issued_emp_id VARCHAR(10),p_issued_member_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE 
	v_book_title VARCHAR(60);
	v_status VARCHAR(5);
BEGIN
	SELECT book_title INTO v_book_title FROM books WHERE isbn = p_book_isbn;
	SELECT status INTO v_status FROM books WHERE isbn = p_book_isbn;
	IF v_status = 'yes' THEN
		INSERT INTO issued_status
		VALUES
		(p_issued_id,p_issued_member_id,v_book_title,CURRENT_DATE,p_book_isbn,p_issued_emp_id);
		UPDATE books
		SET status = 'no'
		WHERE isbn = p_book_isbn;
		RAISE NOTICE 'Book issued succesfully';
	ELSE 
		RAISE NOTICE 'Sorry the book is not available';
	END IF;	
END;
$$

CALL issuing_book('978-0-525-47535-5', 'IS155','E104','C106') --Not available
CALL issuing_book('978-0-14-118776-1', 'IS155','E104','C106') --Available

