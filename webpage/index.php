<!DOCTYPE html>
<!-- https://www.w3schools.com/php/php_file_upload.asp -->
<html>
<head>
    <title>Store form data in .txt file</title>
  
    <!-- Compiled and minified CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css">

    <!-- Compiled and minified JavaScript -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"></script>
</head>

<body class="">
    <div class="container center-align section">
    <img src="img/okh-logo.svg">
    <form class="center-align" action="upload.php" method="post" enctype="multipart/form-data">
      Select image to upload:
      <input type="file" name="fileToUpload" id="fileToUpload">
      <input type="submit" value="Upload manifest" name="submit">
    </form>
    </div>
</body>
</html>
