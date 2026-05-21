# RHCSA 9 lab — CentOS Stream 9 guests, Ansible on Fedora host
# Providers: libvirt (Fedora/KVM, default) and VirtualBox
VAGRANTFILE_API_VERSION = "2"
VAGRANT_DISABLE_VBOXSYMLINKCREATE = "1"

BOX = "generic/centos9s"
file_to_disk1 = "./disk-0-1.vdi"
file_to_disk2 = "./disk-0-2.vdi"
DISK_SETUP = "scripts/provision-server2-disks.sh"

def ansible_provision(vm, playbook)
  vm.vm.provision "ansible" do |ansible|
    ansible.playbook = playbook
    ansible.inventory_path = "inventory"
    ansible.config_file = "ansible.cfg"
    ansible.limit = "all"
    ansible.compatibility_mode = "2.0"
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false
  config.vm.box_check_update = false
  config.vm.box = BOX

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--natdns1", "1"]
  end

  config.vm.provider "libvirt" do |lv|
    lv.uri = "qemu:///system"
    lv.memory = 2048
    lv.cpus = 2
  end

  config.vm.define "repo" do |repo|
    repo.vm.hostname = "repo.nine.example.com"
    repo.vm.network "private_network", ip: "192.168.55.149"
    repo.vm.synced_folder ".", "/vagrant", type: "rsync",
      rsync__exclude: [".git/", "*.vdi", ".github/"]

    repo.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

    repo.vm.provider "libvirt" do |lv|
      lv.memory = 2048
      lv.cpus = 2
    end

    repo.vm.provision "shell", inline: <<-SHELL
      sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
      systemctl restart sshd
      dnf install -y sshpass
    SHELL

    ansible_provision(repo, "playbooks/repo.yml")
  end

  config.vm.define "server2" do |server2|
    server2.vm.hostname = "server2.nine.example.com"
    server2.vm.network "private_network", ip: "192.168.55.151"
    server2.vm.network "private_network", ip: "192.168.55.175"
    server2.vm.network "private_network", ip: "192.168.55.176"
    server2.vm.synced_folder ".", "/vagrant", type: "rsync",
      rsync__exclude: [".git/", "*.vdi", ".github/"]

    server2.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.customize ["storagectl", :id, "--name", "SATA Controller", "--add", "sata", "--portcount", 2]

      unless File.exist?(file_to_disk1)
        vb.customize ["createhd", "--filename", file_to_disk1, "--variant", "Fixed", "--size", 16 * 1024]
      end
      unless File.exist?(file_to_disk2)
        vb.customize ["createhd", "--filename", file_to_disk2, "--variant", "Fixed", "--size", 16 * 1024]
      end

      vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 1,
                    "--device", 0, "--type", "hdd", "--medium", file_to_disk1]
      vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 2,
                    "--device", 0, "--type", "hdd", "--medium", file_to_disk2]
    end

    server2.vm.provider "libvirt" do |lv|
      lv.memory = 2048
      lv.cpus = 2
      lv.storage :file, :size => "16G", :device => "vdb"
      lv.storage :file, :size => "16G", :device => "vdc"
    end

    server2.vm.provision "shell", path: DISK_SETUP
  end

  config.vm.define "server1" do |server1|
    server1.vm.hostname = "server1.nine.example.com"
    server1.vm.network "private_network", ip: "192.168.55.150"
    server1.vm.synced_folder ".", "/vagrant", type: "rsync",
      rsync__exclude: [".git/", "*.vdi", ".github/"]

    server1.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end

    server1.vm.provider "libvirt" do |lv|
      lv.memory = 2048
      lv.cpus = 2
    end

    ansible_provision(server1, "playbooks/master.yml")
    server1.vm.provision "shell", inline: "reboot", run: "always"
  end
end
