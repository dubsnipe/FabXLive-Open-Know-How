<?php
// Code snippets taken and edited from these two sites.
// https://www.codespeedy.com/save-html-form-data-in-a-txt-text-file-in-php/
// https://www.w3schools.com/php/php_file_upload.asp

$target_dir = "manifests/";
$target_file = $target_dir . date('His') . basename($_FILES["fileToUpload"]["name"]);
$uploadOk = 1;
$imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));


// Allow certain file formats
if($imageFileType != "yml") {
  echo "Sorry, only txt and YAML files are allowed.";
  $uploadOk = 0;
}

// Check if file already exists
// if (file_exists($target_file)) {
  // echo "Sorry, file already exists.";
  // $uploadOk = 0;
// }

// Check file size
if ($_FILES["fileToUpload"]["size"] > 1000) {
  echo "Sorry, your file is too large.";
  $uploadOk = 0;
}


// Check if $uploadOk is set to 0 by an error
if ($uploadOk == 0) {
  echo "Sorry, your file was not uploaded.";
// if everything is ok, try to upload file
} else {
  if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
    echo "The file ". basename( $_FILES["fileToUpload"]["name"]). " has been uploaded.";
  } else {
    echo "Sorry, there was an error uploading your file.";
  }
}

if(isset($_POST['eval1']) && isset($_POST['eval2']) && isset($_POST['eval3']) && isset($_POST['eval4']) && isset($_POST['eval5'])) {
    $data = basename( $_FILES["fileToUpload"]["name"]) . "," . $_POST['eval1'] . "," . $_POST['eval2'] . "," . $_POST['eval3'] . "," . $_POST['eval4'] . "," . $_POST['eval5'] . "\r\n";
    $fp = fopen('eval.csv', 'a');
    fwrite($fp, $data);
    fclose($fp);
}

?>
