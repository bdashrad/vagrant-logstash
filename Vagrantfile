# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"

  # Set Hostname
  config.vm.hostname = "logstash"

  # Set up port forwarding
  #config.vm.network :forwarded_port, guest: 9200, host: 9200
  config.vm.network :forwarded_port, guest: 5601, host: 5601
  #config.vm.network :forwarded_port, guest: 80, host: 8080

  # Set a private IP to access the guest at
  config.vm.network "private_network", ip: "192.168.33.10"

  # Use the virtualbox provider
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # Enable provisioning with bash!
  config.vm.provision :shell, path: "boostrap.sh"
end
