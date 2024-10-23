<?php

$connect = new mysqli("localhost", "root", "","app_new");

if($connect) {
    // echo "Connection Successfull";
} else {
    echo "Connection failed";
    exit();
}
?>
