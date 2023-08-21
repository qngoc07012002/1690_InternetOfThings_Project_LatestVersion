<?php
$servername = "103.27.239.251"; 
$username = "ngoc_db"; 
$password = "ngoc123";
$dbname = "ngoc_db"; 

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connect SQL Fail: " . $conn->connect_error);
}

// Xóa toàn bộ dữ liệu trong bảng AddNewStudent
$deleteSql = "DELETE FROM AddNewStudent";
if ($conn->query($deleteSql) === TRUE) {
    $rfidFound = false;
    $nextRFID = 1;

    // Tìm RFID nhỏ nhất chưa được sử dụng từ bảng Student
    while (!$rfidFound) {
        $checkSql = "SELECT COUNT(*) as count FROM Student WHERE RFID = '$nextRFID'";
        $checkResult = $conn->query($checkSql);
        $row = $checkResult->fetch_assoc();
        $count = $row['count'];
        
        if ($count == 0) {
            // Thêm bản ghi mới vào bảng AddNewStudent
            $insertSql = "INSERT INTO AddNewStudent (RFID, Status) VALUES ('$nextRFID', 'Waiting')";
            if ($conn->query($insertSql) === TRUE) {
                $rfidFound = true;
                $response = array("rfid" => $nextRFID);
                echo json_encode($response);
            } else {
                echo "Error: " . $insertSql . "<br>" . $conn->error;
            }
        }
        
        $nextRFID++;
    }
} else {
    echo "Error deleting records: " . $conn->error;
}

$conn->close();
?>
