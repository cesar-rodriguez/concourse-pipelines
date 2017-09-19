$setup = <<EOF
cd /vagrant/scripts
./get-tools.sh
sudo cp upstart/* /etc/init
EOF

Vagrant.configure("2") do |config|

  # Using concourse lite as base VM https://github.com/concourse/concourse-lite
  config.vm.box = "concourse/lite"

  # Installs dependencies
  config.vm.provision "shell", privileged: false, inline: "sudo apt-get -y update > /dev/null && sudo apt-get -y install unzip jq"

  # Runs scripts that download/configure Concourse and Vault
  config.vm.provision "shell", privileged: false, inline: $setup

  # Reload VM
  config.vm.provision :reload

  # Sync time with host
  config.vm.provider 'virtualbox' do |vb|
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
  end
end
