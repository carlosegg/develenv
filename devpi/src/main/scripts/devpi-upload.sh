#!/bin/bash
DEVPI_HOME=/opt/ss/develenv/platform/devpi-client
export PYTHONPATH=$DEVPI_HOME/lib/python2.6/site-packages
DEVPI_COMMAND="$DEVPI_HOME/bin/devpi"
$DEVPI_COMMAND login develenv --password=develenv
if [[ -f setup.cfg ]]; then
   git add -f setup.cfg
fi
if [[ -f VERSION ]]; then
   git add -f VERSION
fi
# SCM_INFO contains url and hash of scm
if [[ -f SCM_INFO ]]; then
   git add -f SCM_INFO
fi
$DEVPI_COMMAND upload