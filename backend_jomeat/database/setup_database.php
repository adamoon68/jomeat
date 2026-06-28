<?php
header('Content-Type: text/plain');

try {
    $dbPath = __DIR__ . '/jomeat.db';
    $pdo = new PDO('sqlite:' . $dbPath);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->exec('PRAGMA foreign_keys = ON');

    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS users (
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT "student",
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )'
    );

    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS food_items (
            food_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            category TEXT NOT NULL,
            price REAL NOT NULL,
            preparation_time INTEGER,
            availability TEXT DEFAULT "Available",
            image_name TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )'
    );

    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS orders (
            order_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            food_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            total_price REAL NOT NULL,
            notes TEXT,
            status TEXT DEFAULT "Pending",
            order_date TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(user_id),
            FOREIGN KEY(food_id) REFERENCES food_items(food_id)
        )'
    );

    $adminHash = password_hash('admin123', PASSWORD_DEFAULT);
    $studentHash = password_hash('student123', PASSWORD_DEFAULT);

    $userStmt = $pdo->prepare(
        'INSERT INTO users (name, email, password, role)
         VALUES (?, ?, ?, ?)
         ON CONFLICT(email) DO UPDATE SET
            name = excluded.name,
            password = excluded.password,
            role = excluded.role'
    );
    $userStmt->execute(['Admin User', 'admin@jomeat.com', $adminHash, 'admin']);
    $userStmt->execute(['Student User', 'student@jomeat.com', $studentHash, 'student']);

    $foodStmt = $pdo->prepare(
        'INSERT OR IGNORE INTO food_items
         (food_id, name, description, category, price, preparation_time, availability, image_name)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
    );

    $foods = [
        [1, 'Nasi Lemak', 'Rice with sambal, egg, cucumber and anchovies.', 'Main Meal', 4.50, 10, 'Available', ''],
        [2, 'Chicken Rice', 'Steamed chicken rice served with soup and chili sauce.', 'Main Meal', 6.00, 12, 'Available', ''],
        [3, 'Mee Goreng', 'Fried noodles with vegetables and egg.', 'Main Meal', 5.00, 8, 'Available', ''],
        [4, 'Iced Milo', 'Cold chocolate malt drink.', 'Drink', 2.50, 3, 'Available', ''],
        [5, 'Teh Ais', 'Iced milk tea.', 'Drink', 2.00, 3, 'Available', ''],
        [6, 'Sandwich', 'Simple sandwich with egg and vegetables.', 'Snack', 3.50, 5, 'Available', ''],
        [7, 'Nasi Goreng Kampung', 'Spicy village-style fried rice with anchovies and vegetables.', 'Main Meal', 5.50, 10, 'Available', ''],
        [8, 'Kuey Teow Goreng', 'Fried flat noodles with egg, vegetables and soy sauce.', 'Main Meal', 5.50, 9, 'Available', ''],
        [9, 'Chicken Burger', 'Chicken patty burger with lettuce and special sauce.', 'Snack', 4.80, 7, 'Available', ''],
        [10, 'French Fries', 'Crispy fried potatoes served hot.', 'Snack', 3.00, 5, 'Available', ''],
        [11, 'Curry Puff', 'Pastry snack filled with potato curry.', 'Snack', 1.50, 4, 'Available', ''],
        [12, 'Mineral Water', 'Bottled drinking water.', 'Drink', 1.20, 1, 'Available', ''],
        [13, 'Orange Juice', 'Cold orange juice drink.', 'Drink', 3.00, 3, 'Available', ''],
        [14, 'Chicken Nugget Set', 'Chicken nuggets served with chili sauce.', 'Snack', 4.00, 6, 'Available', '']
    ];

    foreach ($foods as $food) {
        $foodStmt->execute($food);
    }

    $pdo->exec(
        "UPDATE food_items
         SET image_name = ''
         WHERE image_name IN (
            'nasi_lemak.jpg',
            'chicken_rice.jpg',
            'mee_goreng.jpg',
            'iced_milo.jpg',
            'teh_ais.jpg',
            'sandwich.jpg'
         )"
    );

    echo "JomEat database setup completed.\n";
    echo "Database file: " . $dbPath . "\n";
    echo "Sample admin: admin@jomeat.com / admin123\n";
    echo "Sample student: student@jomeat.com / student123\n";
} catch (PDOException $e) {
    http_response_code(500);
    echo 'Database setup error: ' . $e->getMessage();
}
?>
