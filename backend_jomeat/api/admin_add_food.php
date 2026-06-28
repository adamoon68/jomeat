<?php
require_once '../config/db.php';

try {
    $name = postValue('name');
    $description = postValue('description');
    $category = postValue('category');
    $price = (float) postValue('price');
    $preparationTime = (int) postValue('preparation_time');
    $availability = postValue('availability', 'Available');

    if ($name === '' || $category === '' || $price <= 0) {
        jsonResponse(false, 'Name, category and valid price are required');
    }
    if (!in_array($availability, ['Available', 'Unavailable'])) {
        jsonResponse(false, 'Invalid availability');
    }

    $imageName = uploadFoodImage(true);
    $pdo = getConnection();
    $stmt = $pdo->prepare(
        'INSERT INTO food_items (name, description, category, price, preparation_time, availability, image_name)
         VALUES (?, ?, ?, ?, ?, ?, ?)'
    );
    $stmt->execute([$name, $description, $category, $price, $preparationTime, $availability, $imageName]);
    jsonResponse(true, 'Food item added successfully');
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
