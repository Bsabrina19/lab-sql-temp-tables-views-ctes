USE sakila;

# Creating a Customer Summary Report


## Step 1: Create a View
DROP VIEW IF EXISTS customer_rental_summary;
CREATE VIEW customer_rental_summary AS
SELECT c.customer_id, c.first_name, c.last_name, c.email, COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;
SELECT * FROM customer_rental_summary;

## Step 2: Create a Temporary Table
DROP TEMPORARY TABLE IF EXISTS  customer_payment_summary;
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT crs.customer_id, crs.first_name, crs.last_name, crs.email, SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
JOIN rental r ON crs.customer_id = r.customer_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY crs.customer_id, crs.first_name, crs.last_name, crs.email;
SELECT * FROM  customer_payment_summary;


## Step 3: Create a CTE and the Customer Summary Report
WITH customer_summary AS (
    SELECT crs.customer_id, crs.first_name, crs.last_name, crs.email, crs.rental_count, cps.total_paid
    FROM customer_rental_summary crs
    JOIN customer_payment_summary cps ON crs.customer_id = cps.customer_id
)
SELECT customer_id, first_name, last_name, email, rental_count, total_paid, 
       (total_paid / NULLIF(rental_count, 0)) AS average_payment_per_rental
FROM customer_summary
ORDER BY total_paid DESC;


