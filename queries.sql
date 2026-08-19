SELECT 
    c.CustomerID,
    c.FullName,
    c.Email,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalSpent,
    DENSE_RANK() OVER (ORDER BY SUM(o.TotalAmount) DESC) AS LoyaltyRank
FROM Customer c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderStatus = 'Delivered'
GROUP BY c.CustomerID, c.FullName, c.Email
ORDER BY LoyaltyRank ASC;
SELECT 
    r.RestaurantID,
    r.RestaurantName,
    r.CuisineType,
    COUNT(DISTINCT o.OrderID) AS CompletedOrders,
    SUM(o.TotalAmount) AS TotalRevenue,
    AVG(o.TotalAmount) AS AvgOrderValue
FROM Restaurant r
INNER JOIN Orders o ON r.RestaurantID = o.RestaurantID
WHERE o.OrderStatus = 'Delivered'
GROUP BY r.RestaurantID, r.RestaurantName, r.CuisineType
HAVING SUM(o.TotalAmount) > 10000.00
ORDER BY TotalRevenue DESC;
WITH DailySales AS (
    SELECT 
        CAST(OrderDate AS DATE) AS OrderDay,
        COUNT(OrderID) AS TotalOrders,
        SUM(TotalAmount) AS DailyRevenue
    FROM Orders
    WHERE OrderStatus = 'Delivered'
    GROUP BY CAST(OrderDate AS DATE)
)
SELECT 
    OrderDay,
    TotalOrders,
    DailyRevenue,
    SUM(DailyRevenue) OVER (ORDER BY OrderDay ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotalRevenue
FROM DailySales
ORDER BY OrderDay ASC;
SELECT 
    m.ItemID,
    m.ItemName,
    m.Price,
    r.RestaurantName
FROM MenuItem m
INNER JOIN Restaurant r ON m.RestaurantID = r.RestaurantID
WHERE m.Price > (
    SELECT AVG(m2.Price)
    FROM MenuItem m2
    WHERE m2.RestaurantID = m.RestaurantID
)
ORDER BY m.Price DESC;
