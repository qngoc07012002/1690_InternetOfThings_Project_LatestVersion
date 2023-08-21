<?php
$servername = "103.27.239.251"; 
$username = "ngoc_db"; 
$password = "ngoc123";
$dbname = "ngoc_db"; 

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connect SQL Fail: " . $conn->connect_error);
}

$sql = "SELECT COUNT(*) as count FROM Student WHERE name = 'New Student'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $count = intval($row['count']);

    header('Content-Type: application/json');
    echo json_encode($count > 0);
} else {
    echo json_encode(array("error" => "Query Error."));
}

$conn->close();
?>
