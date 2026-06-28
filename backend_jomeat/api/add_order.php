<?php
require_once '../config/db.php';

try {
    $userId = (int) postValue('user_id');
    $foodId = (int) postValue('food_id');
    $quantity = (int) postValue('quantity');
    $notes = postValue('notes');

    if ($userId <= 0 || $foodId <= 0 || $quantity <= 0) {
        jsonResponse(false, 'Valid user_id, food_id and quantity are required');
    }

    $pdo = getConnection();
    $stmt = $pdo->prepare('SELECT price, availability FROM food_items WHERE food_id = ?');
    $stmt->execute([$foodId]);
    $food = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$food) {
        jsonResponse(false, 'Food item not found');
    }
    if ($food['availability'] !== 'Available') {
        jsonResponse(false, 'Food item is unavailable');
    }

    $totalPrice = (float) $food['price'] * $quantity;
    $insert = $pdo->prepare(
        'INSERT INTO orders (user_id, food_id, quantity, total_price, notes) VALUES (?, ?, ?, ?, ?)'
    );
    $insert->execute([$userId, $foodId, $quantity, $totalPrice, $notes]);
    jsonResponse(true, 'Order added successfully');
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
