#!/bin/bash
. ./setEnv.sh
cd $PROJECT_HOME/app/jenkins/jobs
#for i in `find  . -maxdepth 2 -name "*" -exec echo {} \;|grep -v "^\.$"|grep -v "config.xml"`; do
for i in `ls`; do
   cd $i
   for j in `find  . -maxdepth 1 -name "*" -exec echo {} \;|grep -v "^\.$"|grep -v "config.xml"`; do
       rm -Rf $j
   done;
   cd ..
done;

