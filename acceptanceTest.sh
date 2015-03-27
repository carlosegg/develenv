#!/bin/bash
# Mas info: http://develenv.softwaresano.com/deploymentPipeline/libtest.html y
#           http://develenv.softwaresano.com/deploymentPipeline/index.html#Smoke_Test

function acceptanceTestDevelenv(){
   jmeterExecution \
      "$(dirname $(readlink -f $0))/src/test/resources/develenv.jmx" \
      "$URL_SERVER"
  return $?
}

# import libtest
source $(dirname $(python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $0))/libtest.sh
main $*
exit $?

##################### DEPLOYMENT TABLE ############################
#WARNING: No borrar la línea anterior, ya que es el separador
# del script y de la DEPLOYMENT TABLE
#--------------+--------------------------------------------------------------
# Enviroment   | URL 
#--------------+--------------------------------------------------------------
int            | int-develenv-01.hi.inet
qa             | qa-develenv-01.aislada.hi.inet
local          | http://localhost
