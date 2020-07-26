<!-- Loosely based on https://www.w3schools.com/php/php_file_upload.asp -->
<html>
<head>
    <title>Upload your manifest</title>
  
    <!-- Compiled and minified CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css">

    <!-- Compiled and minified JavaScript -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"></script>

    <style>
    .input-field > label{
        position:relative;
        color: #800080;
    }
    </style>
</head>

<body class="">
    <div class="container center-align section">
        <h1>1. Upload the manifest</h1>
        <img src="img/okh-logo.svg">
        <form class="center-align" action="upload.php" method="post" enctype="multipart/form-data">
            Select image to upload:
            <input type="file" name="fileToUpload" id="fileToUpload">
            <div class="row">
            <h1>2. Evaluate from 1 to 5</h1>
                <div class="input-field col s12 m6 offset-m3">
                    <label for="eval1">How effective do you believe it is? (0=not at all; 10=super effective)</label>
                    <input required type="number" min="0" max="10" name="eval1" id="eval1" class="validate">
                </div>
                <div class="input-field col s12 m6 offset-m3">
                    <label for="eval2">How expensive is it? (0=too expensive; 10=very affordable)</label>
                    <input required type="number" min="0" max="10" name="eval2" id="eval2" class="validate">
                </div>
                <div class="input-field col s12 m6 offset-m3">
                    <label for="eval3">Would it be easy to find its materials? (0=not easy; 10=very easy)</label>
                    <input required type="number" min="0" max="10" name="eval3" id="eval3" class="validate">
                </div>
                <div class="input-field col s12 m6 offset-m3">
                    <label for="eval4">How easy is it to fabricate?  (0=too difficult; 10=very easy)</label>
                    <input required type="number" min="0" max="10" name="eval4" id="eval4" class="validate">
                </div>
                <div class="input-field col s12 m6 offset-m3">
                    <label for="eval5">How durable does it look? (0=not durable or disposable; 10=it looks very durable)</label>
                    <input required type="number" min="0" max="10" name="eval5" id="eval5" class="validate">
                </div>
            </div>
            
      <input type="submit" value="Submit" name="submit">
    </form>
    </div>
</body>
</html>
