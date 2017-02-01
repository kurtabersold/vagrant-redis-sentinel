# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.box = "ubuntu/precise64"
  # config.vm.network "public_network"
  #config.vm.network "public_network", bridge: "eno1"
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
  config.vm.provision "shell", inline: <<-SHELL
    # https://redis.io/topics/sentinel
    if [[ ! -x /site/redis/src/redis-sentinel ]]; then
      # Install
      apt-get update -qy
      apt-get install -qy git nmap
      mkdir -p /site
      mkdir -p /usr/local/src/redis && cd /usr/local/src/redis
      wget http://download.redis.io/releases/redis-3.2.6.tar.gz
      tar xzf redis-3.2.6.tar.gz
      cd redis-3.2.6
      make
      ln -sf /usr/local/src/redis/redis-3.2.6 /site/redis
      cp /vagrant/conf/redis-sentinel-upstart.conf /etc/init/redis-sentinel.conf
      cp /vagrant/conf/redis-server-upstart.conf /etc/init/redis-server.conf
      echo ${HOSTNAME} > /etc/hostname
      echo "192.168.33.10 host1" >> /etc/hosts
      echo "192.168.33.20 host2" >> /etc/hosts
      echo "192.168.33.30 host3" >> /etc/hosts
      cp /vagrant/conf/${HOSTNAME}/redis.conf /site/redis/redis.conf
      cp /vagrant/conf/${HOSTNAME}/sentinel.conf /site/redis/sentinel.conf
      # Prepare system
      sysctl vm.overcommit_memory=1
      echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
      echo never > /sys/kernel/mm/transparent_hugepage/enabled
      # Start services
      initctl reload-configuration
      service redis-sentinel start
      service redis-server start
    fi
    true
  SHELL

  config.vm.define "host1" do |host1|
    host1.vm.hostname = "host1"
    host1.vm.network "private_network", ip: "192.168.33.10"
    host1.vm.network "forwarded_port", guest: 6379, host: 6310    # redis
    host1.vm.network "forwarded_port", guest: 26379, host: 26310  # sentinel
    host1.vm.provision "shell", inline: <<-SHELL
      true
    SHELL
  end

  config.vm.define "host2" do |host2|
    host2.vm.hostname = "host2"
    host2.vm.network "private_network", ip: "192.168.33.20"
    host2.vm.network "forwarded_port", guest: 6379, host: 6320
    host2.vm.network "forwarded_port", guest: 26379, host: 26320
    host2.vm.provision "shell", inline: <<-SHELL
      true
    SHELL
  end

  config.vm.define "host3" do |host3|
    host3.vm.hostname = "host3"
    host3.vm.network "private_network", ip: "192.168.33.30"
    host3.vm.network "forwarded_port", guest: 6379, host: 6330
    host3.vm.network "forwarded_port", guest: 26379, host: 26330
    host3.vm.provision "shell", inline: <<-SHELL
      true
    SHELL
  end

end
