#!/bin/bash
# Esta librería simplifica la invocación de los tests dentro de la pipeline. Además
# añade funciones para invocar a diferentes tipos de tests (selenium, jmeter, 
# httpOk y soapui)
# Mas info: http://develenv.softwaresano.com/deploymentPipeline/libtest.html y
#           http://develenv.softwaresano.com/deploymentPipeline/index.html#Smoke_Test

function currentDir(){
   DIR=$(dirname $(python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $0))
}

function isExecutedInDevelenv(){
   if [ "`id -nu`" == "develenv" ]; then
      isDevelenv="true"
   else
      isDevelenv="false"
   fi
}

function _message(){
   _error_color="\\033[47m\\033[1;31m"
   _default_log_color_pre="\\033[0m\\033[1;34m"
   _default_log_color_suffix="\\033[0m"
   isError=$(echo "$1"|grep "\\[ERROR\\]")
   isDash=`echo -en|grep "\-en"`
   ! [ -z "$isError" ] && messageColor=${_error_color} || messageColor=${_default_log_color_pre}
   [ -z "$isDash" ] && echo -en "${messageColor}$1${_default_log_color_suffix}\n" || echo "${messageColor}$1${_default_log_color_suffix}\n"
}

function _log(){
   _message "[`date '+%Y-%m-%d %X'`] $1"
}

function help(){
   _message "
${typeTest}Test Execution:

Usage:
    $0  < -e <environmentId> > [ -t <deploymentTableFile> ] [-p <wait seconds>] [ -h ]


Parameters:
    <environmentId>  environment against ${typeTest}Tests are run
    <deploymentTableFile> File with the definition of environments and URLs
    <wait seconds> number of seconds to wait for the environment to be ready

Examples:
    $0 -e int -p 150
    $0 -e int
    $0 -t deploymentTableFile.txt -p 120 
    Where a deploymentTableFile.txt looks like this:
#--------------+--------------------------------------------------------------
# Enviroment   | URL 
#--------------+--------------------------------------------------------------
int            | http://int-develenv-01.hi.inet
qa             | http://qa-develenv-01.aislada.hi.inet
"
}

# HTTP tests
function httpOK(){
   wget_test_result=`wget -q -S "$1" -O /dev/null 2>&1|\
                     egrep "HTTP/1\.1 [0-9][0-9][0-9]+"|\
                     tail -1|awk '{ print $2 }'`
   if [ "$wget_test_result" == "200" ]; then
       echo 0
   else
       echo $wget_test_result
   fi 
}

function sshCommand(){
   SSH_OPTIONS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
   SSH_COMMAND="ssh $SSH_OPTIONS"
   $SSH_COMMAND $*
}

# Return 0 if rpm is installed in a Host
function isRpmInstalled(){
   local url_access=$1
   local rpm_name=$2
   sshCommand "$url_access" "rpm -qa|grep $rpm_name"
}

# JMeter Tests
function isExecutedInDevelenv(){
   if [ "`id -nu`" == "develenv" ]; then
      isDevelenv="true"
   else
      isDevelenv="false"
   fi
}

function getJMeterHome(){
   isExecutedInDevelenv
   if [ "$isDevelenv" == "false" ]; then
      jmeterPath=$(which jmeter.sh)
      [[ "$jmeterPath" == "" ]] && _log "[ERROR] Jmeter debería estar en el path" && return 1
      JMETER_HOME=$(dirname $(dirname $jmeterPath))
   else
      JMETER_HOME="/home/develenv/platform/jmeter"
   fi
   export JMETER_HOME
}

function initJmeter(){
   currentDir
   getJMeterHome
   [[ $? != "0" ]] && return 1
   WORKSPACE=$DIR
   OUTPUT_DIR=${WORKSPACE}/target/
   OUTPUT_REPORTS_DIR=$OUTPUT_DIR/reports
   LOG_DIR=$OUTPUT_DIR/logs
   rm -Rf $OUTPUT_DIR $OUTPUT_REPORTS_DIR
   mkdir -p $OUTPUT_DIR $OUTPUT_REPORTS_DIR $LOG_DIR
   JTL_FILE="${OUTPUT_REPORTS_DIR}/jmeter-example.jtl"
}

# Se chequea si hay algún error, en caso de haberlo se imprime. Por ejemplo:
# [ERROR]Test failed: text expected to contain //sonar/stylesheets/sonar.css2/
# que sale del fichero JTL_FILE de una traza como:
# 1360841268091|1155|Sonar is loaded|200|OK|TestCaseExecution Test Suite 1-4|text|false|Test failed: text expected to contain //sonar/stylesheets/sonar.css2/|570403|17
function validateJmeterExecution(){
  local isFalse=$(cat ${JTL_FILE} | cut -d"|" -f8,9 | grep -v "^true|" | cut -d"|" -f2 | sort | uniq -i)
  [[ "$isFalse" != "" ]] && echo "[ERROR] $isFalse" && return 1 || return 0
}

function jmeterExecution(){
  local jmeterSource="$1"
  local urlServer="$2"
  initJmeter
  [[ $? != "0" ]] && return 1
  ${JMETER_HOME}/bin/jmeter.sh -n -j "${LOG_DIR}/jmeter-example.log" \
   -Djmeter.save.saveservice.output_format=csv \
   -Djmeter.save.saveservice.assertion_results_failure_message=true \
   -Djmeter.save.saveservice.default_delimiter="|" \
   -l "${JTL_FILE}" -t "$jmeterSource" \
   -Jhostname="$urlServer"
   validateJmeterExecution
   return $?
}

