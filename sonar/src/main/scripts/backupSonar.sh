#!/bin/bash
if [ "$#" != 1 ]; then
   echo "Error"
   echo "Uso:"
   echo "   $0 <sonar_password>"
   exit
fi
fileBackup=sonar-`date +"%y-%m-%d_%H-%M-%S"`.sql
mysqldump --opt --password=$1 --user=root sonar > $fileBackup
if [ "$0" == 0 ]; then
   echo Backup realizado correctamente en $fileBackup   
fi


