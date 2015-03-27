DEPLOY EN MÁQUINAS VAGRANT
===========================

* [Introducción] (#INTRODUCCIN)
* [Requisitos] (#REQUISITOS)
* [Configuración máquina Vagrant] (#CONFIGURACIN_MQUINA_VAGRANT)
* [Ejecución] (#EJECUCION)
* [Ampliación disco duro](#AMPLICACIN_DISCO_DURO)

INTRODUCCIÓN
------------
[Develenv](http://develenv.softwaresano.com) puede ser desplegado y actualizado 
en una máquina [vagrant](http://www.vagrantup.com/).


REQUISITOS
----------
Los requisitos necesarios para trabajar con las máquinas vagrant son:

* [Virtualbox 4.3.16 ó superior](https://www.virtualbox.org/) con el [Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant 1.6.5 ó superior](http://www.vagrantup.com/)

CONFIGURACIÓN MÁQUINA VAGRANT
-----------------------------

Partiendo que el workspace de los proyectos está *$HOME/workspace*
y que la máquina se va a crear en *$HOME/workspace/vagrant/instances*


```
carlosg@ironman:~$ mkdir -p workspace/vagrant/instances
carlosg@ironman:~/workspace/vagrant/instances$ svn export http://develenv.googlecode.com/svn/trunk/develenv/src/main/deploy/puppet ci-develenv-01
carlosg@ironman:~/workspace/vagrant/instances$ cd ci-develenv-01
carlosg@ironman:~/workspace/vagrant/instances/dev-develenv-01$ vi Vagrantfile

```

## Configuración VagrantFile

### Configuración nombre máquina

```
  ### TODO
  config.vm.hostname= "ci-develenv-01"
```

### Configuración nombre máquina dentro de virtual box

Se asigna el mombre a la máquina de virtualbox, lo correcto es que coincida con
el nombre de la máquina

```
  ### TODO
  vb.name = "ci-develenv-01"
```


### Configuración IP

Se puede configurar un ip privada sólo accesible desde la máquina física:

```
  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # La ip debe pertencer al rango del interfaz vboxnet0
  ### TODO
  config.vm.network :private_network, ip: "192.168.33.20"
```

O se puede asignar una IP pública accesible desde cualquier máquina de la red

```
  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  ### TODO
  config.vm.network :public_network
```

### Configuración directorios compartidos con la máquina física 

```
  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  ### TODO
  #config.vm.synced_folder "Directorio máquina física" "Directorio en maquina vagrant"
  config.vm.synced_folder "/Users/carlosg/workspace", "/home/vagrant/workspace"
```

EJECUCIÓN
---------

Antes de levantar por primera vez la máquina virtual es necesiario instalar el 
plugin de las VirtualBox Guest Adittions:

``` 
carlosg@ironman:~/vagrant/instances/ci-develenv-01$  vagrant plugin install vagrant-vbguest
Installing the 'vagrant-vbguest' plugin. This can take a few minutes...
Installed the plugin 'vagrant-vbguest (0.10.0)'!
```

Para levantar la nueva máquina virtual basta con ejecutar el comando "vagrant up". 
La primera vez debe descargarse la imagen base del sistema operativo y a continuación instalar
los rpms asociados a develenv. Si la imagen base y los rpms están en remoto (comportamiento 
por defecto) el arranque de la máquina puede durar 3 horas.

```
carlosg@ironman:~/vagrant/instances/ci-develenv-01$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
[default] Box 'ci-develenv-01' was not found. Fetching box from specified URL for
the provider 'virtualbox'. Note that if the URL does not have
a box for this provider, you should interrupt Vagrant now and add
the box yourself. Otherwise Vagrant will attempt to download the
full box prior to discovering this error.
Downloading or copying the box...
Extracting box...te: 25.3M/s, Estimated time remaining: 0:00:01)
Successfully added box 'ci-develenv-01' with provider 'virtualbox'!
[default] Importing base box 'ci-develenv'...
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

Si la ejecución ha sido correcta y se ha configurado una ip pública, en este caso
10.95.143.172 se podría acceder a la VM:

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
carlosg@ironman:~/vagrant/instances/ci-develenv-01 $ ssh -p 2222 vagrant@localhost
vagrant@localhost's password:
Last login: Mon May  6 17:43:55 2013 from 10.0.2.15
```

o bien via ssh con usuario **vagrant** y password **vagrant**

```
carlosg@ironman:~/vagrant/instances/ci-develenv-01$ ssh vagrant@10.95.143.172
vagrant@localhost's password:
Last login: Mon May  6 17:43:55 2013 from 10.0.2.15
```

Una vez que se han desplegado todos los rpms, se puede acceder a develenv a través
de http://10.95.143.172/ en el caso de que se haya configurado una ip pública.
Si se ha configurado una ip privada se debería acceder a través de http://192.168.33.20/

AMPLIACIÓN DISCO DURO
---------------------

La máquina virtual viene con un disco duro reducido de 5GB se puede ampliar
siguiendo las siguientes [intrucciones](./virtualMachines.html#Ampliacin_de_disco_duro)