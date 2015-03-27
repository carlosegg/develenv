#!/bin/bash
DIR=$(dirname $(readlink -f $0))
source ${DIR}/setEnv.sh
echo $PROJECT_NAME
function clean(){
   local nexusConf=$PROJECT_HOME/app/nexus/sonatype-work/nexus/
   rm -Rf $nexusConf/indexer/*
   rm -Rf $nexusConf/proxy/*
   rm -Rf $nexusConf/storage/*
   rm -Rf $nexusConf/timeline/*
   _log "[INFO] Clean repositories of nexus."
   _log "[WARNING] If you want remove download repositories you need delete the content of $PROJECT_HOME/app/maven/.m2/repository/ directory"
}
source ${DIR}/cleanTool.sh
cleanTool

