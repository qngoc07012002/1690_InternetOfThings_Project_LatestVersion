<?php
$servername = "103.27.239.251"; 
$username = "ngoc_db"; 
$password = "ngoc123";
$dbname = "ngoc_db"; 

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connect SQL Fail: " . $conn->connect_error);
}
$selectSql = "SELECT RFID FROM AddNewStudent LIMIT 1";
$result = $conn->query($selectSql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $rfid = $row['RFID'];


    $insertSql = "INSERT INTO Student (RFID, Name, Avatar) VALUES ('$rfid', 'New Student', 'default.png')";
    if ($conn->query($insertSql) === TRUE) {
       
        $deleteSql = "DELETE FROM AddNewStudent";
        if ($conn->query($deleteSql) === TRUE) {
            $response = array("message" => "Tạo mới và xóa dữ liệu thành công");
            echo json_encode($response);
        } else {
            echo json_encode(array("error" => "Lỗi khi xóa dữ liệu trong bảng AddNewStudent: " . $conn->error));
        }
    } else {
        echo json_encode(array("error" => "Lỗi khi tạo dữ liệu trong bảng Student: " . $conn->error));
    }
} else {
    echo json_encode(array("error" => "Không tìm thấy dữ liệu trong bảng AddNewStudent."));
}

$conn->close();
?>
