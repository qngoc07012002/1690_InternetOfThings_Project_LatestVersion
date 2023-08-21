<?php
$servername = "103.27.239.251"; 
$username = "ngoc_db"; 
$password = "ngoc123";
$dbname = "ngoc_db"; 

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connect SQL Fail: " . $conn->connect_error);
}


$selectSql = "SELECT * FROM AddNewStudent LIMIT 1";
$result = $conn->query($selectSql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $rfid = $row['RFID'];
    
   
    $response = array("rfid" => $rfid);
    echo json_encode($response);
} else {
    echo json_encode(array("error" => "No data found in AddNewStudent table."));
}

$conn->close();
?>
