#!/bin/bash
# NOTA
#   Selenium no puede trabajar con la ip de loopback. Hasta que no exista una ip física asignada, selenium no
# podrá de alta navegadores en el grid.
#
URL_GRID="http://localhost/grid"
setSeleniumBrowsers(){
   if [ `arch` == "x86_64" ]; then
      archSuffix="-x86_64"
   fi
   SELENIUM_BROWSERS="-browser browserName=firefox,version=`firefox --version|sed s:'Mozilla Firefox ':'':g`,maxInstances=2,platform=LINUX"
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser browserName=firefox,version=3.6,firefox_binary=/usr/bin/firefox-3.6,maxInstances=2,platform=LINUX"
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser browserName=firefox,version=5.0,maxInstances=2,platform=XP"
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser \"browserName=internet explorer,version=8,maxInstances=2,platform=XP\""
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser browserName=chrome,version=13.0,maxInstances=2,platform=XP"
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser \"browserName=firefox,version=3,firefox_binary=C:\Archivos de programa\Mozilla Firefox 3\firefox.exe,maxInstances=2,platform=XP\" "
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser browserName=firefox,version=3.6,maxInstances=2,platform=XP "
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser \"browserName=internet explorer,version=7,maxInstances=2,platform=XP\" "
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser browserName=chrome,version=13.0,maxInstances=2,platform=XP "
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser browserName=opera,version=10.50,maxInstances=2,platform=XP "
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser browserName=safari,version=4.04,maxInstances=2,platform=XP "
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser browserName=firefox,version=5.0,maxInstances=2,platform=VISTA "
   #SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser \"browserName=internet explorer,version=9,maxInstances=2,platform=VISTA\" "
   if [ "`which google-chrome`" != "" ]; then
      version="`google-chrome -version|sed s:'Google Chrome ':'':g|sed s:' *$':'':g`"
   else
      if [ "`which chromium-browser`" != "" ]; then
         version="`chromium-browser -version|sed s:'Chromium ':'':g|sed s:' *$':'':g`"
      fi
   fi
   SELENIUM_BROWSERS="$SELENIUM_BROWSERS -browser browserName=chrome,version=20,maxInstances=2,platform=LINUX"
   SELENIUM_BROWSERS="$SELENIUM_BROWSERS -Dwebdriver.chrome.driver=../drivers/chromedriver${archSuffix}"
}

currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname "$DIR"`
}
currentDir
setSeleniumBrowsers
if [ -f "/home/develenv/bin/setEnv.sh" ]; then
   . /home/develenv/bin/setEnv.sh
   export DISPLAY=:20.0
fi
#El display es necesario para ejecutar los navegadores, existe la posibilidad de utilizar Xframebuffer
#para que los navegadores se ejecuten sin necesidad de ser visualizados. Para ello:
# Distribuciones Ubuntu:
#   sudo su -
#      aptitude install xvfb
#      Xvfb :20 -ac -screen 0 1024x768x8
#      export DISPLAY=:20.0
# Distribuciones Centos / Redhat:
#   sudo su -
#      yum install xorg-x11-server-Xvfb
#      Xvfb :20 -ac -screen 0 1024x768x8
#      export DISPLAY=:20.0
#
currentDir
. "$DIR"/setEnv.sh

pushd . >/dev/null
cd "$DIR"
manageSelenium $1 node
popd >/dev/null

