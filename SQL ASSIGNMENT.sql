select * from customer_info;

select * from sales;

select * from products;


---Q1 List all customers located in Nairobi.Show fuul name and location
select * from customer_info where location = 'Nairobi';

---Q2 Display each customer along with the products they purchased. Include full_name, product_name, and Price.
  

select ci.full_name, p.product_name, p.price
from customer_info ci
join products p on ci.customer_id = p.customer_id;

----Q3: Write a SQL query to find the total sales amount for each customer. Display full_name and the total amount spent, sorted in descending order.


select ci.full_name, sum(s.total_sales) as total_amount
from sales s
join customer_info ci on s.customer_id = ci.customer_id
group by ci.full_name
order by total_amount desc;


-----Q4: Write a SQL query to find all customers who have purchased products priced above 10,000.

select distinct ci.full_name, p.price
from customer_info ci
join products p on ci.customer_id = p.customer_id 
join sales s on p.product_id = s.product_id 
where p.price>10000;


-----Q5: Write a SQL query to find the top 3 customers with the highest total sales.

select ci.full_name, sum(total_sales) as total_amount
from sales s
join customer_info ci on s.customer_id = ci.customer_id 
group by full_name
order by total_amount desc
limit 3;


----Q6: Write a CTE that calculates the average sales per customer and then returns customers whose total sales are above that average.

with total_sales as (
    select customer_id, sum(total_sales) AS total_amount
    from sales s
    group by customer_id
),
average_sales as (
    SELECT avg(total_sales) AS avg_sales
    FROM sales s
)
SELECT ci.full_name, s.total_sales
FROM sales s 
JOIN customer_info ci ON s.customer_id = ci.customer_id
JOIN average_sales a on s.total_sales > a.avg_sales;


------Q7: Write a Window Function query that ranks products by their total sales in descending order. Display product_name, total_sales, and rank.
select p.product_name, 
sum(s.total_sales) as total_sales,
rank ()over (order by sum(s.total_sales) desc) as sales_rank
from products p 
join sales s on p.product_id = s.product_id
group by p.product_name; 


---Q8: Create a View called high_value_customers that lists all customers with total sales greater than 15,000.
create view high_value_customers as 
select ci.full_name, ci.customer_id, sum(s.total_sales) as total_sales 
from customer_info ci 
join sales s on ci.customer_id = s.customer_id 
group by ci.customer_id, ci.full_name 
having sum(s.total_sales) > 15000;

select * from high_value_customers;

----Q9: Create a Stored Procedure that accepts a location as input and returns all customers and their total spending from that location.

CREATE PROCEDURE GetCustomersByLocation(IN p_location VARCHAR(100))
BEGIN
    SELECT 
        c.customer_id,
        c.full_name,
        c.location,
        SUM(s.total_sales) AS total_spending
    FROM customer_info c
    JOIN sales s ON s.customer_id = c.customer_id
    WHERE c.location = p_location
    GROUP BY c.customer_id, c.full_name, c.location
    ORDER BY total_spending DESC;
END; 

CALL GetCustomersByLocation('kakamega');
 

----Q10: Write a recursive query to display all sales transactions in order by sales_id, along with a running total of sales.

WITH RECURSIVE sales_running_total AS (
    SELECT 
        s.sales_id,s.total_sales, s.customer_id, s.product_id,
        s.total_sales AS running_total
    FROM sales s
    WHERE s.sales_id = (SELECT MIN(sales_id) FROM sales)
    
    UNION ALL
    
    SELECT 
        s.sales_id,
        s.total_sales,
        s.customer_id,
        s.product_id,
        srt.running_total + s.total_sales AS running_total
    FROM sales s
    JOIN sales_running_total srt ON s.sales_id = srt.sales_id + 1
)
SELECT * FROM sales_running_total;

WITH RECURSIVE Sales_CTE AS (
    -- Anchor member: first (lowest) sales_id
    SELECT 
        s.sales_id,
        s.total_sales,
        s.total_sales AS running_total
    FROM sales s
    WHERE s.sales_id = (SELECT MIN(sales_id) FROM sales)

    UNION ALL

    -- Recursive member: pick the next sales_id and add to running total
    SELECT 
        s.sales_id,
        s.total_sales,
        c.running_total + s.total_sales AS running_total
    FROM sales s
    JOIN Sales_CTE c 
        ON s.sales_id = c.sales_id + 1
)
SELECT * 
FROM Sales_CTE;


Q11: The following query is running slowly:

SELECT * FROM sales WHERE total_sales > 5000;
Explain two changes you would make to improve its performance and then write the optimized SQL query.

SELECT * FROM sales WHERE total_sales > 5000;
Explain two changes you would make to improve its performance and then write the optimized SQL query. 

-- How to improve performance: 
--1. Add an index on total_sales so filtering is faster.
create index idx_sales_total on sales (total_sales);
--2. select only needed columns instead of* 
select sales_id, product_id, customer_id, total_sales 
from sales 
where total_sales > 5000; 

Q12: Create an index on a column that would improve queries filtering by customer location, then write a query to test the improvement.

create index idx_customer_location on customer_info(location); 
---- test query 
select customer_id, full_name, location 
from customer_info 
where location = 'Nairobi'; 

select * from customer_info 
where location = 'Nyeri';


Q13: Redesign the given schema into 3rd Normal Form (3NF) and provide the new CREATE TABLE statements.

CREATE TABLE customer_info(
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    location VARCHAR(90)
);
-- customer_info 
  -customer_id (pk) 
  - full_name 
  - location 
 
-- products 
  - product_id(pk) 
  - product_name 
  
-- sales 
  - sales_id(pk) 
  - total_sales
  - customer_id (fk) 
  -product_id (fk)

create table customer_info(
    customer_id serial primary key,
    full_name varchar(120),
    location varchar(90)
);


create table products(
    product_id serial primary key,
    product_name varchar(120),
    price float
);

create table sales(
    sales_id serial primary key,
    customer_id int references customer_info(customer_id),
    product_id INT references products(product_id),
    total_sales float
);

Q14: Create a Star Schema design for analyzing sales by product and customer location. Include the fact table and dimension tables with their fields.

create table fact_sales (
    sales_id serial primary key,
    customer_id (FK),
    location_id (FK)
    product_id (FK),
    total_sales float
);
-- Dimension Tables: dim_customer, dim_product, dim_location 
create table dim_customer (
    customer_id serial primary key,
    full_name varchar(120)
);

create table dim_location (
    location_id primary key,
    location varchar(90)
);

create table dim_product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(120),
    price FLOAT
);

Q15: Explain a scenario where denormalization would improve performance for reporting queries, and demonstrate the SQL table creation for that denormalized structure.

*1. Read-Heavy Applications: When you read data much more than you write it
 2. Performance Critical: When query speed is more important than storage space
 3. Reporting Systems: When complex analytics require fast data access
 4. Data Warehousing: For analytical workloads

-- Example 
-- SQL table creation dernomalized by combining customer_info, product and sales into one reporting table. 
CREATE TABLE denorm_sales_report (
    sales_id SERIAL PRIMARY KEY,
    full_name VARCHAR(120),
    location VARCHAR(90),
    product_name VARCHAR(120),
    price FLOAT,
    total_sales FLOAT
);
