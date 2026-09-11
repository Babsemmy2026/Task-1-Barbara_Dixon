Use borders;

-- 1. Basic Aggregation
SELECT 
    COUNT(OrderID) AS total_orders,
    SUM(Quantity) AS total_units_sold,
    ROUND(SUM(TotalPrice), 2) AS total_revenue,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value,
    ROUND(AVG(UnitPrice), 2) AS avg_unit_price
FROM orders_cleaned;

-- 2. Revenue & Volume by Product (GROUP BY & ORDER BY)
SELECT 
    Product,
    COUNT(OrderID) AS order_count,
    SUM(Quantity) AS total_units_sold,
    ROUND(SUM(TotalPrice), 2) AS total_revenue,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value
FROM orders_cleaned
GROUP BY Product
ORDER BY total_revenue DESC;

-- 3. Order Status & Fulfillment Risk Analysis 
-- What is the revenue loss and percentage breakdown associated with cancelled and returned orders?
SELECT 
    OrderStatus, 
    COUNT(OrderID) AS order_count, 
    ROUND(COUNT(OrderID) * 100.0 / (SELECT COUNT(*) FROM orders_cleaned), 2) AS percentage_of_total, 
    ROUND(SUM(TotalPrice), 2) AS total_revenue, 
    ROUND(AVG(TotalPrice), 2) AS avg_order_value
FROM orders_cleaned 
GROUP BY OrderStatus 
ORDER BY order_count DESC 
LIMIT 0, 5000;

-- 4. Customer Acquisition Channel Performance
SELECT 
    ReferralSource,
    COUNT(OrderID) AS order_count,
    ROUND(SUM(TotalPrice), 2) AS total_revenue,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value
FROM orders_cleaned
GROUP BY ReferralSource
ORDER BY total_revenue DESC;

-- 5. Filtering High-Value Purchases
SELECT 
    OrderID,
    Date,
    CustomerID,
    Product,
    Quantity,
    UnitPrice,
    TotalPrice,
    OrderStatus
FROM orders_cleaned
WHERE TotalPrice > 2500
ORDER BY TotalPrice DESC
Limit 5;

-- 6. Which product categories generate the highest gross revenue and average order volume?
SELECT 
    Product,
    COUNT(OrderID) AS total_orders,
    SUM(Quantity) AS total_units_sold,
    ROUND(SUM(TotalPrice), 2) AS gross_revenue,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value,
    ROUND(AVG(UnitPrice), 2) AS avg_unit_price
FROM orders_cleaned
GROUP BY Product
ORDER BY gross_revenue DESC;

-- 7. Which acquisition channels generate the highest revenue and how many lost vs. delivered orders originate from each?
SELECT 
    ReferralSource,
    COUNT(OrderID) AS total_orders,
    ROUND(SUM(TotalPrice), 2) AS total_revenue,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value,
    SUM(CASE WHEN OrderStatus = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN OrderStatus IN ('Cancelled', 'Returned') THEN 1 ELSE 0 END) AS lost_orders
FROM orders_cleaned
GROUP BY ReferralSource
ORDER BY total_revenue DESC;

-- 8. How do payment methods compare in order volume, average order size, and cancellation rates?
SELECT 
    PaymentMethod,
    COUNT(OrderID) AS total_orders,
    ROUND(SUM(TotalPrice), 2) AS total_revenue,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value,
    ROUND(AVG(ItemsInCart), 2) AS avg_cart_size,
    SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
FROM orders_cleaned
GROUP BY PaymentMethod
ORDER BY total_orders DESC;

-- 9. What proportion of revenue comes from repeat customers versus single-purchase customers?
SELECT 
    customer_order_type,
    COUNT(CustomerID) AS customer_count,
    SUM(total_orders) AS total_orders,
    ROUND(SUM(total_revenue), 2) AS total_revenue
FROM (
    SELECT 
        CustomerID,
        COUNT(OrderID) AS total_orders,
        SUM(TotalPrice) AS total_revenue,
        CASE 
            WHEN COUNT(OrderID) > 1 THEN 'Repeat Customer'
            ELSE 'One-Time Customer'
        END AS customer_order_type
    FROM orders_cleaned
    GROUP BY CustomerID
) sub
GROUP BY customer_order_type;
