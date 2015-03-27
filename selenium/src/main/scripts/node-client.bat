SET URL_GRID=http://localhost/grid
SET SELENIUM_BROWSERS=-browser "browserName=internet explorer,version=8,maxInstances=2,platform=XP"
rem SET SELENIUM_BROWSERS=-browser browserName=firefox,version=7.0,maxInstances=2,platform=XP
rem SET SELENIUM_BROWSERS=-browser browserName=internet explorer,version=8,maxInstances=2,platform=XP
rem SET SELENIUM_BROWSERS=-browser browserName=chrome,version=13.0,maxInstances=2,platform=XP
rem SET SELENIUM_BROWSERS=-browser "browserName=firefox,version=3,firefox_binary=C:\Archivos de programa\Mozilla Firefox 3\firefox.exe,maxInstances=2,platform=XP"
rem SET SELENIUM_BROWSERS=-browser browserName=firefox,version=3.6,maxInstances=2,platform=XP
rem SET SELENIUM_BROWSERS=-browser browserName=chrome,version=13.0,maxInstances=2,platform=XP
rem SET SELENIUM_BROWSERS=-browser browserName=opera,version=10.50,maxInstances=2,platform=XP
rem SET SELENIUM_BROWSERS=-browser browserName=safari,version=4.04,maxInstances=2,platform=XP
rem SET SELENIUM_BROWSERS=-browser browserName=firefox,version=5.0,maxInstances=2,platform=VISTA
rem SET SELENIUM_BROWSERS=-browser browserName=chrome,version=13.0,maxInstances=2,platform=VISTA
rem SET SELENIUM_BROWSERS=-Dwebdriver.chrome.driver="%CD%\..\drivers\chromedriver.exe"
java -jar ..\selenium-server-standalone.jar -role webdriver -hub %URL_GRID%/register -port 5557 %SELENIUM_BROWSERS% -maxSession 3 1>> ..\log\node.log 2>&1



