# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "puppetlabs/centos-6.6-64-nocm"
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 512]
  end

  config.vm.define :haproxy1, primary: true do |haproxy1_config|

    haproxy1_config.vm.hostname = 'haproxy1'
    haproxy1_config.vm.network :forwarded_port, guest: 8080, host: 8080
    haproxy1_config.vm.network :forwarded_port, guest: 80, host: 8081

    haproxy1_config.vm.network :private_network, ip: "172.28.33.11"
    haproxy1_config.vm.provision :shell do |shell|
            shell.inline = "mkdir -p /etc/puppet/modules;
                           rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm;
                           yum install -y puppet;
                           puppet module install puppetlabs/haproxy;
                           puppet module install arioch/keepalived;
                           puppet apply --environment=production /vagrant/manifests/site.pp"
    end
  end
  config.vm.define :haproxy2, primary: true do |haproxy2_config|

    haproxy2_config.vm.hostname = 'haproxy2'

    haproxy2_config.vm.network :private_network, ip: "172.28.33.12"
    haproxy2_config.vm.provision :shell do |shell|
            shell.inline = "mkdir -p /etc/puppet/modules;
                           rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm;
                           yum install -y puppet;
                           puppet module install puppetlabs/haproxy;
                           puppet module install arioch/keepalived;
                           puppet apply --environment=production /vagrant/manifests/site.pp"
    end
  end
  config.vm.define :web1 do |web1_config|

    web1_config.vm.hostname = 'web1'
    web1_config.vm.network :private_network, ip: "172.28.33.13"
    web1_config.vm.provision :shell, :path => "web-setup.sh"


  end
  config.vm.define :web2 do |web2_config|

    web2_config.vm.hostname = 'web2'
    web2_config.vm.network :private_network, ip: "172.28.33.14"
    web2_config.vm.provision :shell, :path => "web-setup.sh"

  end
#  config.vm.define :web3 do |web3_config|
#
#    web3_config.vm.hostname = 'web3'
#    web3_config.vm.network :private_network, ip: "172.28.33.15"
#    web3_config.vm.provision :shell, :path => "web-setup.sh"
#
#
#  end
#  config.vm.define :web4 do |web4_config|
#
#    web4_config.vm.hostname = 'web4'
#    web4_config.vm.network :private_network, ip: "172.28.33.16"
#    web4_config.vm.provision :shell, :path => "web-setup.sh"
#
#
#  end
end
