<?php 
require "connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
        $title = $_POST['title'];
        $content = $_POST['content'];
        $description = $_POST['description'];
        $id_users = $_POST['id_users'];

            $image = date('dmYHIs') . str_replace(" ", "", basename($_FILES['image']['name']));
            $imagePath = "upload/" . $image;
            move_uploaded_file($_FILES['image']['tmp_name'], $imagePath);

                $insert = "INSERT INTO tbl_news (image, title, content, description, date_news, created_at, id_users) VALUES ('$image', '$title', '$content', '$description', NOW(), NOW(), '$id_users')";
                if ($connect->query($insert) === TRUE) {
                    $response['value'] = 1;
                    $response['message'] = "Addnews Successfully";
                    echo json_encode($response);
                } else {
                    $response['value'] = 0;
                    $response['message'] = "AddNews not Successfully: " . $connect->error;
                }
                echo json_encode($response);
            }
?>
