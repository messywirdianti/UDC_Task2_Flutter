<?php 
require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
    $email = $_POST['email'];
    $password = md5($_POST['password']);

    $check = "SELECT * FROM tbl_users WHERE email='$email' and password = '$password'";
    $result = mysqli_fetch_array(mysqli_query($connect, $check));

    if(isset($result)) {
        $response ['value'] = 1;
        $response ['message'] = "Login Successfully";
        $response ['username'] = $result['username'];
        $response ['email'] = $result['email'];
        $respon ['id_users'] = $result['id_users'];
        echo json_encode($response);
    } else {
        $response['value'] = 0;
        $response['message'] = "Login gagal";
        echo json_encode($response);
    }
    }  
?>
