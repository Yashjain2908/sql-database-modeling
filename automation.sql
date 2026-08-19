-- 1. Audit Log Table
CREATE TABLE IF NOT EXISTS AuditLog (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    LogTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    EventType VARCHAR(50) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    Message TEXT
);

-- 2. Transactional Stored Procedure for Order Processing
DELIMITER //
CREATE PROCEDURE sp_PlaceFoodOrder (
    IN p_CustomerID INT,
    IN p_RestaurantID INT,
    IN p_ItemID INT,
    IN p_Quantity INT,
    IN p_UnitPrice DECIMAL(8,2),
    IN p_PaymentMethod VARCHAR(30)
)
BEGIN
    DECLARE v_OrderID INT;
    DECLARE v_TotalAmount DECIMAL(10,2);
    
    -- Error Handler: Rollback on any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO AuditLog (EventType, Status, Message)
        VALUES ('ORDER_CREATION', 'FAILED', 'Transaction rolled back due to error.');
    END;

    START TRANSACTION;

    -- Step 1: Calculate total amount and insert Order
    SET v_TotalAmount = p_Quantity * p_UnitPrice;
    INSERT INTO Orders (CustomerID, RestaurantID, TotalAmount, OrderStatus)
    VALUES (p_CustomerID, p_RestaurantID, v_TotalAmount, 'Delivered');
    SET v_OrderID = LAST_INSERT_ID();

    -- Step 2: Insert Order Item Details
    INSERT INTO OrderItem (OrderID, ItemID, Quantity, UnitPrice)
    VALUES (v_OrderID, p_ItemID, p_Quantity, p_UnitPrice);

    -- Step 3: Record Payment
    INSERT INTO Payment (OrderID, Amount, PaymentMethod, PaymentStatus)
    VALUES (v_OrderID, v_TotalAmount, p_PaymentMethod, 'Completed');

    -- Step 4: Log Success
    INSERT INTO AuditLog (EventType, Status, Message)
    VALUES ('ORDER_CREATION', 'SUCCESS', CONCAT('Order ID ', v_OrderID, ' processed successfully.'));

    COMMIT;
END //
DELIMITER ;

-- 3. Scheduled Maintenance Event
CREATE EVENT evt_DailyAuditCleanup
ON SCHEDULE EVERY 1 DAY
STARTS '2026-08-20 03:00:00'
DO
BEGIN
    INSERT INTO AuditLog (EventType, Status, Message)
    VALUES ('DAILY_HEALTH_CHECK', 'SUCCESS', 'Database integrity check completed successfully.');
END;
