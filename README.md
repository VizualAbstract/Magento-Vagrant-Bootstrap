Magento + Vagrant + VirtualBox
==============================

Get up and running with Magento using Vagrant & VirtualBox. Based on [simple-magento-vagrant](https://github.com/r-baker/simple-magento-vagrant)

![Magento + Vagrant + VirtualBox](http://host.coreycapetillo.com/git/media/vagrant-magento-virtualbox.png?v=2)

## Quickstart Installation

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](http://www.vagrantup.com/)
* In your project directory, run `vagrant up`

## Features

* PHP5
* MySQL
* Git
* Magerun
* Modman
* Compass/Sass

## Configuration
Before running `vagrant up`, it's recommended that you go over the pre-configuration options listed in the Vagrantfile and adjust them to your needs.

| Variable Name | Default Value |
| :-- | --: |
| magento_version | 1.9.1.0 |
| magento_sampleVersion | 1.9.0.0 |
| magento_sampleData | true |
| magento_adminUser | admin |
| magento_adminPassword | password123 |
| magento_dbUser | magento |
| magento_dbPass | magento |
| magento_dbName | magento |
| magento_url | http://127.0.0.1:8080 |
| use_magerun | true |
| use_modman | true |
| use_git | true |
| use_compass | true |
| rvm_version | 1.9.3 |