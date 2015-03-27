<html>
  <head>
    <script type="text/javascript">
      document.domain="softwaresano.com";
     <!--
<?php
  $artifactId=htmlspecialchars($_GET["artifactId"]);
  $version=htmlspecialchars($_GET["version"]);
  $classifier=htmlspecialchars($_GET["classifier"]);
  $route=$artifactId . "/" . $artifactId . "-" . $version . $classifier;
  $prefix="../softwaresano/downloads/";
  $existe=exec("ls " .  $prefix . $route . ";echo $?");

  if ( $existe == "0" ){
     $redirect= $route;
     $existe=exec("ls -s --block-size=M " . $prefix . $route ."|cut -d' ' -f1");
     exec($prefix . "../private/stats/counter.sh downloads_" . $artifactId . "-" . $version . $classifier );
     exec($prefix . "../private/stats/counter.sh downloads_" . $artifactId);
     echo 'window.location="http://develenv.softwaresano.com/downloading.php?route=' . $redirect . '&size=' . $existe .'&component=' . $artifactId . "-" . $version . $classifier . '"';
  } else{
     $route=$artifactId . "/uploading_" . $artifactId . "-*.*";
     $existe=exec("ls " .  $prefix . $route . ";echo $?");
     if ( $existe == "0" ){
	$redirect= "componentUpdating.php?component=" . $artifactId;
        exec("../private/stats/counter.sh updating");
        echo 'window.location ="http://develenv.softwaresano.com/develenvUpdating.php?route=' .'&component=' . $artifactId . '"';
     }
     else {
        $redirect= "componentNotFound.php?component=" . $route;
        exec("../private/stats/counter.sh notFound");
        echo 'window.location ="http://develenv.softwaresano.com/develenvNotFound.php?route=' .'&component=' . $artifactId . "-" . $version . $classifier . '"';
     }
  }
?>
     //-->
    </script>
  </head>
  <body>
  </body>
</html>

