<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

function getConnection()
{
    $dbPath = __DIR__ . '/../database/jomeat.db';
    $pdo = new PDO('sqlite:' . $dbPath);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->exec('PRAGMA foreign_keys = ON');
    return $pdo;
}

function jsonResponse($success, $message, $data = null)
{
    $response = [
        'success' => $success,
        'message' => $message
    ];
    if ($data !== null) {
        $response['data'] = $data;
    }
    echo json_encode($response);
    exit;
}

function postValue($key, $default = '')
{
    return isset($_POST[$key]) ? trim($_POST[$key]) : $default;
}

function uploadFoodImage($required = false)
{
    if (!isset($_FILES['image']) || $_FILES['image']['error'] === UPLOAD_ERR_NO_FILE) {
        if ($required) {
            jsonResponse(false, 'Food image is required');
        }
        return null;
    }

    if ($_FILES['image']['error'] !== UPLOAD_ERR_OK) {
        jsonResponse(false, 'Image upload failed');
    }

    if ($_FILES['image']['size'] > 5 * 1024 * 1024) {
        jsonResponse(false, 'Image size must be 5MB or less');
    }

    $uploadDir = dirname(__DIR__, 2) . '/assets/images';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $originalName = $_FILES['image']['name'];
    $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
    $allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

    if (!in_array($extension, $allowedExtensions)) {
        jsonResponse(false, 'Only JPG, PNG, and WEBP images are allowed');
    }

    $fileName = 'food_' . date('Ymd_His') . '_' . bin2hex(random_bytes(4)) . '.' . $extension;
    $targetPath = $uploadDir . '/' . $fileName;

    if (!move_uploaded_file($_FILES['image']['tmp_name'], $targetPath)) {
        jsonResponse(false, 'Could not save uploaded image');
    }

    return 'assets/images/' . $fileName;
}
?>
