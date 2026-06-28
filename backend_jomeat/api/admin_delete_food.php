<?php
require_once '../config/db.php';

try {
    $foodId = (int) postValue('food_id');
    if ($foodId <= 0) {
        jsonResponse(false, 'Valid food_id is required');
    }

    $pdo = getConnection();
    $pdo->beginTransaction();

    $existing = $pdo->prepare('SELECT food_id FROM food_items WHERE food_id = ?');
    $existing->execute([$foodId]);

    if (!$existing->fetch(PDO::FETCH_ASSOC)) {
        $pdo->rollBack();
        jsonResponse(false, 'Food item not found');
    }

    $deleteOrders = $pdo->prepare('DELETE FROM orders WHERE food_id = ?');
    $deleteOrders->execute([$foodId]);

    $deleteFood = $pdo->prepare('DELETE FROM food_items WHERE food_id = ?');
    $deleteFood->execute([$foodId]);

    $pdo->commit();
    jsonResponse(true, 'Food item deleted successfully');
} catch (PDOException $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
