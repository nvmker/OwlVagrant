# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  # config.vm.box = "debian/jessie64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL

  config.vm.box = "debian/jessie64"

  # restrict box version to ensure we are all using the same box.
  # always test a `vagrant destroy; vagrant up` after changing this.
  config.vm.box_version = "8.3.0"

  config.vm.hostname = "ulrike"

  config.vm.network "forwarded_port", guest: 80, host: 4567

  # gives our vm an ip address, so we can route to it with a hosts file
  config.vm.network "private_network", ip: "192.168.50.4"

  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root",
    owner: "vagrant",
    group: "www-data",
    mount_options: ["dmode=775,fmode=664"]

  config.vm.provision "shell", inline: <<-SHELL

    # `apt-key update` will update apt's list of secure packages
    sudo apt-key update

    sudo apt-get update
    sudo apt-get install -y apache2 php5 libapache2-mod-php5
    sudo apt-get -y install libapache2-mod-proxy-html
    # if ! [ -L /var/www ]; then
    #   rm -rf /var/www
    #   ln -fs /vagrant /var/www
    # fi
    sudo mkdir -p /var/www
    sudo rsync -rav /vagrant/html/ /var/www

    sudo cp /vagrant/apacheconf/* /etc/apache2/sites-available/
    sudo a2ensite staging.hoxtonowl.com
    sudo a2ensite staging.hoxtonowl.com-ssl
    sudo a2enmod proxy_html
    
    ## installing sql hangs when selecting a password,
    ## need to find another way to do this...
    # sudo apt-get install -y mysql-server mysql-client php5-mysql
    sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password secret'
    sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password secret'
    sudo apt-get -y install mysql-server-5.5 php5-mysql

    # download and install wordpress
    sudo apt-get -y install unzip
    sudo cd /tmp
    sudo wget -q https://wordpress.org/wordpress-4.4.2.zip
    sudo unzip -q wordpress-4.4.2.zip
    sudo mkdir -p /var/www/hoxtonowl.com/staging/httpdocs
    sudo rsync -rav wordpress/ /var/www/hoxtonowl.com/staging/httpdocs
    sudo ln -fs /opt/OwlProgram.online/Build/docs/html /var/www/hoxtonowl.com/staging/httpdocs/docs

    # set up mysql database
    sudo mysql -uroot -psecret < /vagrant/conf/create-databases.sql
    sudo zcat /vagrant/conf/owl_staging_wp.sql.gz|mysql -uowl -powl owl_staging_wp

    sudo groupadd -f hoxtonowl

    sudo apt-get -y install git

    # install the Composer php package manager
    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer

    # install nodejs and npm
    sudo apt-get install -y nodejs npm
    sudo ln -fs /usr/bin/nodejs /usr/bin/node

    sudo mkdir -p /srv/owl/deployment/
    sudo cp /vagrant/scripts/deploy-api.sh /srv/owl/deployment/
    sudo mkdir -p /var/www/hoxtonowl.com/staging/deployment/
    sudo cp /vagrant/scripts/deploy-website.sh /var/www/hoxtonowl.com/staging/deployment/

    sudo cp /vagrant/scripts/owl-api /etc/init.d/
    sudo cp /vagrant/scripts/api-settings.js /srv/owl/api
    sudo bash /var/www/hoxtonowl.com/staging/deployment/deploy-website.sh
    sudo bash /srv/owl/deployment/deploy-api.sh

    ## more provisioning...
    sudo mkdir -p /opt/OwlProgram.online
    cd /opt/OwlProgram.online
    sudo git init
    sudo git remote add clone https://github.com/pingdynasty/OwlProgram.git 
    sudo git pull origin master
    
  SHELL

end
