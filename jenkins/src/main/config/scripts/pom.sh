#!/bin/bash
. ${PROJECT_HOME}/bin/setEnv.sh
createDevelopers() {
DEVELOPER=""
for i in `cat target/site/svn.log|grep author|cut -d '>' -f2|cut -d '<' -f1|sort|uniq -i`;do

DEVELOPER="$DEVELOPER<developer> \
         <id>$i</id> \
         <name>$i</name> \
         <email>$i@softwaresano.com</email> \
         <roles> \
            <role>developer</role> \
         </roles> \
         <organization>SoftwareSano.com</organization>\
         <timezone>+1</timezone>\
      </developer>"
done
DEVELOPERS="<developers>$DEVELOPER</developers>"
cat sintetic_pom.xml| sed s:"<!-- DEVELOPERS -->":"$DEVELOPERS":g>sintetic_pom.xml.backup
}
createCIUsers() {
DEVELOPER=""
for i in `cat target/site/svn.log|grep author|cut -d '>' -f2|cut -d '<' -f1|sort|uniq -i`;do

DEVELOPER="$DEVELOPER<notifier>\
            <type>mail</type>\
                      <sendOnError>true</sendOnError>\
            <sendOnFailure>true</sendOnFailure>\
            <sendOnSuccess>false</sendOnSuccess>\
            <sendOnWarning>false</sendOnWarning>\
            <configuration>\
         <address>$i@softwaresano.com</address>\
         </configuration>\
         </notifier>"
done
DEVELOPERS="<ciManagement>
      <system>Hudson</system>

      <notifiers>$DEVELOPER</notifiers>
   </ciManagement>
   "

cat sintetic_pom.xml.backup| sed s:"pepelucas":"kakalucas":g>sintetic_pom.xml
}

calculateCPD(){
$JAVA_HOME/bin/java -classpath $PROJECT_HOME/platform/cpd/pmd-4.2.5.jar:$PROJECT_HOME/platform/cpd/ams-3.1.jar:$PROJECT_HOME/platform/cpd/jaxen-1.1.1.jar:$PROJECT_HOME/platform/cpd/junit-4.4.jar \
        net.sourceforge.pmd.cpd.CPD --minimum-tokens 100 --language $1 \
        --files . --format net.sourceforge.pmd.cpd.XMLRenderer > target/site/cpd_$1.xml
xsltproc $PROJECT_HOME/platform/cpd/xslt/cpdhtml.xslt target/site/cpd_$1.xml > target/site/cpd_$1.html
}

DIR_PROJECT=$PWD
cd ../../
vArtifactId=`basename $PWD`
vGroupId=`hostname`
vSubversionUrl=`cat $PWD/config.xml|grep remote|cut -f2 -d">"|cut -f1 -d'<'`
vDescription=`cat $PWD/config.xml|grep description|cut -f2 -d">"|cut -f1 -d'<'`
vVersion="1.0.0"
vName="`hostname` - $vArtifactId"
cd $DIR_PROJECT
vReportOutputDirectory=$PWD
rm -Rf pom.xml
mvn $PROJECT_HOME/platform/maven/bin/mvn  -f sintetic_pom.xml \
      -DvArtifactId=$vArtifactId -DvGroupId=$vGroupId -DvVersion=$vVersion \
      -DvName="$vName" \
      -DvDescription="$vDescription" \
      -DvWorkspace="$vReportOutputDirectory" \
      -DvSite.url="$SITE_URL" \
      -DvAdministratorId=$ADMINISTRATOR_ID \
      -DvSubversionUrl=$vSubversionUrl \
      -Dyear=`date '+%Y'` clean

mkdir -p target/site/statscm
LANGUAGES="c cpp h java php py rb html js sql"
for i in $LANGUAGES; do
   present=`find . -name "*.$i"`
   if [ "$present" != "" ]; then
      calculateCPD $i
   fi
done
svn log --xml -v >target/site/svn.log
sloccount --wide --details >target/site/sloccount.sc
$JAVA_HOME/bin/java -jar $PROJECT_HOME/platform/statsvn/statsvn.jar target/site/svn.log . -output-dir target/site/statscm
mvn $PROJECT_HOME/platform/maven/bin/mvn  -f sintetic_pom.xml \
      -DvArtifactId=$vArtifactId -DvGroupId=$vGroupId -DvVersion=$vVersion \
      -DvName="$vName" \
      -DvDescription="$vDescription" \
      -DvWorkspace="$vReportOutputDirectory" \
      -DvSite.url="$SITE_URL" \
      -DvAdministratorId=$ADMINISTRATOR_ID \
      -DvSubversionUrl=$vSubversionUrl \
      -Dyear=`date '+%Y'` site:site site:deploy sonar:sonar

