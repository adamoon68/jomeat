<?php
require_once '../config/db.php';

try {
    $orderId = (int) postValue('order_id');
    if ($orderId <= 0) {
        jsonResponse(false, 'Valid order_id is required');
    }

    $pdo = getConnection();
    $stmt = $pdo->prepare('UPDATE orders SET status = ? WHERE order_id = ?');
    $stmt->execute(['Cancelled', $orderId]);

    if ($stmt->rowCount() === 0) {
        jsonResponse(false, 'Order not found');
    }
    jsonResponse(true, 'Order cancelled successfully');
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
