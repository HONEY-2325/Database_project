-- VIEWS :


-- VIEW TO CHECK FOR ANY MACHINERY AVAILABLE ----

create or replace view avaialbilty as
select
		u.fname||' '||u.lname as owner,
		m.name as machinery_name,
		m.available,
		m.farmer_id as email,
		cd.phone phone_number
from
	machinery m
	join f2c_user u on m.farmer_id=u.email
	join contact_detail cd on cd.user_id=u.email
	where m.available='TRUE';
	
-----------------------------------------------------------------------------------
/*  Displays all products offered by a specific farmer,*/
CREATE VIEW farmer_products AS
SELECT
    f.farmer_id,
    u.fname || ' ' || u.lname AS farmer_name,
    p.product_id,
    p.name AS product_name,
    p.category_id,
    c.category_name,
    p.price,
    p.available_units,
    p.in_stock
FROM
    farmer f
JOIN
	f2c_user u ON f.farmer_id=u.email
JOIN
    product p ON f.farmer_id = p.farmer_id
JOIN
    category c ON p.category_id = c.category_id;
	
--------------------------------------------------------------------------------------
/* A view listing the order history for each customer.*/
CREATE VIEW customer_order_history AS
SELECT
    c.customer_id,
    u.fname || ' ' || u.lname AS farmer_name,
    o.order_id,
    o.order_date
FROM
    customer c
JOIN
	f2c_user u ON c.customer_id=u.email
JOIN 
	f2c_order o ON c.customer_id = o.customer_id;

--------------------------------------------------------------------------------------
/* Displays reviews for a specific product, including the reviewer's name and rating.*/
CREATE VIEW product_reviews AS
SELECT
    r.review_id,
    r.product_id,
    p.name AS product_name,
    r.customer_id,
    u.fname || ' ' || u.lname AS customer_name,
    r.review,
    r.rating,
    r.review_date
FROM
    review r
JOIN
    product p ON r.product_id = p.product_id
JOIN
    f2c_user u ON r.customer_id = u.email;
	
--------------------------------------------------------------------------------------
/* Displays products categorized by their respective categories, making it easy for customers to browse products*/
CREATE VIEW product_categories AS
SELECT
    c.category_name,
    p.product_id,
    p.name AS product_name,
    p.price,
    p.available_units,
    p.in_stock,
    u.fname || ' ' || u.lname AS farmer_name
FROM
    product p
JOIN
    category c ON p.category_id = c.category_id
JOIN
    farmer f ON p.farmer_id = f.farmer_id
JOIN
	f2c_user u ON f.farmer_id=u.email
	
--------------------------------------------------------------------------------------
/*Displays the top products based on ratings and review counts*/
CREATE VIEW popular_products AS
SELECT
    p.product_id,
    p.name,
    COUNT(op.order_id) AS order_count
FROM
    order_product op
    JOIN product p ON op.product_id = p.product_id
GROUP BY
    p.product_id,
    p.name
ORDER BY
    order_count DESC
	limit 10;

--------------------------------------------------------------------------------------
/*Displays information about machinery rented by farmers, including rental dates and the rented machinery.*/
CREATE VIEW farmer_machinery_rentals AS
SELECT
    f.farmer_id,
    u.fname || ' ' || u.lname AS farmer_name,
    m.machinery_id,
    m.name AS machinery_name,
    r.rented_date,
    r.returned_date,
    r.rented_by
FROM
    rented r
JOIN
    Machinery m ON r.machinery_id = m.machinery_id
JOIN
    farmer f ON r.rented_by = f.farmer_id
JOIN
	f2c_user u ON f.farmer_id=u.email;
	
--------------------------------------------------------------------------------------
/*Displays total sales by category.*/
CREATE VIEW category_summary AS
SELECT
    c.category_id,
    c.category_name,
    COUNT(op.order_id) AS order_count
FROM
    order_product op
    JOIN product p ON op.product_id = p.product_id
    JOIN category c ON p.category_id = c.category_id
GROUP BY
    c.category_id,
    c.category_name;
	
--------------------------------------------------------------------------------------
/* Displays payment information for customers, including payment dates and amounts.*/
CREATE VIEW payment_history AS
SELECT
    p.payment_id,
    p.customer_id,
    u.fname || ' ' || u.lname AS customer_name,
    p.order_id,
    o.total_price,
    p.payment_date,
    p.amount
FROM
    payment p
JOIN
    f2c_order o ON p.order_id = o.order_id
JOIN
    f2c_user u ON p.customer_id = u.email;
	
-----------------------------------------------------------
	
CREATE OR REPLACE VIEW farmer_orders AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_name AS customer_name,
    o.total_price,
    o.order_date,
    o.shipping_price,
    o.delivery_address_id,
    o.delivery_date,
    o.order_status,
    o.quantity,
    p.farmer_id,
    f.farmer_name AS farmer_name
FROM
    f2c_order o
JOIN
    customer c ON o.customer_id = c.customer_id
JOIN
    order_product op ON o.order_id = op.order_id
JOIN
    product p ON op.product_id = p.product_id
JOIN
    farmer f ON p.farmer_id = f.farmer_id;
	
select * from farmer_orders where farmer_id;



