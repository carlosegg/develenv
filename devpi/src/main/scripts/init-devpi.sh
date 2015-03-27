#!/bin/bash
echo "[INFO] Initializing devpi repository"
DEVPI_HOME=/opt/ss/develenv/platform/devpi-server
export PYTHONPATH=$DEVPI_HOME/lib/python2.6/site-packages/
DEVPI_COMMAND="$DEVPI_HOME/bin/devpi"
$DEVPI_COMMAND use http://localhost:4042
$DEVPI_COMMAND login root --password ''
$DEVPI_COMMAND user -m root password=temporal
$DEVPI_COMMAND logoff
$DEVPI_COMMAND user -c develenv password=develenv email=develenv@softwaresano.com
$DEVPI_COMMAND login develenv --password=develenv
$DEVPI_COMMAND index -c dev
$DEVPI_COMMAND use develenv/dev