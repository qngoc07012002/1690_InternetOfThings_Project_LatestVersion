<?php
$servername = "103.27.239.251"; 
$username = "ngoc_db"; 
$password = "ngoc123";
$dbname = "ngoc_db"; 

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connect SQL Fail: " . $conn->connect_error);
}

$orderBy = "TimeIn"; 

$sql = "SELECT * FROM Slot ORDER BY $orderBy DESC";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $slots = array();
    while ($row = $result->fetch_assoc()) {
        $slots[] = $row;
    }

    header('Content-Type: application/json');
    echo json_encode($slots);
} else {
    echo json_encode(array("error" => "No Slots Found."));
}

$conn->close();
?>
