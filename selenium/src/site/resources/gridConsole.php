
	<?php
	 $console=exec('wget -O- http://localhost/grid/console|sed s:".*<body>":"":g|sed s:"</body>.*":"":g');
	 if ( $console == "" ){
	    $inSoftwaresanoCom=exec('if [ -d "/home/develenv" ]; then echo "develenv";fi');
            if ($inSoftwaresanoCom == ""){
              $console="<H1>Grid Hub</H1><fieldset><legend>DefaultRemoteProxy</legend>listening on http://develenv.softwaresano.com:5556<br />test session time out after 300 sec.<br />Supports up to <b>3</b> concurrent tests from: <br /><img src='/grid/resources/images/firefox.png'  title='{platform=LINUX, browserName=firefox, maxInstances=2, version=7.0.1}type=WebDriver' /><img src='/grid/resources/images/firefox.png'  title='{platform=LINUX, browserName=firefox, maxInstances=2, version=7.0.1}type=WebDriver' /><img src='/grid/resources/images/chrome.png'  title='{platform=LINUX, browserName=chrome, maxInstances=2, version=15.0}type=WebDriver' /><img src='/grid/resources/images/chrome.png'  title='{platform=LINUX, browserName=chrome, maxInstances=2, version=15.0}type=WebDriver' /><img src='/grid/resources/images/safari.png'  title='{platform=LINUX, browserName=chrome, maxInstances=2, version=15.0}type=WebDriver' /><img src='/grid/resources/images/safari.png'  title='{platform=LINUX, browserName=chrome, maxInstances=2, version=15.0}type=WebDriver' /><img src='/grid/resources/images/opera.png'  title='{platform=LINUX, browserName=chrome, maxInstances=2, version=15.0}type=WebDriver' /><img src='/grid/resources/images/opera.png'  title='{platform=LINUX, browserName=chrome, maxInstances=2, version=15.0}type=WebDriver' /><img src='/grid/resources/images/internet%20explorer.png'  title='{platform=LINUX, browserName=chrome, maxInstances=2, version=15.0}type=WebDriver' /><img src='/grid/resources/images/internet%20explorer.png'  title='{platform=LINUX, browserName=chrome, maxInstances=2, version=15.0}type=WebDriver' /></fieldset><ul></ul>"; 
            } else{
	      $console="<H1>Grid Hub NO DISPONIBLE</H1><fieldset>Selenium Grid No disponible<br/>Revise los logs en /var/log/develenv/selenium o <a href='/develenv/logs/selenium/'>aquí.</a><br />Una vez revisados los logs puede rearrancar utilizando el comando:<br/>sudo /home/develenv/platform/selenium.sh restart</fieldset><ul></ul>";
	      
            }
         } 
         echo  'document.write("' . $console . '");' ;
	?>

