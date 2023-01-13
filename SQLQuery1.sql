-- These SQL queries start from "beginner" to "advanced".

-- A. Provide a list all of the Customer ID, Customer Names, and States and sort the list in alphabetical order by Customer Name.

SELECT CustomerID, CustomerName, CustomerState FROM CUSTOMER_T ORDER BY CustomerName ASC;

-- B. Provide a list of all of the Customer ID, Customer Names, and City, and sort the list by city with the Customer Names in alphabetical order within each city.

SELECT CustomerID, CustomerName, CustomerCity FROM CUSTOMER_T ORDER BY CustomerCity, CustomerName ASC;

-- C. List the customers showing the Customer ID, Customer Name, address, and sales rep name in alphabetical order by customer name

SELECT Customer_T.CustomerID, Customer_T.CustomerName, Customer_T.CustomerStreet, 
Employee_T.EmployeeFirstName + ' ' + EMPLOYEE_T.EmployeeLastName AS SalesRepName
FROM Customer_T FULL OUTER JOIN EMPLOYEE_T ON Customer_T.SalesRepID = EMPLOYEE_T.EmployeeID WHERE SALESREPID IS NOT NULL ORDER BY SalesRepName ASC;

-- D. Which employees have not completed course ID = 100? Hint: name of employee only, and the best way to determine this is by having a subselect statement to determine the EmployeeIDs that have completed CourseID 100, and then have a the select statement use the output of the subselect to determine which of all of the employees are not in the list provided by the subselect.

SELECT EmployeeFirstName, EmployeeLastName FROM EMPLOYEE_T WHERE EmployeeID NOT IN (Select EmployeeID FROM EMPLOYEE_COURSE_T WHERE CourseID =100);

-- E. How many sales reps does PSC have? Hint: I want to know how many, not who they are. Also, realize that all sales reps are employees, but not all employees are sales reps. Also, keep in mind that being a sales rep does not mean that they have actually sold anything.

SELECT COUNT(*) 'Number of SalesReps' FROM SALES_REPRESENTATIVE;

-- F. List all of the sales reps sorted by largest commission rate first Hint: name and sales commission rate

SELECT SALES_REPRESENTATIVE.CommissionRate, EMPLOYEE_T.EmployeeFirstName +' ' + EMPLOYEE_T.EmployeeLastName AS 'Sales Rep Name' FROM SALES_REPRESENTATIVE FULL OUTER JOIN EMPLOYEE_T ON SALES_REPRESENTATIVE.EmployeeID = EMPLOYEE_T.EmployeeID WHERE CommissionRate IS NOT NULL ORDER BY SALES_REPRESENTATIVE.CommissionRate DESC;

-- G. Who are the manager(s) of the sales reps? Hint: name of the manager only.

SELECT DISTINCT A.EmployeeFirstName + ' ' +  A.EmployeelastName AS 'Manager of the Sales Rep'  FROM EMPLOYEE_T B INNER JOIN EMPLOYEE_t A
ON B.ManagerID = A.EmployeeID WHERE A.EmployeeID IN (SELECT EmployeeID FROM EMPLOYEE_T WHERE ManagerID IS NOT NULL);    

-- H. List the employees’ names who report to a Sales Manager. Hint: Your SQL statement will need to determine the manager first before it can determine the employees that report to him/her.

SELECT EmployeeFirstName, EmployeeLastName
FROM EMPLOYEE_T WHERE ManagerID IN(SELECT DISTINCT EMP.ManagerID FROM Employee_T AS EMP, SALES_REPRESENTATIVE AS S
WHERE EMP.EmployeeID = S.EmployeeID);

-- I. Who is the manager of the manager of the sales reps? Hint: Show the name of the sales rep’s manager’s manager only, and your single SQL statement will need to determine the sales rep’s manager before it can determine the manager of the sales rep’s manager.
SELECT DISTINCT A.EmployeeFirstName + ' ' +  A.EmployeelastName AS 'Manager of Manager of Sales Representatives' 
FROM EMPLOYEE_t B INNER JOIN EMPLOYEE_t A ON B.ManagerID = A.EmployeeID WHERE A.EmployeeID IN (SELECT EmployeeID FROM EMPLOYEE_t 
WHERE ManagerID IS NULL);

-- J. List the employee names of those that report directly to the manager of the sales manager(s). Hint: Your SQL statement must determine the sales manager before it can determine manager of the sales rep’s manager, and then it must determine the names of those that report to the manager of the sales rep’s manager.

SELECT EmployeeFirstName + ' ' + EmployeeLastName AS 'Employees who report to manager of sales manager'
FROM EMPLOYEE_T WHERE ManagerID IN(SELECT DISTINCT ManagerID FROM EMPLOYEE_T WHERE EmployeeID 
IN (SELECT DISTINCT A.ManagerID FROM EMPLOYEE_T AS A, SALES_REPRESENTATIVE AS B WHERE A.EmployeeID = B.EmployeeID))

-- K. Provide an inventory report that lists the most costly items first. The inventory report should include product identification numbers, product descriptions, unit prices, supplier names, cost, and quantity supplied. Hint: the most costly item is the one in which the product of cost and quantity yields the largest value. Be careful not to confuse cost with price. Price is the value that the products are sold to the customers, and cost is the value that is paid to purchase the products from the suppliers. Also, be aware that the word “product” above refers to the result of multiplication (i.e., the product of cost and quantity).

SELECT A.ProductID, A.ProductDescription, A.UnitPrice, B.SupplierName, C.ProductCost, C.Purchased_Quantity
FROM PRODUCT_t AS A, PRODUCT_SUPPLIER_t AS C, SUPPLIER_t AS B WHERE A.ProductID = C.ProductID
AND C.SupplierID = B.SupplierID ORDER BY C.ProductCost * C.Purchased_Quantity DESC;

-- L. List all of the employees in alphabetical order and each course they have completed in order of date completed. Hint: some employees might not have taken any courses.

SELECT A.EmployeeFirstName + ' ' + A.EmployeeLastName AS EmployeeName, B.CourseDescription FROM EMPLOYEE_T AS A, EMPLOYEE_COURSE_T AS C, COURSE_T AS B WHERE A.EmployeeID = C.EmployeeID 
AND C.CourseID = B.CourseID AND C.CompletionDate IS NOT NULL ORDER BY A.EmployeeFirstName,A.EmployeeLastName , C.CompletionDate;









