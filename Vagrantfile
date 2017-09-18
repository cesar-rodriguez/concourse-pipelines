$setup = <<EOF
cd /home/vagrant
git clone https://github.com/cesar-rodriguez/terraform-pipeline.git
cd terraform-pipeline/helper-scripts
./get-tools.sh
./go-vault.sh
EOF

Vagrant.configure("2") do |config|
  config.vm.box = "concourse/lite"
  config.vm.provision "file", source: "~/.aws/credentials", destination: "~/.aws/credentials"
  config.vm.provision "shell", privileged: false, inline: "sudo apt-get -y update > /dev/null && sudo apt-get -y install git unzip jq"
  config.vm.provision "shell", privileged: false, inline: $setup
  config.vm.provider "virtualbox" do |vb|
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/ — timesync-set-threshold", 10000 ]
  end
end
