DESARROLLO
==========

* [Introducción] (#INTRODUCCIN)
* [Requisitos] (#REQUISITOS)
* [Creación máquina Vagrant] (#CREACIN_MQUINA_VAGRANT)
* [Compilación y empaquetado] (#COMPILACIN_Y_EMPAQUETADO_DE_DEVELENV)

INTRODUCCIÓN
------------
Para desarrollar/corregir errores en develenv se utilizará 
[Vagrant](http://www.vagrantup.com/) de forma que cualquier desarrollador parta
del mismo entorno.

REQUISITOS
----------
Los requisitos necesarios para trabajar con las máquinas vagrant son:

* [Virtualbox 4.3.16 ó superior](https://www.virtualbox.org/)
* [Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant 1.6.5 ó superior](http://www.vagrantup.com/)

CREACIÓN MÁQUINA VAGRANT
-------------------------

Partiendo de la suposición de que ya está descargado develenv en un directorio
de la máquina física(Ejemplo:/home/carlosg/workspace/develenv) y que la máquina
se va a crear en */home/carlosg/vagrant/instances*

```
carlosg@ironman:~$ mkdir -p ~/vagrant/instances/dev-develenv-carlosegg-01
carlosg@ironman:~$ cd ~/vagrant/instances/dev-develenv-carlosegg-01
carlosg@ironman:~/vagrant/instances/dev-develenv-carlosegg-01$ curl http://develenv.googlecode.com/svn/trunk/develenv/src/main/development/vagrant/instance/Vagrantfile
 > Vagrantfile
```
Se edita el fichero *Vagrantfile* y se busca la cadena **config.vm.synced_folder "/Users/carlosg/workspace", "/home/vagrant/workspace"** y se susituye por
**config.vm.synced_folder "/Users/carlosg/workspace", "/home/vagrant/workspace"** 

Se instalan las VirtualBox Guest Adittions

``` 
carlosg@ironman:~/vagrant/instances/dev-develenv-carlosegg-01$  vagrant plugin install vagrant-vbguest
Installing the 'vagrant-vbguest' plugin. This can take a few minutes...
Installed the plugin 'vagrant-vbguest (0.8.0)'!
```
Se arranca la máquina virtual

```
carlosg@ironman:~/vagrant/instances/dev-develenv-carlosegg-01$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
[default] Box 'dev-develenv-02' was not found. Fetching box from specified URL for
the provider 'virtualbox'. Note that if the URL does not have
a box for this provider, you should interrupt Vagrant now and add
the box yourself. Otherwise Vagrant will attempt to download the
full box prior to discovering this error.
Downloading or copying the box...
Extracting box...te: 25.3M/s, Estimated time remaining: 0:00:01)
Successfully added box 'dev-develenv-02' with provider 'virtualbox'!
[default] Importing base box 'dev-develenv-02'...
[default] Matching MAC address for NAT networking...
[default] Setting the name of the VM...
[default] Clearing any previously set forwarded ports...
[default] Creating shared folders metadata...
[default] Clearing any previously set network interfaces...
[default] Available bridged network interfaces:
1) en0: Ethernet
2) en1: Wi-Fi (AirPort)
3) p2p0
What interface should the network bridge to? 2
[default] Preparing network interfaces based on configuration...
[default] Forwarding ports...
[default] -- 22 => 2222 (adapter 1)
[default] Booting VM...
[default] Waiting for VM to boot. This can take a few minutes.
[default] VM booted and ready for use!
GuestAdditions 4.2.12 running --- OK.
[default] Configuring and enabling network interfaces...
[default] Mounting shared folders...
[default] -- /vagrant
[default] -- /home/vagrant/workspace
```

Si la ejecución ha sido correcta se podría acceder a la VM:

```
carlosg@ironman:~/vagrant/instances$ vagrant ssh
[vagrant@develenv ~]$ ls
workspace
[vagrant@develenv ~]$ ifconfig
eth0      Link encap:Ethernet  HWaddr 08:00:27:EE:C5:C4
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:feee:c5c4/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:567 errors:0 dropped:0 overruns:0 frame:0
          TX packets:352 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:59277 (57.8 KiB)  TX bytes:47592 (46.4 KiB)

eth1      Link encap:Ethernet  HWaddr 08:00:27:01:98:88
          inet addr:10.95.143.172  Bcast:10.95.143.255  Mask:255.255.248.0
          inet6 addr: fe80::a00:27ff:fe01:9888/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:21090 errors:0 dropped:0 overruns:0 frame:0
          TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:2555346 (2.4 MiB)  TX bytes:1401 (1.3 KiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
```

o bien via ssh(a través de forwarding ports) con usuario **vagrant** y password **vagrant**

```
carlosg@ironman:~/vagrant/instances$ ssh -p 2222 vagrant@localhost
vagrant@localhost's password:
Last login: Mon May  6 17:43:55 2013 from 10.0.2.2
```

o bien via ssh con usuario **vagrant** y password **vagrant**

```
carlosg@ironman:~/vagrant/instances$ ssh vagrant@10.95.143.172
vagrant@localhost's password:
Last login: Mon May  6 17:43:55 2013 from 10.0.2.2
```

COMPILACIÓN Y EMPAQUETADO DE DEVELENV
-------------------------------------

Para realizar cualquier modificación y su posterior empaquetado de rpms. Se han 
de seguir los siguientes pasos:

```
carlosg@ironman:~/vagrant/instances$ vagrant ssh
[vagrant@develenv ~]$ cd workspace
[vagrant@develenv ~/workspace]$ svn co https://develenv.googlecode.com/svn/trunk/develenv/
[vagrant@develenv ~/workspace/develenv]$ # Compile develenv
[vagrant@develenv ~/workspace/develenv]$ ./build.sh
[vagrant@develenv ~/workspace/develenv]$ # Rpm packages in /vagrant/rpmbuild/RPMS
[vagrant@develenv ~/workspace/develenv]$ deploymentPipeline/src/main/deploymentPipeline/plugin/app/plugins/pipeline_plugin/dp_package.sh
[vagrant@develenv ~/workspace/develenv]$ # Develenv installation in this vagrant machine
[vagrant@develenv ~/workspace/develenv]$ yum install ss-develenv-jenkins-examples ss-develenv-core -y
[vagrant@develenv ~/workspace/develenv]$ # Run smokeTests.sh
[vagrant@develenv ~/workspace/develenv]$ ./smokeTest.sh -e local
[vagrant@develenv ~/workspace/develenv]$ # Run acceptanceTest
[vagrant@develenv ~/workspace/develenv]$ ./acceptanceTest.sh -e local
```