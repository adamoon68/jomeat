<?php
require_once '../config/db.php';

try {
    $foodId = (int) postValue('food_id');
    if ($foodId <= 0) {
        jsonResponse(false, 'Valid food_id is required');
    }

    $pdo = getConnection();
    $stmt = $pdo->prepare('SELECT * FROM food_items WHERE food_id = ?');
    $stmt->execute([$foodId]);
    $food = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$food) {
        jsonResponse(false, 'Food item not found');
    }
    jsonResponse(true, 'Food detail loaded', $food);
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