#Jmeter tests example
# Copy, uncomment and modify this function in acceptanceTest.sh
#function acceptanceTestDevelenv(){
#  initJmeter
#  [[ $? != "0" ]] && return 1
#  ${JMETER_HOME}/bin/jmeter.sh -n -j "${LOG_DIR}/jmeter-example.log" \
#   -Djmeter.save.saveservice.output_format=csv \
#   -Djmeter.save.saveservice.assertion_results_failure_message=true \
#   -Djmeter.save.saveservice.default_delimiter="|" \
#   -l "${JTL_FILE}" -t "$DIR/src/test/resources/develenv.jmx" \
#   -Jhostname=$URL_SERVER
#   validateJmeterExecution
#   return $?
#}

# Selenium Tests
function seleniumTest(){
   mvn integration-test -Dselenium.host=localhost -Dselenium.port=80 -Dselenium.browser.name=$1 -DurlServer="$URL_SERVER"
   return $?
}

#Seleniun (Firefox) tests example
# Copy, uncomment and modify this function in acceptanceTest.sh
#function acceptanceTestFirefox(){
#   seleniumTest firefox
#   return $?
#}

#Seleniun (Chrome) tests example
# Copy, uncomment and modify this function in acceptanceTest.sh
#function acceptanceTestChrome(){
#   seleniumTest chrome
#   return $?
#}

# SOAPUI Tests
#soapui/bin/testrunner.sh -j -f"$WORKSPACE/reports" -r -a "$WORKSPACE/jira-utils-soapui-project.xml" -PEndpoint=http://urlaprobar.hi.inet

function getParameters(){
  local flagE="false"
  local msg[0]="You need to provide at least one parameter"
  local msg[1]="The options -e,-t and -p requieres a parameter"
  local msg[2]="Illegal option"
  local msg[3]="The -p parameter must be a number"
  local msg[4]="The -e parameter is mandatory and must be the first one"
  while getopts ":e:t:p:h" opt; do
    local errorCode="0"
    case $opt in
      e)
        environmentId=$OPTARG
      ;;
      t)
        deploymentTableFile=$OPTARG 
      ;;
      p)
        [ -z $OPTARG ] && help && errorCode=1 || PAUSE_SECONDS=$OPTARG
        [[ ! $PAUSE_SECONDS =~ ^[0-9]+$ ]] && errorCode=3
        ;;
      h)
        help
        exit 0
        ;;
      :)
        errorCode=1
        ;;
      \?)
        errorCode=2
        ;;
    esac
  done
  [[ "$#" == "0" ]] && errorCode=0
  [[ -z "$environmentId" ]] && errorCode=4
  if [ "$errorCode" != "0" ]; then
       _log "[ERROR] $(printf "${msg[$errorCode]}\n" $opt)"
       help
       return $errorCode
  fi
}

function processDeploymentTableFile(){
   # If they don't give me a deploymentTableFile I need to extract it from this file
   if [ ! -f "$deploymentTableFile" ]; then
      rm -Rf target
      mkdir -p target
      TEST_DEPLOYMENT_FILE="target/deployment"
      lineSeparator=`grep -n "##################### DEPLOYMENT TABLE ############################" $0\
                     |grep -v "grep" |sed s:"\:##################### DEPLOYMENT TABLE ############################":"":g`
      sed 1,${lineSeparator}d $0 > $TEST_DEPLOYMENT_FILE
      deploymentTableFile=$TEST_DEPLOYMENT_FILE
   fi
}

# Get Environment access from deployment Table file
function getEnvironmentAccess(){
  URL_SERVER=$(grep "^$environmentId" ${deploymentTableFile}|cut -d'|' -f2\
              |sed s:"^ *":"":g|sed s:" *$":"":g)
}


function executeTest(){
   failed=false
   for theTest in `grep "^function ${typeTest}Test.*()" $0 \
                          |awk '{ print $2 }'|sed s:"(.*":"":g`;do
      $theTest
      errorCode=$?
      if [ "$errorCode" == "0" ]; then
         echo "${typeTest}Test[$theTest]  Success"
      else 
         echo "${typeTest}Test[$theTest]  Fail"
         failed=true
      fi
   done;
   if [ "$failed" == "false" ]; then
      return 0
   else
      return 1
   fi
}

function init(){
   PAUSE_SECONDS=$DEFAULT_PAUSE_SECONDS
   getParameters $*
   local errorCode=$?
   if [ "$errorCode" != "0" ]; then
      return $errorCode
   fi
   processDeploymentTableFile
}

function main(){
   init $*
   local errorCode=$?
   if [ "$errorCode" != "0" ]; then
      return $errorCode
   fi
   # Esperamos a que esté desplegado el servicio
   _log "[INFO] Esperando $PAUSE_SECONDS segundos para que se inicialice la aplicación"
   getEnvironmentAccess
   if [ "$URL_SERVER" == "" ]; then
      _log "[ERROR] No hay una url definida para el entorno [$environmentId]"
      return 1
   fi
   _log "[INFO] Testing against environment: $environmentId with URL: $URL_SERVER"
   sleep $PAUSE_SECONDS
   executeTest
   return $?
}
DEFAULT_PAUSE_SECONDS=150
#typeTest calculated with the name of the script.
#The name of the script must be finish with Test.sh
#Examples:
#   smokeTest.sh      --> typeTest= smoke
#   acceptanceTest.sh --> typeTest= acceptance
typeTest=$(echo $(basename $0)|sed s:"Test\.sh$":"":g)
if [[ "$typeTest" == "" ]]; then
   _log "[ERROR] The scripts must be finish with Test.sh"
   exit 1
fi
