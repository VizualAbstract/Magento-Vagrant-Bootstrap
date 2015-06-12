# Pre-Configuration Variables
# ---------------------------------------------------------------------- */
magento_version = "1.9.1.0"
magento_sampleVersion = "1.9.0.0"
magento_sampleData = "true"

magento_adminUser = "admin"
magento_adminPassword = "password123"

magento_dbUser = "magento"
magento_dbPass = "magento"
magento_dbName = "magento"
magento_url = "http://127.0.0.1:8080/"

use_git = "true"
use_magerun = "true"
use_modman = "true"
use_compass = "true"

# Run Vagrant Configuration
# ---------------------------------------------------------------------- */
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64" # https://vagrantcloud.com/ubuntu/boxes/trusty64/versions/20150609.0.1/providers/virtualbox.box

  config.vm.provision :shell, :path => "vm_provisions/bootstrap.sh", :args =>[
    magento_version,
    magento_sampleVersion,
    magento_sampleData,
    magento_adminUser,
    magento_adminPassword,
    magento_dbUser,
    magento_dbPass,
    magento_dbName,
    magento_url,
    use_git,
    use_magerun,
    use_modman,
    use_compass
  ]

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777", "fmode=666"]
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.name = "magento-vagrant"
  end
end