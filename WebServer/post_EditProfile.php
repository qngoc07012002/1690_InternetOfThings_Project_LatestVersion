<?php
$servername = "103.27.239.251"; 
$username = "ngoc_db";
$password = "ngoc123"; 
$dbname = "ngoc_db";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$rfid = $_POST['rfid'];
$name = $_POST['name'];
$studentCode = $_POST['student_code'];
$email = $_POST['email'];
$avatar = $_POST['avatar'];

$sql = "UPDATE Student SET Name = '$name', Student_Code = '$studentCode', Email = '$email'";

if (!empty($avatar)) {
    $sql .= ", Avatar = '$avatar'";
}

$sql .= " WHERE RFID = '$rfid'";

if ($conn->query($sql) === TRUE) {
    echo "Update Profile Successful";
} else {
    echo "Lỗi: " . $conn->error;
}

$conn->close();
?>
