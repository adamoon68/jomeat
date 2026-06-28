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
        'INSERT OR IGNORE INTO users (name, email, password, role) VALUES (?, ?, ?, ?)'
    );
    $userStmt->execute(['Admin User', 'admin@jomeat.com', $adminHash, 'admin']);
    $userStmt->execute(['Student User', 'student@jomeat.com', $studentHash, 'student']);

    $foodStmt = $pdo->prepare(
        'INSERT OR IGNORE INTO food_items
         (food_id, name, description, category, price, preparation_time, availability, image_name)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
    );

    $foods = [
        [1, 'Nasi Lemak', 'Rice with sambal, egg, cucumber and anchovies.', 'Main Meal', 4.50, 10, 'Available', 'nasi_lemak.jpg'],
        [2, 'Chicken Rice', 'Steamed chicken rice served with soup and chili sauce.', 'Main Meal', 6.00, 12, 'Available', 'chicken_rice.jpg'],
        [3, 'Mee Goreng', 'Fried noodles with vegetables and egg.', 'Main Meal', 5.00, 8, 'Available', 'mee_goreng.jpg'],
        [4, 'Iced Milo', 'Cold chocolate malt drink.', 'Drink', 2.50, 3, 'Available', 'iced_milo.jpg'],
        [5, 'Teh Ais', 'Iced milk tea.', 'Drink', 2.00, 3, 'Available', 'teh_ais.jpg'],
        [6, 'Sandwich', 'Simple sandwich with egg and vegetables.', 'Snack', 3.50, 5, 'Available', 'sandwich.jpg']
    ];

    foreach ($foods as $food) {
        $foodStmt->execute($food);
    }

    echo "JomEat database setup completed.\n";
    echo "Database file: " . $dbPath . "\n";
    echo "Sample admin: admin@jomeat.com / admin123\n";
    echo "Sample student: student@jomeat.com / student123\n";
} catch (PDOException $e) {
    http_response_code(500);
    echo 'Database setup error: ' . $e->getMessage();
}
?>
