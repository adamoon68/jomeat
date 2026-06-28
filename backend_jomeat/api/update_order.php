<?php
require_once '../config/db.php';

try {
    $orderId = (int) postValue('order_id');
    $quantity = (int) postValue('quantity');
    $notes = postValue('notes');

    if ($orderId <= 0 || $quantity <= 0) {
        jsonResponse(false, 'Valid order_id and quantity are required');
    }

    $pdo = getConnection();
    $stmt = $pdo->prepare(
        'SELECT o.status, f.price
         FROM orders o
         INNER JOIN food_items f ON o.food_id = f.food_id
         WHERE o.order_id = ?'
    );
    $stmt->execute([$orderId]);
    $order = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$order) {
        jsonResponse(false, 'Order not found');
    }
    if ($order['status'] !== 'Pending') {
        jsonResponse(false, 'Only pending orders can be updated');
    }

    $totalPrice = (float) $order['price'] * $quantity;
    $update = $pdo->prepare('UPDATE orders SET quantity = ?, total_price = ?, notes = ? WHERE order_id = ?');
    $update->execute([$quantity, $totalPrice, $notes, $orderId]);
    jsonResponse(true, 'Order updated successfully');
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
