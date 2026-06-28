<?php
require_once '../config/db.php';

try {
    $email = postValue('email');
    $password = postValue('password');

    if ($email === '' || $password === '') {
        jsonResponse(false, 'Email and password are required');
    }

    $pdo = getConnection();
    $stmt = $pdo->prepare('SELECT * FROM users WHERE email = ?');
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user || !password_verify($password, $user['password'])) {
        jsonResponse(false, 'Invalid email or password');
    }

    unset($user['password']);
    jsonResponse(true, 'Login successful', $user);
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
