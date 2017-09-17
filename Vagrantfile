$setup = <<EOF
cd /home/vagrant
git clone https://github.com/cesar-rodriguez/terraform-pipeline.git
cd terraform-pipeline/helper-scripts
./get-tools.sh
./go-vault.sh
EOF

Vagrant.configure("2") do |config|
  config.vm.box = "concourse/lite"
  config.vm.provision "shell", privileged: false, inline: $setup
  config.vm.provider "virtualbox" do |vb|
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/ — timesync-set-threshold", 10000 ]
  end
end
