#!/bin/bash
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}
currentDir
. $DIR/setEnv.sh
lineSeparator=`grep -n "#### build.xml ####" $0|grep -v "grep" |cut -d':' -f1`
echo $lineSeparator
sed 1,${lineSeparator}d $0 > build.xml
$PROJECT_HOME/platform/ant/bin/ant -DPROJECT_HOME=$PROJECT_HOME -DHOSTNAME=`hostname`
$PROJECT_HOME/bin/updateSoftwaresano.sh $PROJECT_HOME/temp/site tools/develenv/site $PROJECT_HOME/temp/softwaresano
rm build.xml
exit 0

#### build.xml ####
<project name="develenv" default="replace" basedir=".">
    <property name="tempSite" value="${PROJECT_HOME}/temp/site"/>
    <property name="dirSite" value="${PROJECT_HOME}/docs/com.softwaresano/develenv"/>
    <property name="domain" value="softwaresano.com"/>
    <property name="host" value="${HOSTNAME}" />
    <target name="replace" >
          <delete dir="${tempSite}"/>
          <mkdir dir="${tempSite}" />
          <copy toDir="${tempSite}">
                <fileset dir="${dirSite}"/>
          </copy>
         <replace  dir="${tempSite}"  >
            <include name="**/*.html"/>
       <replacefilter
         token="root@${host}"
         value="root@${domain}"/>

       <replacefilter
         token="carlosg@${host}"
         value="carlosg@${domain}"/>
       <replacefilter
                   token="http://${host}/sites/com.softwaresano/develenv"
                   value="http://${domain}/develenv/"/>

            <replacefilter
                   token="http://${host}/"
                   value="http://${domain}/"/>
       </replace>
    </target>
</project>
