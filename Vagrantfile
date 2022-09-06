Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: """
        cp /host/install.sh ~vagrant/
        chown vagrant ~vagrant/install.sh
        export DEBIAN_FRONTEND=noninteractive
        yes | sudo -u vagrant ~vagrant/install.sh
    """
   
    config.vm.synced_folder "./", "/host"
  
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end

    config.vm.define "jammy", autostart: false  do |jammy|
        jammy.vm.box = "ubuntu/jammy64"
    end

    config.vm.define "focal", autostart: false  do |focal|
        focal.vm.box = "ubuntu/focal64"
    end

    config.vm.define "bullseye", autostart: false  do |bullseye|
        bullseye.vm.box = "debian/bullseye64"
    end

    config.vm.define "centos8", autostart: false  do |centos8|
        centos8.vm.box = "generic/centos8"
    end

    config.vm.define "playground", autostart: false do |playground|
        playground.vm.box = "ubuntu/jammy64"
        playground.vm.provider "virtualbox" do |vb|
            vb.memory = "16384"
        end
    end

  end