<?php
require_once '../config/db.php';

try {
    $foodId = (int) postValue('food_id');
    $name = postValue('name');
    $description = postValue('description');
    $category = postValue('category');
    $price = (float) postValue('price');
    $preparationTime = (int) postValue('preparation_time');
    $availability = postValue('availability', 'Available');

    if ($foodId <= 0 || $name === '' || $category === '' || $price <= 0) {
        jsonResponse(false, 'food_id, name, category and valid price are required');
    }
    if (!in_array($availability, ['Available', 'Unavailable'])) {
        jsonResponse(false, 'Invalid availability');
    }

    $pdo = getConnection();
    $existing = $pdo->prepare('SELECT image_name FROM food_items WHERE food_id = ?');
    $existing->execute([$foodId]);
    $food = $existing->fetch(PDO::FETCH_ASSOC);

    if (!$food) {
        jsonResponse(false, 'Food item not found');
    }

    $imageName = uploadFoodImage(false);

    if ($imageName === null) {
        $stmt = $pdo->prepare(
            'UPDATE food_items
             SET name = ?, description = ?, category = ?, price = ?, preparation_time = ?, availability = ?
             WHERE food_id = ?'
        );
        $stmt->execute([$name, $description, $category, $price, $preparationTime, $availability, $foodId]);
    } else {
        $stmt = $pdo->prepare(
            'UPDATE food_items
             SET name = ?, description = ?, category = ?, price = ?, preparation_time = ?, availability = ?, image_name = ?
             WHERE food_id = ?'
        );
        $stmt->execute([$name, $description, $category, $price, $preparationTime, $availability, $imageName, $foodId]);
    }

    jsonResponse(true, 'Food item updated successfully');
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
