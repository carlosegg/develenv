#!/bin/bash
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}

function upload(){
    pushd . >/dev/null
    fileToUpload=$1
    fileName=$2
    targetDir=$3
    rm -Rf $UPLOAD_TEMP_DIR
    mkdir -p $UPLOAD_TEMP_DIR
    cd $UPLOAD_TEMP_DIR
    split ${fileToUpload} ${fileName}_ -b 2m -d -a 3
    total=`ls |sort|tail -1 |sed s:".*_":"":g`
    for i in `ls |sort`; do
        index=`echo $i|sed s:".*_":"":g`
        echo Uploading ${i} / Total: $total
   if [ "$targetDir" == "" ]; then
            uploadUrl="${PREFIX_URL}/upload.php?fileName=${fileName}&index=$index&total=$total&execute=true"
        else
          uploadUrl="${PREFIX_URL}/upload.php?fileName=${fileName}&index=$index&total=$total&targetDir=${targetDir}&execute=false"
   fi
   curl --user ${USER_URL}:${pass} $uploadUrl --data-binary @$i
   if [ "$?" != "0" ]; then
      echo "[ERROR] curl --user u59950287:${pass} $uploadUrl --data-binary @$i"
      exit 1
    fi
    done;
    popd >/dev/null   
}

function preprocessSite(){
    pushd . >/dev/null
    OLD_DIR=$PWD
    TEMPSITEDEVELENV=$PROJECT_HOME/temp/site
    REMOTETEMPDIR=
    rm -Rf $TEMPSITEDEVELENV
    mkdir -p $TEMPSITEDEVELENV
    cd $TEMPSITEDEVELENV
    cp -R $UPLOAD_DIR/* .
    IFS=$'\x0A'$'\x0D';sed -i s:"http\://ironman1/":"http\://develenv\.softwaresano\.com/":g `find . -name '*.html'`
    #Si hay que subir el *.sh"
    if [ -f "assemblies/${PROJECT_NAME}-${PROJECT_VERSION}.sh" ]; then
        #Se calcula el md5
   cd assemblies
   md5sum ${PROJECT_NAME}-${PROJECT_VERSION}.sh > ${PROJECT_NAME}-${PROJECT_VERSION}.sh.md5
        cd ..
   upload $PWD/assemblies/${PROJECT_NAME}-${PROJECT_VERSION}.sh.md5 ${PROJECT_NAME}-${PROJECT_VERSION}.sh.md5 /www/softwaresano/downloads/develenv
   rm -Rf $PWD/assemblies/${PROJECT_NAME}-${PROJECT_VERSION}.sh.md5
   upload $PWD/assemblies/${PROJECT_NAME}-${PROJECT_VERSION}.sh ${PROJECT_NAME}-${PROJECT_VERSION}.sh /www/softwaresano/downloads/develenv
   rm -Rf $PWD/assemblies/${PROJECT_NAME}-${PROJECT_VERSION}.sh
    fi
    SITE_OUTPUT_FILE_TGZ="../site.tar.gz"
    tar cvfz ${SITE_OUTPUT_FILE_TGZ} .
    size=`ls -Al ${SITE_OUTPUT_FILE_TGZ}|cut -d' ' -f 5`
    lineSeparator=`grep -n "#### site.sh ####" $OLD_DIR/$0|grep -v "grep" |sed s:"\:#### site.sh ####":"":g`
    sed 1,${lineSeparator}d $OLD_DIR/$0 > ${SITE_OUTPUT_FILE}
    sed -i s:"^SOFTWARESANO_HOME=\"\"$":"SOFTWARESANO_HOME=$SOFTWARESANO_HOME":g ${SITE_OUTPUT_FILE}
    sed -i s:"^TEMP_SOFTWARESANO=\"\"$":"TEMP_SOFTWARESANO=$TEMP_SOFTWARESANO":g ${SITE_OUTPUT_FILE}
    sed -i s:"^size=\"\"$":"size=$size":g ${SITE_OUTPUT_FILE}
    # Agregando tar.gz
    tail -c $size ${SITE_OUTPUT_FILE_TGZ} >>${SITE_OUTPUT_FILE}
    upload ${SITE_OUTPUT_FILE} site.sh
    popd . >/dev/null
}


function help(){
   echo -e "\nuso: $0 <siteDir>"
   echo e " Actualiza el site de ${artifactId} en sofwaresano (http://develenv.softwaresano.com)"
   exit 1
}

function testParams(){
   local useHelp="false"
   if  [ "$1" == "--help" ]; then
       useHelp="true"
   fi

   if  [ $# != 1 ]; then
       useHelp="true"
   fi
}


currentDir
. $DIR/setEnv.sh
PREFIX_URL="http://admin.softwaresano.com"
USER_URL="u59950287"
UPLOAD_DIR=$PROJECT_HOME/docs/$PROJECT_GROUPID/$PROJECT_NAME
SOFTWARESANO_HOME=/homepages/46/d339887408/htdocs
TEMP_SOFTWARESANO=$SOFTWARESANO_HOME/temp
DIR_OUTPUT="$PROJECT_HOME/temp"
SITE_OUTPUT_FILE="$DIR_OUTPUT/site.sh"
UPLOAD_TEMP_DIR=$DIR_OUTPUT/upload
onlyDownloads=""
read -s -p "admin.softwaresano.com --> Enter Password: " pass
echo ""
preprocessSite
exit 0

#### site.sh ####
#!/bin/bash
SOFTWARESANO_HOME=""
TEMP_SOFTWARESANO=""
size=""
if ! [ -d "$SOFTWARESANO_HOME" ]; then
    echo "[ERROR] No existe el directorio $SOFTWARESANO_HOME"
    exit 1
fi
SOURCE=$TEMP_SOFTWARESANO/site.tar.gz
tail -c $size $0 > $SOURCE
pushd . >/dev/null
rm -Rf $TEMP_SOFTWARESANO/site
mkdir -p $TEMP_SOFTWARESANO/site
cd $TEMP_SOFTWARESANO/site
tar xfz $SOURCE
if [ "$?" != "0" ];then
   echo "Error en la descompresión de $SOURCE"
   popd >/dev/null
   rm -Rf $SOURCE
   rm -Rf $TEMP_SOFTWARESANO
   exit 1
fi
rm -Rf $SOURCE
if [ "$?" != "0" ]; then
    echo "[ERROR] $0 corrupto"
    exit 1
fi
if [ -d "$TEMP_SOFTWARESANO/site/assemblies" ]; then
   mkdir -p $SOFTWARESANO_HOME/www/softwaresano/downloads/develenv
   mv $TEMP_SOFTWARESANO/site/assemblies/develenv*.sh $SOFTWARESANO_HOME/www/softwaresano/downloads/develenv
   rm -Rf $TEMP_SOFTWARESANO/site/assemblies/
fi
#Sustituimos el site de develenv
rm -Rf $TEMP_SOFTWARESANO/develenv.ori
mv $SOFTWARESANO_HOME/www/develenv/ $TEMP_SOFTWARESANO/develenv.ori
mv $TEMP_SOFTWARESANO/site $SOFTWARESANO_HOME/www/develenv
popd >/dev/null
rm -Rf $SOURCE
rm -Rf $0
exit 0

