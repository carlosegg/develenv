set CATALINA_PID=${PROJECT_HOME}/${project.artifactId}.pid
set CATALINA_OPTS="-Xmx512m" "-XX:MaxPermSize=512m" "-Dhudson.DNSMultiCast.disabled=true" "-DHUDSON_HOME=${PROJECT_HOME}/app/hudson" "-DWTK_HOME=${PROJECT_HOME}/platform/wtk" "-Dfile.encoding=UTF-8" "-Djava.awt.headless=true" %CATALINA_OPTS%
