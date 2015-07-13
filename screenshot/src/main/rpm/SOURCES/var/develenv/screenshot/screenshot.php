<?php
$file = $_GET['url'];
$id_element = $_GET['element_id'];
$token="/tmp/selenium-" . md5(uniqid(mt_rand(), true)) . ".png";
exec("python screenshot.py " . $file . " " . $token . " " . $id_element);
header('Content-type: image/png');
readfile($token);
exec("rm -f " . $token);
?>