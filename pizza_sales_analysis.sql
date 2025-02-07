create database pizzahut;

use pizzahut;

select * from pizza_sales.order_details;

-- Basic:

-- querry 1 - Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS 'total_no._of_orders'
FROM
    orders;

-- querry 2 - Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(o.quantity * p.price)) AS 'total_revenue'
FROM
    order_details o
        JOIN
    pizzas p USING (pizza_id);

-- querry3 - Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizzas p
        LEFT JOIN
    pizza_types pt USING (pizza_type_id)
ORDER BY price DESC
LIMIT 1;

-- querry 4 - Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(o.quantity) AS total_quantity
FROM
    order_details o
        JOIN
    pizzas p USING (pizza_id)
GROUP BY size
ORDER BY total_quantity DESC;

-- querry 5 - List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p USING (pizza_type_id)
        JOIN
    order_details od USING (pizza_id)
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- INTERMEDIATE QUERRY

-- QUERRY 6 - Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p USING (pizza_type_id)
        JOIN
    order_details od USING (pizza_id)
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- QUERRY 7 - Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS total_order
FROM
    orders
GROUP BY HOUR(order_time);

-- QUERRY 8 - find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS 'total_orders'
FROM
    pizza_types pt
GROUP BY category;

-- querry 9 - Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS 'avg_number_of_pizzas_ordered'
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od USING (order_id)
    GROUP BY o.order_date) AS order_quantity;

-- QUERRY 10 - Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(od.quantity * p.price) AS 'revenue'
FROM
    pizza_types pt
        JOIN
    pizzas p USING (pizza_type_id)
        JOIN
    order_details od USING (pizza_id)
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- OR


SELECT 
    name, category, SUM(quantity * price) AS 'total_revenue'
FROM
    pizza_types pt
        LEFT JOIN
    pizzas p USING (pizza_type_id)
        LEFT JOIN
    order_details od USING (pizza_id)
GROUP BY name , category
ORDER BY total_revenue DESC
LIMIT 3;


-- Advanced:

-- QUERRY 11 - Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(o.quantity * p.price)) AS 'total_revenue'
                FROM
                    order_details o
                        JOIN
                    pizzas p USING (pizza_id)) * 100,
            2) AS total_revenue
FROM
    pizza_types pt
        JOIN
    pizzas p USING (pizza_type_id)
        JOIN
    order_details od USING (pizza_id)
GROUP BY pt.category
ORDER BY total_revenue DESC;

-- OR

SELECT 
    category,
    round((SUM(quantity * price) / (SELECT 
            ROUND(SUM(quantity * price), 2)
        FROM
            order_details od
                JOIN
            pizzas p USING (pizza_id))) * 100,2) AS 'average_revenue'
FROM
    pizza_types pt
        LEFT JOIN
    pizzas p USING (pizza_type_id)
        LEFT JOIN
    order_details od USING (pizza_id)
GROUP BY category;


-- QUERRY 12 - Analyze the cumulative revenue generated over time

select order_date, sum(total_revenue) over(order by order_date) as cum_revenue
from
(select o.order_date, sum(od.quantity*p.price) as "total_revenue" from pizzas p 
join order_details od
using(pizza_id)
join orders o
on o.order_id = od.order_id
group by o.order_date) as sales;

-- OR

with my_cte as 
(select order_date,sum(quantity*price) as "total" from orders o
left join order_details od
using(order_id)
join pizzas p
using(pizza_id)
group by order_date)

select order_date,
sum(total) over(order by order_date) as "cummulative_sum" from my_cte;


-- QUERRY 13 - Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,total_revenue from
(select category,name,total_revenue,
rank() over(partition by category order by total_revenue desc) as rn
from
(select pt.category,pt.name ,sum(od.quantity*p.price) as "total_revenue"
from pizza_types pt
join pizzas p
using(pizza_type_id)
join order_details od
using(pizza_id)
group by pt.category,pt.name ) as A) as B
where rn<=3;







