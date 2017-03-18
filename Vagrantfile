# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify a Consul version
CONSUL_DEMO_VERSION = ENV['CONSUL_DEMO_VERSION']

# Specify a custom Vagrant box for the demo
DEMO_BOX_NAME = ENV['DEMO_BOX_NAME'] || "maier/alpine-3.3.1-x86_64"

# Vagrantfile API/syntax version.
# NB: Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = DEMO_BOX_NAME
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "256"]
    vb.customize ["modifyvm", :id, "--cpus", 1]
  end

  config.vm.provision "file",
      source:"machines/consul.rc",
      destination: "/home/vagrant/consul.rc"
  
  config.vm.define "consul1" do |machine|
    machine.vm.provision "file", 
      source:"machines/consul1.json", 
      destination: "/home/vagrant/config.json"   
    machine.vm.hostname = "consul1"
    machine.vm.network "private_network", ip: "172.20.20.10"
    machine.vm.provision "shell" do |s|
      s.path = "machines/install.sh"
    end 
  end

  config.vm.define "consul2" do |machine|
    machine.vm.provision "file", 
      source:"machines/consul2.json", 
      destination: "/home/vagrant/config.json" 
    machine.vm.hostname = "consul2"
    machine.vm.network "private_network", ip: "172.20.20.20"
    machine.vm.provision "shell" do |s|
      s.path = "machines/install.sh"
    end 
  end

  config.vm.define "consul3" do |machine|
    machine.vm.provision "file", 
      source:"machines/consul3.json", 
      destination: "/home/vagrant/config.json" 
    machine.vm.hostname = "consul3"
    machine.vm.network "private_network", ip: "172.20.20.30"
    machine.vm.provision "shell" do |s|
      s.path = "machines/install.sh"
    end 
  end
end 
