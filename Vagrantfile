# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "phusion/ubuntu-14.04-amd64"

  config.vm.define "web" do |web|
    web.vm.network "forwarded_port", guest: 80, host: 80

    web.vm.provision "ansible" do |ansible|
      ansible.playbook = "roles/all.yml"
      ansible.extra_vars = { user: "vagrant", type: "web", env: "dev" }
    end
  end

  config.vm.define "worker" do |web|
    web.vm.provision "ansible" do |ansible|
      ansible.playbook = "roles/all.yml"
      ansible.extra_vars = { user: "vagrant", type: "worker", env: "dev" }
    end
  end
end
