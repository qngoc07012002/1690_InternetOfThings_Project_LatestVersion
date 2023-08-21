<?php

$servername = "103.27.239.251";
$username = "ngoc_db";
$password = "ngoc123";
$dbname = "ngoc_db";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Failed to connect to the database" . $conn->connect_error);
}

$currentDateTime = date("Y-m-d H:i:s");
$currentDate = date("Y-m-d");

$slotData = array(
    1 => array("Name" => "1", "TimeIn" => "07:30:00", "TimeOut" => "09:00:00"),
    2 => array("Name" => "2", "TimeIn" => "09:10:00", "TimeOut" => "10:40:00"),
    3 => array("Name" => "3", "TimeIn" => "10:50:00", "TimeOut" => "12:20:00"),
    4 => array("Name" => "4", "TimeIn" => "12:50:00", "TimeOut" => "14:20:00"),
    5 => array("Name" => "5", "TimeIn" => "14:30:00", "TimeOut" => "16:00:00"),
    6 => array("Name" => "6", "TimeIn" => "16:10:00", "TimeOut" => "17:40:00"),
    7 => array("Name" => "7", "TimeIn" => "17:50:00", "TimeOut" => "19:20:00"),
    8 => array("Name" => "8", "TimeIn" => "19:30:00", "TimeOut" => "21:00:00")
);

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $slotValue = $_POST["slot_value"];

    if ($slotValue >= 1 && $slotValue <= 8) {
        $slotEndTime = $currentDate . " " . $slotData[$slotValue]["TimeOut"];
        
        if ($currentDateTime > $slotEndTime) {
            $errorResponse = array("error" => "The current time has passed Slot {$slotData[$slotValue]['Name']}");
            echo json_encode($errorResponse);
        } else {
            // Tiếp tục với phần tạo Slot
            $slotName = $slotData[$slotValue]["Name"];
            $timeIn = $currentDate . " " . $slotData[$slotValue]["TimeIn"];
            $timeOut = $currentDate . " " . $slotData[$slotValue]["TimeOut"];

            $checkSlotQuery = "SELECT SlotID FROM Slot WHERE TimeIn = '$timeIn' AND TimeOut = '$timeOut'";
            $checkSlotResult = $conn->query($checkSlotQuery);

            if ($checkSlotResult->num_rows > 0) {
                $errorResponse = array("error" => "Slot already exists with corresponding time");
                echo json_encode($errorResponse);
            } else {
                // Tiếp tục với phần tạo Slot
                $insertSlotQuery = "INSERT INTO Slot (Name, TimeIn, TimeOut) VALUES ('$slotName', '$timeIn', '$timeOut')";
                if ($conn->query($insertSlotQuery) === TRUE) {
                    $slotID = $conn->insert_id;

                    // Tạo lịch cho sinh viên
                    $selectRFIDQuery = "SELECT RFID FROM Student WHERE Name != 'New Student'";
                    $result = $conn->query($selectRFIDQuery);

                    if ($result->num_rows > 0) {
                        while ($row = $result->fetch_assoc()) {
                            $rfid = $row["RFID"];
                            $status = "Not Yet";

                            $insertAttendanceQuery = "INSERT INTO Attendance (SlotID, RFID, Status) VALUES ('$slotID', '$rfid', '$status')";
                            if ($conn->query($insertAttendanceQuery) !== TRUE) {
                                $errorResponse = array("error" => "Error: " . $insertAttendanceQuery . "<br>" . $conn->error);
                                echo json_encode($errorResponse);
                                exit();
                            }
                        }
                    } else {
                        $errorResponse = array("error" => "Không tìm thấy sinh viên nào có tên khác 'New Student'");
                        echo json_encode($errorResponse);
                        exit();
                    }
                    
                    $successResponse = array("success" => "Create Schedule Succesful");
                    echo json_encode($successResponse);
                } else {
                    $errorResponse = array("error" => "Error: " . $insertSlotQuery . "<br>" . $conn->error);
                    echo json_encode($errorResponse);
                }
            }
        }
    } else {
        $errorResponse = array("error" => "Invalid slot value");
        echo json_encode($errorResponse);
    }
}

$conn->close();

?>
