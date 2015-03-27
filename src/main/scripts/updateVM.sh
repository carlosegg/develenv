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
    echo $UPLOAD_TEMP_DIR
    split ${fileToUpload} ${fileName}_ -b 5M -d -a 3
    total=`ls |sort|tail -1 |sed s:".*_":"":g`
    for i in `ls |sort`; do
        index=`echo $i|sed s:".*_":"":g`
        echo `date` Uploading ${i} / Total: $total
   if [ "$targetDir" == "" ]; then
            uploadUrl="http://85.214.82.106/private/admin/upload.php?fileName=${fileName}&index=$index&total=$total&execute=true"
        else
          uploadUrl="http://85.214.82.106/private/admin/upload.php?fileName=${fileName}&index=$index&total=$total&targetDir=${targetDir}&execute=false"
   fi
   echo "curl --user carlosg:${pass} $uploadUrl --data-binary @$i"
   curl --user carlosg:${pass} $uploadUrl --data-binary @$i
   if [ "$?" != "0" ]; then
      echo "[ERROR] curl --user u59950287:${pass} $uploadUrl --data-binary @$i"
      exit 1
    fi
        rm -Rf $i
    done;
    popd >/dev/null   
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
DIR_OUTPUT="$PROJECT_HOME/temp"
UPLOAD_TEMP_DIR=/home/develenv/temp/compress
read -s -p "admin.softwaresano.com --> Enter Password: " pass
echo ""
#upload "/media/EECE-DA29/develenv_ubuntu_11.04(64bits).ova"  "develenv_ubuntu_11.04(64bits).ova" public/downloads
#upload "/home/develenv/temp/VM/develenv_ubuntu1110-1.7.9.ova"  "develenv_ubuntu1110-1.7.9.ova" /www/public/downloads
upload "/home/develenv/temp/VM/develenv_ubuntu1110-1.7.9.ova.md5"  "develenv_ubuntu1110-1.7.9.ova.md5" /www/public/downloads
exit 0

