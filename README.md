Development on CodeLibs
=======================

## Install Vagrant Box

    $ vagrant box add centos6 http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130731.box

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
