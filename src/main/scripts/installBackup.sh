#!/bin/bash
logCommands=echo
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}

getAppDirName(){
   APPNAME=$PROJECT_NAME-$PROJECT_VERSION
}
. $DIR/setEnv.sh

getAppDirName
CURRENT_DIR=$PWD
BACKUP_DIR="/var/$APPNAME/backup"
mkdir -p $BACKUP_DIR
cd $BACKUP_DIR
ln -s $PROJECT_NAME/app/hudson hudson
ln -s $PROJECT_NAME/app/nexus/sonatype-work/nexus/conf nexus
ln -s $PROJECT_HOME/platform/tomcat/webapps/sonar sonar
ln -s $PROJECT_HOME/platform/maven/conf maven
ln -s $PROJECT_HOME/platform/tomcat/conf tomcat

cd $CURRENT_DIR
