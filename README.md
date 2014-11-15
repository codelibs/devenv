Development on CodeLibs
=======================

## Prerequisite

Install VirtualBox and Vagrant.

* https://www.virtualbox.org/
* http://www.vagrantup.com/

### Create Account For Vagrant Cloud

* http://vagrantcloud.com/

### Install Vagrant-Omnibus Plugin

    vagrant plugin install vagrant-omnibus

## Login Vagrant Cloud

    $ vagrant login

## Install Vagrant's Box

    $ vagrant box list
    $ vagrant box add chef/centos-6.5
    $ vagrant box add chef/centos-7.0

## Development for Elasticsearch

Puts your elasticsearch plugins into data/elasticsearch/plugins and then executes:

    $ cd elasticsearch
    $ vagrant up

You can check log files in data/elasticsearch/logs directory.

## Development for Fess

Executes:

    $ cd fess
    $ vagrant up

You can check log files in data/fess/logs directory.
