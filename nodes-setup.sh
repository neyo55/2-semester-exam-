#!/bin/bash


# create a vagrant file
touch Vagrantfile

# edit the vagrant file
cat <<EOF > Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Define the Ubuntu 22.04 box for master
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.define "master" do |master|
    master.vm.box = "bento/ubuntu-22.04"
    master.vm.hostname = "master"
    master.vm.network "private_network", type: "static", ip: "192.168.56.40"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "1024" # 1GB RAM
      vb.cpus = "1"
    end

    master.vm.provision "shell", path: "lamp.sh"
  end

  config.vm.define "slave" do |slave|
  config.vm.box = "bento/ubuntu-22.04"
    slave.vm.network "private_network", type: "static", ip: "192.168.56.41"
    slave.vm.hostname = "slave"
    slave.vm.provider "virtualbox" do |vb|
      vb.memory = "1024" # 1GB RAM
      vb.cpus = "1"
    end

    slave.vm.provision "ansible" do |ansible|
      ansible.playbook = "laravel.yml"
      ansible.inventory_path = "/home/neyo55/Desktop/confirmed/inventory.ini" 
    end
  end  
end
EOF

# start vagrant
vagrant up