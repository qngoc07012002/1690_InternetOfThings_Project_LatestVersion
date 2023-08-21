<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        $targetDir = 'images/'; // Đường dẫn tới thư mục "images"
        $targetFile = $targetDir . basename($_FILES['image']['name']); 

        if (move_uploaded_file($_FILES['image']['tmp_name'], $targetFile)) {
            echo 'Image uploaded successfully.';
        } else {
            echo 'Error uploading image.';
        }
    } else {
        echo 'No image sent or an error occurred.';
    }
}
?>
