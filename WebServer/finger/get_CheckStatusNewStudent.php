<?php
$servername = "103.27.239.251"; 
$username = "ngoc_db"; 
$password = "ngoc123";
$dbname = "ngoc_db"; 

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connect SQL Fail: " . $conn->connect_error);
}

// Lấy dòng dữ liệu đầu tiên từ bảng AddNewStudent
$selectSql = "SELECT * FROM AddNewStudent LIMIT 1";
$result = $conn->query($selectSql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $status = $row['Status'];
    
    // Trả về trạng thái dưới dạng JSON
    $response = array("status" => $status);
    echo json_encode($response);
} else {
    echo "No data found in AddNewStudent table.";
}

$conn->close();
?>
