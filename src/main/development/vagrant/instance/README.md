Description
===========

A virtual machine description for using with Vagrant.

Requirements
============

You need the `vbguest` plugin for keeping up to date the VirtualBox guest additions.

    $ vagrant plugin install vagrant-vbguest

Usage
=====

Just type

    $ vagrant up

This can take some time if it is the first time you run it.

Then you can access the virtual machine with

    $ vagrant ssh

Building our software
=====================

Once the Vagrant machine is up, you can go to `/home/workspace/develenv` and build our software as usual.
