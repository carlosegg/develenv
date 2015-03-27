#!/bin/bash
#################################################
# wget https://code.google.com/p/develenv-php-plugin/downloads/list
# cat list|grep "<a href=\"http://develenv-php-plugin.googlecode.com/files/"|sed s:".*'Download - Downloaded', '":"":g|sed s:"'.*":"":g
# http://www.tonybhimani.com/2008/04/30/creating-multi-volume-archives-and-checksums/


#################
# Es necesario ser root para instalar este ${project.artifactId}
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}

help (){
        echo "Uso: $0 <name> <svn_url>"
        echo "Configuración plugin"
        echo ""
        echo "EJEMPLOS:"
        echo " A partir de los fuentes:"
        echo "    $0 php_plugin http://develenv-php-plugin.googlecode.com/svn/trunk/php_plugin"
        echo " A partir de un binario"
        echo "    $0 php_plugin http://develenv-php-plugin.googlecode.com/files/php_plugin-4.dp "
        echo " ó "
        echo "    $0 php_plugin /tmp/php_plugin.dp"
        echo "LISTA DE PLUGINS:"
        echo "    Consulta http://code.google.com/p/develenv-plugins/ para ver todos los plugins disponibles"

}

extractPlugin (){
   source_plugin="$1"
   target="$2"
   length=${#source_plugin}
   if (( $length > 3 )) ; then
      jarextension=${source_plugin: -3}
      if [ "$jarextension" == ".dp" ]; then
         if [ "${source_plugin:0:7}" == "http://" ]; then
            wget $source_plugin -O plugin.dp
            if [ "$?" != 0 ]; then
               echo "Error in http connection[$source_plugin]"
               exit 2
            fi
            source_plugin=$PWD/plugin.dp
         fi
         mkdir -p $target
         cd $target
         jar xvf $source_plugin
         cd ..
         rm -Rf plugin.dp
      else
         if [ "$jarextension" == "git" ]; then
                 git clone $source_plugin $target
         else
              svn export $source_plugin $target
         fi
         if [ "$?" != 0 ]; then
               echo "Error in $source_plugin download"
               exit 2
         fi
      fi
   else
      echo "Incorrect plugin"
      exit 1
   fi
}

compileHudsonPlugin(){
  pushd . >/dev/null
  plugin_name=$1
  ACTUAL_DIR=$PWD
  if [ -d  "$plugin_name/hudson/plugins" ]; then
     ls $plugin_name/hudson/plugins/
     for i in `ls $plugin_name/hudson/plugins`;do
         su $PROJECT_USER -c "cd $ACTUAL_DIR/$plugin_name/hudson/plugins/$i;$PROJECT_HOME/platform/maven/bin/mvn clean install;cp target/$i.hpi $PROJECT_HOME/app/hudson/plugins/"
     done
  fi
  popd >/dev/null
}


copyDir(){
  source_dir=$1
  target_dir=$2
  if [ -d "$source_dir" ]; then
     ndirs=`ls -l $source_dir|cut -d' ' -f2`
     if [ "$ndirs" != "0" ]; then
          cp -R $source_dir/* $target_dir
     fi
  fi
}


addJobsToDevelenvView(){
   pushd . >/dev/null
   cd $1/plugin/app/hudson/jobs
   find . -maxdepth 1 -name "*"|grep -v "\.\/\."|while read line; do
     if [ "$line" != "." ]; then
        line2=`echo $line|sed s:"\./":"":g`
        exists=$(grep "<string>$line2</string>" $PROJECT_HOME/app/hudson/config.xml)
        if [ "$exists" == "" ]; then
           sed -i  s:"<string>develenv</string>":"<string>develenv</string>\n\t<string>$line2</string>":g $PROJECT_HOME/app/hudson/config.xml
        fi
     fi
   done
   popd >/dev/null
}

cleanCacheRedHat(){
   yum clean all
}

cleanCacheDebian(){
   aptitude clean
}

cleanCachePackages(){
   cleanCache${distribution}

}

if [ "`id|grep \"uid=0\"`" == "" ]; then
   echo "Para instalar un plugin es necesario ser root"
   exit 2
fi

if [ "$#" != "2" ]; then
   help
   exit 1
fi
currentDir

. ./setEnv.sh
pushd . >/dev/null
rm -Rf $PROJECT_HOME/temp/$1
mkdir -p $PROJECT_HOME/temp
# Test if access to temp is success.
if [ "$?" != 0 ]; then
   _log "[ERROR] Unable to access to the $PROJECT_HOME/temp directory."
   exit 1
fi
chown -R $PROJECT_USER:$PROJECT_USER  $PROJECT_HOME/temp
mkdir -p $PROJECT_HOME/temp/$1
cd $PROJECT_HOME/temp/$1
extractPlugin $2 $1
chmod 755 -R $1
chown -R $PROJECT_USER:$PROJECT_USER $1
compileHudsonPlugin $1
current_time=`date +%T`
minute="`date -u -d$current_time-0010 '+%M'`"
hour="`date -u -d$current_time-0010 '+%H'`"
sed -i 's/\*\ \*\ \*\ \*\ \*/'$minute'\ '$hour'\ \*\ \*\ \*/' `find . -name config.xml`

mkdir -p $PROJECT_HOME/app/plugins
chown -R $PROJECT_USER:$PROJECT_USER $PROJECT_HOME/app/plugins
copyDir $1/plugin/app/hudson/jobs $PROJECT_HOME/app/hudson/jobs
copyDir $1/plugin/app/hudson/plugins $PROJECT_HOME/app/hudson/plugins
copyDir $1/plugin/app/sites $PROJECT_HOME/app/sites
copyDir $1/plugin/bin $PROJECT_HOME/bin
copyDir $1/plugin/app/plugins $PROJECT_HOME/app/plugins
copyDir $1/plugin/platform $PROJECT_HOME/platform

chown -R $PROJECT_USER:$PROJECT_USER $PROJECT_HOME/app/hudson/jobs/*
chown -R $PROJECT_USER:$PROJECT_USER $PROJECT_HOME/app/hudson/plugins/*
chown -R $PROJECT_USER:$PROJECT_USER $PROJECT_HOME/app/sites/*
chown -R $PROJECT_USER:$PROJECT_USER $PROJECT_HOME/bin/*
chown -R $PROJECT_USER:$PROJECT_USER $PROJECT_HOME/app/plugins/*
chown  $PROJECT_USER:$PROJECT_USER $PROJECT_HOME/app/plugins
#Agregando jobs a la vista de develenv
addJobsToDevelenvView $1

cd $PROJECT_HOME/bin
chmod 755 ./$1.sh
./$1.sh
rm -Rf $PROJECT_HOME/temp/$1
rm -Rf $1.sh
cleanCachePackages
popd >/dev/null

/etc/init.d/$PROJECT_NAME restart

