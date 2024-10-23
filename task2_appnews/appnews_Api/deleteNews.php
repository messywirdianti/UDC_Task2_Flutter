<?php
require "../appnews/connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
    $id_news = $_POST['id_news'];

    // Perbaiki query delete
    $delete = "DELETE FROM tbl_news WHERE id_news='$id_news'"; 
    
    if (mysqli_query($connect, $delete)) {
        $response['value'] = 1;
        $response['message'] = "Delete news successfully";
    } else {
        $response['value'] = 0;
        $response['message'] = "Delete not successfully: " . mysqli_error($connect);
    }
    
    // Encode response to JSON format
    echo json_encode($response);
}
?>
