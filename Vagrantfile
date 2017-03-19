# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify a Consul version
CONSUL_DEMO_VERSION = ENV['CONSUL_DEMO_VERSION']

# Specify a custom Vagrant box for the demo
DEMO_BOX_NAME = ENV['DEMO_BOX_NAME'] || "maier/alpine-3.4-x86_64"

# Vagrantfile API/syntax version.
# NB: Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = DEMO_BOX_NAME
  config.vm.synced_folder ".", "/vagrant", disabled: true 

  config.vm.define "consul1" do |machine|
    machine.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "256"]
      vb.customize ["modifyvm", :id, "--cpus", 1]
    end

    machine.vm.provision "file",
      source:"machines/consul.rc",
      destination: "/home/vagrant/consul.rc"
    
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
    machine.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "256"]
      vb.customize ["modifyvm", :id, "--cpus", 1]
    end

    machine.vm.provision "file",
      source:"machines/consul.rc",
      destination: "/home/vagrant/consul.rc"

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
    machine.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "256"]
      vb.customize ["modifyvm", :id, "--cpus", 1]
    end

    machine.vm.provision "file",
      source:"machines/consul.rc",
      destination: "/home/vagrant/consul.rc"

    machine.vm.provision "file", 
      source:"machines/consul3.json", 
      destination: "/home/vagrant/config.json" 

    machine.vm.hostname = "consul3"
    machine.vm.network "private_network", ip: "172.20.20.30"
    machine.vm.provision "shell" do |s|
      s.path = "machines/install.sh"
    end 
  end

  config.vm.define "elasticsearch" do |machine|
    machine.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "4096"]
      vb.customize ["modifyvm", :id, "--cpus", 1]
    end

    machine.vm.provision "file",
      source:"machines/sysctl-es.conf",
      destination: "/home/vagrant/sysctl-es.conf"

    machine.vm.provision "file", 
      source:"machines/elasticsearch.yml", 
      destination: "/home/vagrant/elasticsearch.yml" 
    
    machine.vm.provision "file",
      source:"machines/elasticsearch.rc",
      destination: "/home/vagrant/elasticsearch.rc"

    machine.vm.provision "file", 
      source:"machines/consul-client.json", 
      destination: "/home/vagrant/config.json"

     machine.vm.provision "file",
      source:"machines/consul.rc",
      destination: "/home/vagrant/consul.rc"

    machine.vm.provision "shell" do |s|
      s.path = "machines/elastic-search.sh"
    end

    machine.vm.network "private_network", ip: "172.20.20.70"
    machine.vm.hostname = "elasticsearch"
  end

  config.vm.define "kibana" do |machine|
    machine.vm.box = "nastevens/alpine-3.5-x86_64"
    machine.vm.network "private_network", ip: "172.20.20.80"
    machine.vm.hostname = "kibana"
    
    machine.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "512"]
      vb.customize ["modifyvm", :id, "--cpus", 1]
    end

    machine.vm.provision "file", 
      source:"machines/consul-client.json", 
      destination: "/home/vagrant/config.old.json"

    machine.vm.provision "file",
      source:"machines/kibana.rc",
      destination: "/home/vagrant/kibana.rc"

    machine.vm.provision "file",
      source:"machines/consul.rc",
      destination: "/home/vagrant/consul.rc"

    machine.vm.provision "file",
      source:"machines/kibana.yml",
      destination:"/home/vagrant/kibana.yml"

    machine.vm.provision "shell" do |s|
      s.path = "machines/kibana-install.sh"
    end  
  end        
end 

