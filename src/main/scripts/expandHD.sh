#!/bin/bash
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}

currentDir
pushd . >/dev/null
cd $DIR
. ./setEnv.sh
popd >/dev/null

if [ $# != 1 ]; then
   echo Uso $0 "<disk>"
fi
partition=/dev/${1}1
PARTITIONS=`ls -al /dev/${1}* 2>/dev/null|wc -l`
if [ "$PARTITIONS" == "1" ]; then
   if [ "$distribution" == "Debian" ]; then
      develenv_root_partition="develenv-root"
      develenv_volume="develenv"
   else   
      develenv_root_partition="vg_develenv-lv_root"
      develenv_volume="vg_develenv"   
   fi
   echo n > fdisk.in
   echo p >> fdisk.in
   echo 1 >> fdisk.in
   echo "" >> fdisk.in
   echo "" >> fdisk.in
   echo "w" >> fdisk.in
   fdisk /dev/${1}< fdisk.in
   mkfs.ext4 $partition
   pvcreate $partition
   vgextend $develenv_volume $partition
   lvextend -l +100%free /dev/mapper/$develenv_root_partition
   resize2fs /dev/mapper/$develenv_root_partition
else
   echo Error en la creación de la partición en $1
fi


