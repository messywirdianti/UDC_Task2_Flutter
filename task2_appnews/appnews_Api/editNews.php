<?php
require "../appnews/connect.php";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();
    
    // Mendapatkan data dari form
    $title = $_POST['title'];
    $content = $_POST['content'];
    $description = $_POST['description'];
    $id_news = $_POST['id_news'];

    // Cek apakah ada file gambar yang diupload
    if (isset($_FILES['image']) && $_FILES['image']['name'] != '') {
        $image = date('dmYHis') . str_replace(" ", "", basename($_FILES['image']['name']));
        $imagePath = "upload/" . $image;

        if (move_uploaded_file($_FILES['image']['tmp_name'], $imagePath)) {
            // Query update untuk memperbarui data termasuk gambar
            $update = "UPDATE tbl_news SET image = '$image', title = '$title', content = '$content', description = '$description' WHERE id_news = '$id_news'";
        } else {
            $response['value'] = 0;
            $response['message'] = "Failed to upload image.";
            echo json_encode($response);
            return;
        }
    } else {
        // Jika tidak ada gambar yang diupload, hanya update title, content, dan description
        $update = "UPDATE tbl_news SET title = '$title', content = '$content', description = '$description' WHERE id_news = '$id_news'";
    }

    if (mysqli_query($connect, $update)) {
        $response['value'] = 1;
        $response['message'] = "Edit news successfully";
    } else {
        $response['value'] = 0;
        $response['message'] = "Edit news failed: " . mysqli_error($connect);
    }
    
    echo json_encode($response);
}
?>
