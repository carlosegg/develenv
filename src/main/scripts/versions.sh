#!/bin/bash
function modifiedSCM(){
   MODIFIES=`svn st |egrep "M |D |A "`
   if [ "$MODIFIES" != "" ]; then
      echo "[ERROR] Existen cambios en local que no están subidos al repositorio"      
      exit 1
   fi
   return 0
}
if  [ "$#" != 1 ]; then
    echo "Uso: $0 <nextVersion>"
    exit 1
fi

nextVersion=$1

newVersion=`grep "<version>" pom.xml|head -n 1|sed s:"</\?version>":"":g|sed s:"-SNAPSHOT":"":g|awk '{print $1}'`
if [ "$newVersion" == "$nextVersion" ]; then
   echo "[ERROR] La siguiente version ($nextVersion) es idéntica a la actual ($newVersion)"      
   exit 2
fi
wget http://develenv.googlecode.com/svn/tags/ -O develenvVersions
existVersion=$(grep "develenv-${newVersion} develenvVersions")
rm -Rf develenvVersions
if [ "$existVersion" != "" ]; then
   echo "[ERROR] La version ($nextVersion) ya existe"      
   exit 3
fi

modifiedSCM
cd ../extdevelenv
modifiedSCM
RELEASE_COMMENT="[RELEASE] develenv ${newVersion}"
echo svn copy https://extdevelenv-softwaresano.googlecode.com/svn/trunk/develenv https://extdevelenv-softwaresano.googlecode.com/svn/tags/develenv-${newVersion} -m "${RELEASE_COMMENT}"
svn copy https://extdevelenv-softwaresano.googlecode.com/svn/trunk/develenv https://extdevelenv-softwaresano.googlecode.com/svn/tags/develenv-${newVersion} -m "${RELEASE_COMMENT}" --username carlosegg
cd ../develenv
svn propget svn:externals > /tmp/develenv_externals
cat /tmp/develenv_externals|sed s:"/trunk/develenv/":"/tags/develenv-${newVersion}/":g > /tmp/develenv_newExternals
svn propset svn:externals . -F /tmp/develenv_newExternals
svn up
sed s:"#set( \$versiones = \[":"#set( \$versiones = \[\"${newVersion}\", ":g src/site/apt/downloads/releases.apt.vm > /tmp/develenv_releases.apt.vm
rm src/site/apt/downloads/releases.apt.vm
mv  /tmp/develenv_releases.apt.vm src/site/apt/downloads/releases.apt.vm
export MAVEN_HOME=$PWD/src/main/tools/platform/maven/
export PATH=$MAVEN_HOME/bin:$PATH
mvn versions:set -DnewVersion=${newVersion}
svn ci . -m "${RELEASE_COMMENT}"
svn copy https://develenv.googlecode.com/svn/trunk/develenv https://develenv.googlecode.com/svn/tags/develenv-${newVersion} -m "${RELEASE_COMMENT}" --username carlosegg
mvn versions:set -DnewVersion=${nextVersion}-SNAPSHOT
svn propset svn:externals . -F /tmp/develenv_externals
createDate=`date +%Y-%m-%d`
sed -i s:"<\!-- ADD LAST RELEASES -->":"<\!-- ADD LAST RELEASES -->\n <release version=\"${nextVersion}\" date=\"${createDate}\" description=\"Add description\"></release>":g src/changes/changes.xml
svn up
svn ci -m "[MINOR] Starting release ${nextVersion}"
rm -Rf /tmp/develenv_*
LANG=C
revision=`svn info|grep "Revision:"|sed s:"Revision\: ":"":g`
release_revision=`expr $revision - 2`
echo Construyendo build para la relases ${newVersion}
svn up -r $release_revision
./configure











