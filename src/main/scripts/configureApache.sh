#!/bin/bash
if [ -z $PROJECT_HOME ]; then
   . $(dirname $(readlink -f $0))/setEnv.sh
else
   . $PROJECT_HOME/bin/setEnv.sh
fi
installationIn$distribution
cp $PROJECT_HOME/docs/readme.html $APACHE_HTML_DIR/index.html

