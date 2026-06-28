<?php
require_once '../config/db.php';

try {
    $userId = (int) postValue('user_id');
    if ($userId <= 0) {
        jsonResponse(false, 'Valid user_id is required');
    }

    $pdo = getConnection();
    $stmt = $pdo->prepare(
        'SELECT o.*, f.name AS food_name
         FROM orders o
         INNER JOIN food_items f ON o.food_id = f.food_id
         WHERE o.user_id = ?
         ORDER BY o.order_date DESC, o.order_id DESC'
    );
    $stmt->execute([$userId]);
    jsonResponse(true, 'Orders loaded', $stmt->fetchAll(PDO::FETCH_ASSOC));
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
