#!/bin/sh
if [ -z "$PROJECT_HOME" ]; then
   #Extract ${project.artifactId}_home
   PROJECT_HOME=$(dirname $(dirname $CATALINA_HOME))
fi
export CATALINA_PID=$PROJECT_HOME/${project.artifactId}.pid
export CATALINA_OPTS="-Xmx512m -XX:MaxPermSize=512m -DHUDSON_HOME=$PROJECT_HOME/app/hudson -DWTK_HOME=$PROJECT_HOME/platform/wtk -Dfile.encoding=UTF-8 -Djava.awt.headless=true -Dhudson.DNSMultiCast.disabled=true $CATALINA_OPTS -Dhudson.model.Api.INSECURE=true"