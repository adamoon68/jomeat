<?php
require_once '../config/db.php';

try {
    $foodId = (int) postValue('food_id');
    if ($foodId <= 0) {
        jsonResponse(false, 'Valid food_id is required');
    }

    $pdo = getConnection();
    try {
        $stmt = $pdo->prepare('DELETE FROM food_items WHERE food_id = ?');
        $stmt->execute([$foodId]);
        if ($stmt->rowCount() === 0) {
            jsonResponse(false, 'Food item not found');
        }
        jsonResponse(true, 'Food item deleted successfully');
    } catch (PDOException $deleteError) {
        $update = $pdo->prepare('UPDATE food_items SET availability = ? WHERE food_id = ?');
        $update->execute(['Unavailable', $foodId]);
        jsonResponse(true, 'Food item is used in orders, so it was marked Unavailable');
    }
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
