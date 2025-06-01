# Library_System_Building_With_SQL
A comprehensive SQL-based Library Management System project that includes CRUD operations, data analysis queries, performance reports, and stored procedures for book issuing and returns, built for PostgreSQL.

---

# 📚 **Project Tasks**

---

## 🔧 **CRUD Operations**

**Task 1: Create a New Book Record**

```sql
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
```

**Task 2: Update an Existing Member's Address**

**Task 3: Delete a Record from the Issued Status Table**
**Objective**: Delete the record with `issued_id = 'IS104'` from the `issued_status` table.

**Task 4: Retrieve All Books Issued by a Specific Employee**
**Objective**: Select all books issued by the employee with `emp_id = 'E101'`.

**Task 5: List Members Who Have Issued More Than One Book**
**Objective**: Use `GROUP BY` to find members who have issued more than one book.

---

## 📑 **CTAS (Create Table As Select)**

**Task 6: Create Summary Tables**
**Objective**: Use CTAS to generate new tables based on query results – each book and total `book_issued_cnt`.

---

## 📊 **Data Analysis & Findings**

**Task 7: Retrieve All Books in a Specific Category**

**Task 8: Find Total Rental Income by Category**

**Task 9: List Members Who Registered in the Last 180 Days**

**Task 10: List Employees with Their Branch Manager's Name and Branch Details**

**Task 11: Create a Table of Books with Rental Price Above a Certain Threshold**

**Task 12: Retrieve the List of Books Not Yet Returned**

---

## 🧠 **Advanced SQL Operations**

**Task 13: Identify Members with Overdue Books**
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.

**Task 14: Update Book Status on Return**
Write a query to update the status of books in the `books` table to `"yes"` when they are returned (based on entries in the `return_status` table).

**Task 15: Branch Performance Report**
Create a query that generates a performance report for each branch, showing:

* Number of books issued
* Number of books returned
* Total revenue generated from book rentals

**Task 16: Identify Members Issuing High-Risk Books**
Write a query to identify members who have issued books more than twice with the status `"damaged"` in the `books` table. Display:

* Member name
* Book title
* Number of times they've issued damaged books

---

## ⚙️ **Stored Procedure**  

**Task 17: Manage Book Status**
**Objective**: Create a stored procedure to manage the status of books in a library system.

**Description**:
Write a stored procedure that updates the status of a book based on its issuance or return:

* If a book is issued, the status should change to `'no'`.
* If a book is returned, the status should change to `'yes'`. **(Task 14)**

---
## ✅ Conclusion
**Working on this project gave me hands-on experience with real-world SQL scenarios in a library management system. I practiced everything from basic CRUD operations and CTAS to more advanced queries like performance reporting and stored procedures. Each task helped me strengthen my understanding of relational databases, query design, and data analysis. This project has been a solid step in improving my SQL skills and preparing for more complex database challenges.**
