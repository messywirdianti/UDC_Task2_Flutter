<?php 
require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
    $username = $_POST['username'];
    $email = $_POST['email'];
    $password = md5($_POST['password']);

    $check = "SELECT * FROM tbl_users WHERE email='$email'";
    $result = mysqli_fetch_array(mysqli_query($connect, $check));

    if(isset($result)) {
        $response ['value'] = 2;
        $response ['message'] = "Email already in use";
        echo json_encode($response);
    } else {
        $insert = "INSERT INTO tbl_users VALUES(NULL, '$username','$email','$password','1',NOW())";
    if (mysqli_query($connect,$insert)) {
        $response['value'] = 1;
        $response['message'] = "Register Successfully";
        echo json_encode($response);
    } else {
        $response['value'] = 0;
        $response['message'] = "Register not Successfully: " . mysqli_error($connect); // Menambahkan pesan error
        echo json_encode($response);
    }
    }  
}
?>
