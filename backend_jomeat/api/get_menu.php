<?php
require_once '../config/db.php';

try {
    $category = postValue('category');
    $pdo = getConnection();

    if ($category !== '') {
        $stmt = $pdo->prepare('SELECT * FROM food_items WHERE category = ? ORDER BY food_id DESC');
        $stmt->execute([$category]);
    } else {
        $stmt = $pdo->query('SELECT * FROM food_items ORDER BY food_id DESC');
    }

    jsonResponse(true, 'Menu loaded', $stmt->fetchAll(PDO::FETCH_ASSOC));
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
