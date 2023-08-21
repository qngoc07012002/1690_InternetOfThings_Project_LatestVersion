<?php

$servername = "103.27.239.251";
$username = "ngoc_db";
$password = "ngoc123";
$dbname = "ngoc_db";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Failed to connect to the database" . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "GET") {
    $rfid = $_GET["rfid"];

    // Lấy thông tin sinh viên từ bảng Student
    $studentQuery = "SELECT RFID, Name, Student_Code, Email, Avatar FROM Student WHERE RFID = '$rfid'";
    $studentResult = $conn->query($studentQuery);

    if ($studentResult->num_rows > 0) {
        $studentData = $studentResult->fetch_assoc();
        
        // Lấy lịch sử điểm danh từ bảng Attendance và Slot, sắp xếp theo thời gian giảm dần
        $attendanceHistoryQuery = "
            SELECT A.AttendanceID, S.Name AS SlotName, A.Status, DATE(S.TimeIn) AS Date
            FROM Attendance A
            INNER JOIN Slot S ON A.SlotID = S.SlotID
            WHERE A.RFID = '$rfid'
            ORDER BY S.TimeIn DESC
        ";
        
        $attendanceHistoryResult = $conn->query($attendanceHistoryQuery);
        
        $attendanceHistory = array();
        if ($attendanceHistoryResult->num_rows > 0) {
            while ($row = $attendanceHistoryResult->fetch_assoc()) {
                $attendanceHistory[] = array(
                    "AttendanceID" => $row["AttendanceID"],
                    "SlotName" => $row["SlotName"],
                    "Status" => $row["Status"],
                    "Date" => $row["Date"]
                );
            }
        }

        $response = array(
            "Student" => $studentData,
            "AttendanceHistory" => $attendanceHistory
        );

        echo json_encode($response);
    } else {
        $errorResponse = array("error" => "Student with RFID $rfid not found");
        echo json_encode($errorResponse);
    }
}

$conn->close();

?>
