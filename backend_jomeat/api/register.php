<?php
require_once '../config/db.php';

try {
    $name = postValue('name');
    $email = postValue('email');
    $password = postValue('password');
    $role = postValue('role', 'student');

    if ($name === '' || $email === '' || $password === '' || $role === '') {
        jsonResponse(false, 'All fields are required');
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        jsonResponse(false, 'Invalid email format');
    }
    if (!in_array($role, ['student', 'admin'])) {
        jsonResponse(false, 'Invalid role');
    }

    $pdo = getConnection();
    $check = $pdo->prepare('SELECT user_id FROM users WHERE email = ?');
    $check->execute([$email]);
    if ($check->fetch()) {
        jsonResponse(false, 'Email already registered');
    }

    $hash = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare('INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)');
    $stmt->execute([$name, $email, $hash, $role]);
    jsonResponse(true, 'Registration successful');
} catch (PDOException $e) {
    jsonResponse(false, 'Database error: ' . $e->getMessage());
}
?>
