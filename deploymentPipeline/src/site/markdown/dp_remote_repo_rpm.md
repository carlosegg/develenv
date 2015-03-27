Repositorio de rpms externo a develenv
======================================

Por defecto la *deployment pipeline* deja los rpms en la misma máquina en la
que se ejecuta develenv, en concreto en http://develenv/develenv/rpms. Para dejar los rpms en una ubicación externa a la máquina de develenv, se han de seguir los siguientes pasos:

* [Crear rpm con la configuración del repositorio](#Crear_rpm_con_la_configuracin_del_repositorio)
* [Configurar deployment table](Configurar_deployment_table)

Crear rpm con la configuración del repositorio
----------------------------------------------

```
develenv@ci-pipeline:~/app/plugins/pipeline_plugin$ ./dp_repo_rpm.sh http://develenv.softwaresano.com/develenv/rpms
```
Configurar deployment table
---------------------------
Es necesario añadir a la deployment table la propiedad  **Artifact repository:**. Para ello es necesario editar el job *-install de la pipeline que
se está ejecutando.

```
#!/bin/bash
export DEBUG_PIPELINE="TRUE"
. /home/develenv/app/plugins/pipeline_plugin/pipeline.sh

##################### DEPLOYMENT TABLE ############################
#WARNING: No borrar la línea anterior, ya que es el separador
# del script y de la DEPLOYMENT TABLE


############################### WARNING ######################################
# La tabla siguiente ha sido creada automáticamente a partir de la ejecución #
# del script /home/develenv/app/plugins/pipeline_plugin/pipelineProject.sh. #
# Revise la configuración de dicha tabla #
# Para mas info http://code.google.com/p/develenv-pipeline-plugin #
##############################################################################
# Organization: pdi 
# Project: develenv
# Version: 24
# Enviroments: int qa
# AdminUser: sysadmin
# Artifact repository: http://develenv.softwaresano.com/develenv/rpms 
#--------------+------------------------------------+--------------------------------------------------
# Enviroment   | IPs/Hosts                          | Packages
#--------------+------------------------------------+--------------------------------------------------
int            | int-develenv-01.hi.inet            | ss-develenv-core ss-develenv-jmeter ss-develenv-soapui ss-develenv-ant ss-develenv-maven ss-develenv-maven2 ss-develenv-config ss-develenv-jenkins ss-develenv-jenkins-plugins ss-develenv-nexus ss-develenv-tomcat ss-develenv-sonar ss-develenv-sonar-plugins ss-develenv-sonar-rules
qa             | qa-develenv-01.aislada.hi.inet     | ss-develenv-core ss-develenv-jmeter ss-develenv-soapui ss-develenv-ant ss-develenv-maven ss-develenv-maven2 ss-develenv-config ss-develenv-jenkins ss-develenv-jenkins-plugins ss-develenv-nexus ss-develenv-tomcat ss-develenv-sonar ss-develenv-sonar-plugins ss-develenv-sonar-rules
```
