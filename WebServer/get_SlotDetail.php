<?php

$servername = "103.27.239.251";
$username = "ngoc_db";
$password = "ngoc123";
$dbname = "ngoc_db";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Failed to connect to the database: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "GET") {
    $slotID = $_GET["slotID"];

    $query = "SELECT Student.Name, Student.Student_Code, Student.Avatar, Attendance.Status
              FROM Attendance
              JOIN Student ON Attendance.RFID = Student.RFID
              WHERE Attendance.SlotID = '$slotID'";

    $result = $conn->query($query);

    if ($result->num_rows > 0) {
        $data = array();
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode($data);
    } else {
        echo json_encode(array("message" => "No records found."));
    }
} else {
    echo json_encode(array("message" => "Invalid request method."));
}

$conn->close();

?>
