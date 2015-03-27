#!/bin/bash
#################
# Es necesario ser root para instalar este ${project.artifactId}
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}

help (){
        echo "Uso: $0 <version>"
        echo "Empaquetado de un plugin"
        echo ""
        echo "EJEMPLOS:"
        echo "    $0 1.0"

}

copyPlugin(){
   plugin_name=`basename $PWD`
   version=$1
   home_plugin=$PROJECT_HOME/temp/package_plugin
   dist_dir=$PWD/target
   rm -Rf $home_plugin
   rm -Rf $dist_dir
   mkdir -p $home_plugin
   pushd . >/dev/null
   cp -R $PWD $home_plugin
   cd $home_plugin
   rm -rf `find . -name ".svn"`
   compileHudsonPlugin $plugin_name
   cd $home_plugin/$plugin_name
   rm -Rf hudson
   jar cvf $home_plugin/../$plugin_name-$version.dp .
   mkdir $dist_dir
   mv $home_plugin/../$plugin_name-$version.dp $dist_dir
   rm -Rf $home_plugin
   echo ===============================================================
   echo Build successfull.
   echo Your plugin is available in $dist_dir/$plugin_name-$version.dp
   echo ===============================================================

   popd . >/dev/null
}


compileHudsonPlugin(){
  pushd . >/dev/null
  plugin_name=$1
  ACTUAL_DIR=$PWD
  if [ -d  "$plugin_name/hudson/plugins" ]; then
     ls $plugin_name/hudson/plugins/
     for i in `ls $plugin_name/hudson/plugins`;do
         cd $ACTUAL_DIR/$plugin_name/hudson/plugins/$i;$PROJECT_HOME/platform/maven/bin/mvn clean install;cp target/$i.hpi $ACTUAL_DIR/$plugin_name/plugin/app/hudson/plugins/
     done
  fi
  popd >/dev/null
}

if [ "$#" != "1" ]; then
   help
   exit 1
fi
currentDir

. $DIR/setEnv.sh
pushd . >/dev/null
copyPlugin $1
popd >/dev/null
