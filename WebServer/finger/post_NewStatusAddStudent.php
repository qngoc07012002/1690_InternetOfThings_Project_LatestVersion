<?php
$servername = "103.27.239.251"; 
$username = "ngoc_db"; 
$password = "ngoc123";
$dbname = "ngoc_db"; 

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connect SQL Fail: " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Đọc dữ liệu từ yêu cầu POST
    $newStatus = $_POST['status'];

    // Cập nhật trạng thái dòng đầu tiên
    $updateSql = "UPDATE AddNewStudent SET Status = '$newStatus' LIMIT 1";
    
    if ($conn->query($updateSql) === TRUE) {
        $response = array("message" => "Trạng thái đã được cập nhật");
        echo json_encode($response);
    } else {
        echo json_encode(array("error" => "Lỗi khi cập nhật trạng thái: " . $conn->error));
    }
} else {
    echo json_encode(array("error" => "Phương thức yêu cầu không hợp lệ."));
}

$conn->close();
?>
