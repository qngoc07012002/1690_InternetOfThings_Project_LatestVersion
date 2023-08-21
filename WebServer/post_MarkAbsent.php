<?php

$servername = "103.27.239.251";
$username = "ngoc_db";
$password = "ngoc123";
$dbname = "ngoc_db";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Kết nối đến cơ sở dữ liệu thất bại: " . $conn->connect_error);
}

$currentDateTime = date("Y-m-d H:i:s");

$markAbsentQuery = "UPDATE Attendance
                    JOIN Slot ON Attendance.SlotID = Slot.SlotID
                    SET Attendance.Status = 'Absent'
                    WHERE Attendance.Status = 'Not Yet' AND Slot.TimeOut <= '$currentDateTime'";

if ($conn->query($markAbsentQuery) === TRUE) {
    echo "Đã cập nhật trạng thái 'Absent' cho các sinh viên với Slot Timeout nhỏ hơn hoặc bằng thời gian hiện tại: $currentDateTime";
} else {
    echo "Lỗi: " . $markAbsentQuery . "<br>" . $conn->error;
}

$conn->close();

?>
