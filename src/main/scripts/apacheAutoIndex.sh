#!/bin/bash
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}

currentDir
. $DIR/setEnv.sh
sed s:'<div id="footer">':'\n#### HEADER.html ####\n<div id="footer">':g develenv_HEADER.html >aux.html
lineSeparator=`grep -n "#### HEADER.html ####" aux.html|grep -v "grep" |sed s:"\:#### HEADER.html ####":"":g`
sed 1,${lineSeparator}d aux.html > develenv_FOOTER.html
sed s:"<\!-- ~~~~~~~~~~ -->.*":"\n#### HEADER.html ####":g develenv_HEADER.html >aux.html
lineSeparator=`grep -n "#### HEADER.html ####" aux.html|grep -v "grep" |sed s:"\:#### HEADER.html ####":"":g`
sed $lineSeparator,10000d aux.html > develenv_HEADER.html
sed -i s:'<a href="http\:':'a<a href="http\:':g develenv_HEADER.html
sed -i s:' <a href="':' <a href="/docs/':g develenv_HEADER.html
sed -i s:'a<a href="http\:':'<a href="http\:':g develenv_HEADER.html
sed -i s:'"./css/':'"/docs/css/':g develenv_HEADER.html
rm aux.html
su $PROJECT_USER -c "mkdir -p /var/log/$APPNAME && cp $PROJECT_HOME/app/repositories/.htaccess /var/log/$APPNAME"
su $PROJECT_USER -c "sed -i s:\"\*.log\":\"\":g /var/log/develenv/.htaccess"
su $PROJECT_USER -c "cp $PROJECT_HOME/app/repositories/.htaccess /var/$APPNAME"
