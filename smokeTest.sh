#!/bin/bash
# Mas info: http://develenv.softwaresano.com/deploymentPipeline/libtest.html y
#           http://develenv.softwaresano.com/deploymentPipeline/index.html#Smoke_Test

function smokeTestIndex(){
   retCode=$(httpOK "$URL_SERVER/docs/index.html")
   case $retCode in
      403)
         _log "[ERROR] Probably there's an error on file's security context (SELinux)"
         return $retCode
         ;;
       *)
         return $retCode
         ;;
   esac
}

function smokeTestJenkins(){
   return $(httpOK "$URL_SERVER/jenkins")
}

function smokeTestRunJenkinsExamples(){
   local http_status=$(httpOK "$URL_SERVER/jenkins/job/01-execute-develenv-examples/build?token=9iufas9jfnniu6adfj&cause=smoke+tests")
   if [ "$http_status" == "201" ]; then
      return 0
   fi
   return $http_status
}

function smokeTestSonar(){
   return $(httpOK "$URL_SERVER/sonar")
}
function smokeTestNexus(){
   return $(httpOK "$URL_SERVER/nexus")
}
function smokeTestSeleniumGrid(){
   return $(httpOK "$URL_SERVER/grid/console")
}

function smokeTestScreenshot(){
   return $(httpOK "$URL_SERVER/develenv/screenshot/screenshot.php?url=\"http://$URL_SERVER/sonar/\"&element_id=sidebar")
}

function smokeTestDockerRegistry(){
   return $(httpOK "$URL_SERVER:5010")
}

function smokeTestRepoRpm(){
   return $(httpOK "$URL_SERVER/develenv/rpms/noarch/ss-develenv-repo-1.0-0.0.noarch.rpm")
}

function smokeTestDevelenvLogs(){
   return $(httpOK "$URL_SERVER/develenv/logs")
}

function smokeTestDevelenvConfig(){
   return $(httpOK "$URL_SERVER/develenv/config")
}



function smokeTestDevelenvAdmin(){
   local develenv_admin_url=$URL_SERVER/develenv/admin
   retCode=$(httpOK "$develenv_admin_url")
   if [ "$retCode" == "401" ]; then
       return 0
   fi
   _log "[ERROR] Unnable to access to [$develenv_admin_url]. You can not manage develenv."
   return 1
}

source $(dirname $(python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $0))/libtest.sh
DEFAULT_PAUSE_SECONDS=450
main $*
exit $?

##################### DEPLOYMENT TABLE ############################
#WARNING: No borrar la línea anterior, ya que es el separador
# del script y de la DEPLOYMENT TABLE

#--------------+--------------------------------------------------------------
# Enviroment   | URL 
#--------------+--------------------------------------------------------------
int            | http://int-develenv-01.hi.inet
qa             | http://qa-develenv-01.aislada.hi.inet
local          | http://localhost
