
CREATE INDEX idx_orders_status_date_amt 
ON Orders(OrderStatus, OrderDate, TotalAmount);

WITH RestaurantAvgPrice AS (
    SELECT 
        RestaurantID, 
        AVG(Price) AS AvgPrice
    FROM MenuItem
    GROUP BY RestaurantID
)
SELECT 
    m.ItemID, 
    m.ItemName, 
    m.Price, 
    m.RestaurantID
FROM MenuItem m
INNER JOIN RestaurantAvgPrice rap ON m.RestaurantID = rap.RestaurantID
WHERE m.Price > rap.AvgPrice;

CREATE INDEX idx_orders_status_date_amt ON Orders(OrderStatus, OrderDate, TotalAmount);

-- Foreign key indexes for relational joins
CREATE INDEX idx_orders_custid ON Orders(CustomerID);
CREATE INDEX idx_orders_restid ON Orders(RestaurantID);
CREATE INDEX idx_orderitem_orderid ON OrderItem(OrderID);
CREATE INDEX idx_orderitem_itemid ON OrderItem(ItemID);
CREATE INDEX idx_menuitem_restid ON MenuItem(RestaurantID);
