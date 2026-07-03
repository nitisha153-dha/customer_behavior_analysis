use customer_behavior_analysis;
CREATE TABLE sales (
    customer_id VARCHAR(10),
    order_date DATE,
    product_id INT
);
CREATE TABLE menu (
    product_id INT,
    product_name VARCHAR(50),
    price INT

);
CREATE TABLE members (
    customer_id VARCHAR(10),
    join_date DATE
);

INSERT INTO sales VALUES
('A','2021-01-01',1),
('A','2021-01-01',2),
('A','2021-01-07',2),
('A','2021-01-10',3),
('A','2021-01-11',3),
('A','2021-01-11',3),
('B','2021-01-01',2),
('B','2021-01-02',2),
('B','2021-01-04',1),
('B','2021-01-11',1),
('B','2021-01-16',3),
('B','2021-01-16',3),
('C','2021-01-01',3),
('C','2021-01-01',3),
('C','2021-01-07',3);
INSERT INTO menu VALUES
(1,'sushi',10),
(2,'curry',15),
(3,'ramen',12);
INSERT INTO members VALUES
('A','2021-01-07'),
('B','2021-01-09');

# Total amount spent by each customer
SELECT 
    s.customer_id,
    SUM(m.price) AS total_spent
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

# How many days each customer visited
SELECT 
    customer_id,
    COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id;

# First item purchased by each customer
SELECT *
FROM (
    SELECT 
        s.customer_id,
        s.order_date,
        m.product_name,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id 
            ORDER BY s.order_date
        ) AS rn
    FROM sales s
    JOIN menu m
        ON s.product_id = m.product_id
) t
WHERE rn = 1;
# Most purchased item overall
SELECT 
    m.product_name,
    COUNT(*) AS total_orders
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_orders DESC;
# Most popular item for each customer
SELECT *
FROM (
    SELECT 
        s.customer_id,
        m.product_name,
        COUNT(*) AS total_orders,
        RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM sales s
    JOIN menu m
        ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
) t
WHERE rnk = 1;
# First purchase after becoming a member
SELECT *
FROM (
    SELECT 
        s.customer_id,
        s.order_date,
        m.product_name,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date
        ) AS rn
    FROM sales s
    JOIN members mem
        ON s.customer_id = mem.customer_id
    JOIN menu m
        ON s.product_id = m.product_id
    WHERE s.order_date >= mem.join_date
) t
WHERE rn = 1;
# Last item before becoming a member
SELECT *
FROM (
    SELECT 
        s.customer_id,
        s.order_date,
        m.product_name,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date DESC
        ) AS rn
    FROM sales s
    JOIN members mem
        ON s.customer_id = mem.customer_id
    JOIN menu m
        ON s.product_id = m.product_id
    WHERE s.order_date < mem.join_date
) t
WHERE rn = 1;
# Total items and spend before membership
SELECT 
    s.customer_id,
    COUNT(*) AS total_items,
    SUM(m.price) AS total_spent
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
JOIN members mem
    ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;
# Points per customer (simple rule)
SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 2
            ELSE m.price
        END
    ) AS total_points
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY s.customer_id;









