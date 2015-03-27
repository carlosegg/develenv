#!/bin/bash
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}
setSvnProperties(){
local extension=$1
local mimeType=$2
local filesMime=`find . -name "$extension"`
for i in $filesMime; do
   svn propset svn:mime-type $mimeType $i
done;
}
currentDir
. $DIR/setEnv.sh
pushd .
GOOGLESITE_DIR=$PROJECT_HOME/temp/google
DEPLOYED_SITE_DIR=$PROJECT_HOME/temp/site
rm -Rf $GOOGLESITE_DIR
rm -Rf $DEPLOYED_SITE_DIR
mkdir -p $GOOGLESITE_DIR
cd $GOOGLESITE_DIR
svn co https://develenv.googlecode.com/svn/site
cd site
find . -name "*" | grep -v ".svn"|sort -i >$PROJECT_HOME/temp/googlecode
popd
lineSeparator=`grep -n "#### build.xml ####" $0|grep -v "grep" |sed s:"\:#### build.xml ####":"":g`
echo $lineSeparator
sed 1,${lineSeparator}d $0 > build.xml
$PROJECT_HOME/platform/ant/bin/ant -DPROJECT_HOME=$PROJECT_HOME -DPROJECT_VERSION=$PROJECT_VERSION
cd $DEPLOYED_SITE_DIR
find . -name "*" |grep -v ".tar.gz"|grep -v "*.zip" |grep -v "*.war" | sort -i>../deployedsite
deletedFiles=`diff $PROJECT_HOME/temp/deployedsite $PROJECT_HOME/temp/googlecode|grep "> ."|sed s:"> ":"":g`
cd $GOOGLESITE_DIR/site
for i in $deletedFiles; do
    svn del $i
done

cp -R  $DEPLOYED_SITE_DIR/* $GOOGLESITE_DIR/site
cd $GOOGLESITE_DIR/site
newFiles=`find . -name "*.*" |grep -v ".tar.gz"|grep -v ".zip"|grep -v ".war"|grep -v ".jar"|grep -v ".tgz"|grep -v ".svn"`
for i in $newFiles; do
    svn add $i   
done;
setSvnProperties "*.html" "text/html"
setSvnProperties "*.htm" "text/html"
setSvnProperties "*.xhtml" "text/html"
setSvnProperties "*.jpg" "image/jpeg"
setSvnProperties "*.png" "image/png"
setSvnProperties "*.gif" "image/gif"
setSvnProperties "*.css" "text/css"
setSvnProperties "README" "text/plain"
setSvnProperties "*.txt" "text/plain"
svn ci --username carlosegg
exit 0
#### build.xml ####
<project name="develenv" default="replace" basedir=".">
    <property name="tempSite" value="${PROJECT_HOME}/temp/site"/>
    <property name="dirSite" value="${PROJECT_HOME}/docs/com.softwaresano/develenv"/>
    <property name="ftpServer" value="s339887419.mialojamiento.es"/>
    <property name="domain" value="develenv.softwaresano.com"/>
    <property name="host" value="ironman"/>
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
         token="carlosg@i${host}"
         value="carlosg@${domain}"/>
       <replacefilter
                   token="http://${host}/sites/com.softwaresano/develenv"
                   value="http://${domain}/develenv/"/>

            <replacefilter
                   token="http://${host}/"
                   value="http://${domain}/"/>

                 <replacefilter token="./assemblies/develenv-${PROJECT_VERSION}.sh"
                        value="./substitution.html"
                 />
      <replacefilter token="./maven.zip"
                        value="./substitution.html"
                 />
       <replacefilter token="./maven.tar.gz"
                        value="./substitution.html"
                 />
       </replace>
    </target>
</project>
