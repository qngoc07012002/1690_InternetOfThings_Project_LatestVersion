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
    $rfid = $_POST['rfid'];

    $checkStudentQuery = "SELECT * FROM Student WHERE RFID = '$rfid'";
    $result = $conn->query($checkStudentQuery);

    if ($result->num_rows === 0) {
        echo json_encode(array("error" => "Student Not Found"));
        exit;
    }

    $student = $result->fetch_assoc();

    if ($student['Name'] === 'New Student') {
        echo json_encode(array("error" => "Student Not Found"));
        exit;
    }

    $currentDateTime = date("Y-m-d H:i:s");

    $checkSlotQuery = "SELECT SlotID FROM Slot WHERE TimeIn <= '$currentDateTime' AND TimeOut >= '$currentDateTime'";
    $checkSlotResult = $conn->query($checkSlotQuery);

    if ($checkSlotResult->num_rows === 0) {
        echo json_encode(array("error" => "No Schedule"));
        exit;
    }

    $slotID = $checkSlotResult->fetch_assoc()['SlotID'];

    $updateAttendanceQuery = "UPDATE Attendance SET Status = 'Attended' WHERE SlotID = '$slotID' AND RFID = '$rfid' AND Status = 'Not Yet'";
    if ($conn->query($updateAttendanceQuery) === TRUE) {
        header('Content-Type: application/json');
        echo json_encode($student);
    } else {
        echo json_encode(array("error" => "Error updating attendance."));
    }
}

$conn->close();
?>
