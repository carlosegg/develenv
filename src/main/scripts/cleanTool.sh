#!/bin/bash
function statusDevelenv(){
   local status=$(service $PROJECT_NAME status)
   [[ $status =~ .*\ running.* ]] && echo "Started" || echo "Stopped"
}
function checkUser(){
   local userExecution=$(id -un)
   if [ "$userExecution" != "root" -a "$userExecution" != "$PROJECT_USER" ]; then
      _log "[ERROR] Only root or $PROJECT_USER can be execute this script"
      exit 1
   fi
}
function cleanTool(){
   local serviceMessage="[INFO] You can do this with: sudo service $PROJECT_NAME"
   if [ $(statusDevelenv) == "Stopped" ]; then
      checkUser
      clean
      _log "[INFO] $PROJECT_NAME is stopped, remember to start it again!"
      _log "$serviceMessage start"
   else
      _log "[ERROR] This scritp must be run with $PROJECT_NAME stopped, please Stop $PROJECT_NAME first"
      _log "$serviceMessage $PROJECT_NAME stop"
   fi
}
