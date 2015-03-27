#!/bin/bash -x
      PROJECT_NAME=develenv
      INSTALL_DIR_LOG=/tmp
      PROJECT_VERSION=32
      HOSTNAME=int-develenv-01.hi.inet
      PROJECT_HOME=/home/develenv
      prefix=/home/develenv
      enviroment=native
      crond="12 12 * * *"
      profileorg="-Dorg=default_organization"
      PROJECT_USER="develenv"
      JAVA_HOME="/usr/java/default/"
      pushd .
      cd /etc/develenv/
      # Remove broken links
      rm -Rf $(find -L * -type l)
      popd
   su $PROJECT_USER -c "../platform/ant/bin/ant -l $INSTALL_DIR_LOG/${PROJECT_NAME}.log -buildfile $PROJECT_HOME/install/buildfile_min.xml \
            -Ddevelenv.host=$HOSTNAME -Ddevelenv.port="" \
            -Ddevelenv.prefix="$prefix" -Denv=$enviroment \
            -Ddevelenv.crond=\"$crond\" \
            -Ddevelenv.projectName=$PROJECT_NAME \
            -Ddevelenv.projectVersion=$PROJECT_VERSION \
            -Ddevelenv.projectHome=$PROJECT_HOME \
            -Ddevelenv.java.home=$JAVA_HOME  -Dadministrator.id=rga -Dpassword=develenv -Dorg=http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/tid.properties $profileorg >$INSTALL_DIR_LOG/${PROJECT_NAME}.error.log"
   # TODO 
   # Falta la ejecución del replace user

   if [ "$?" != "0" ]; then
      echo "[ERROR] Error durante la personalización.
Revisa $INSTALL_DIR_LOG/${PROJECT_NAME}.error.log y $INSTALL_DIR_LOG/${PROJECT_NAME}.log"
      exit 1
   fi