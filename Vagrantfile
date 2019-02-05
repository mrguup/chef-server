# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/bionic64"

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.customize [ "setextradata", 
            :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"
        ]
    end

    config.vm.network "public_network", ip: "192.168.8.100", bridge: "Realtek PCIe GBE Family Controller"
    config.ssh.insert_key = false
    config.ssh.private_key_path = ["data/ssh/id_rsa","~/.vagrant.d/insecure_private_key"]

    config.vm.provision "file", source: "data/ssh/id_rsa.pub", destination: "/tmp/id_rsa.pub"
    config.vm.provision "shell", 
        inline: <<-EOS
            cat /tmp/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
            rm -f /tmp/id_rsa.pub
        EOS

    config.vm.provision "file", source: "data/chef-server.deb", destination: "/tmp/chef-server.deb"
    config.vm.provision "shell", path: "provision.sh", run: "always"

    config.vm.synced_folder "data/host_files", "/mnt/shared_files", create: "true"
end
