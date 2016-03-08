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

#  config.hostsupdater.aliases = ["staging.hoxtonowl.com", "ulrike.pingdynasty.com"]

  config.vm.provision "shell", inline: <<-SHELL

    # update hosts file (todo: use hostsupdater plugin)
    sudo cp /vagrant/scripts/hosts /etc/hosts

    # `apt-key update` will update apt's list of secure packages
    sudo apt-key update
    sudo apt-get update
    sudo groupadd -f hoxtonowl
    sudo apt-get -y install git unzip

    # install apache and mongodb
    sudo apt-get install -y apache2 php5 libapache2-mod-php5 libapache2-mod-proxy-html mongodb openssl
    sudo mkdir -p /var/www
    sudo rsync -rav /vagrant/html/ /var/www

    sudo cp /vagrant/apacheconf/* /etc/apache2/sites-available/
    sudo a2ensite staging.hoxtonowl.com
    sudo a2ensite staging.hoxtonowl.com-ssl
    sudo a2enmod proxy_html
    sudo a2enmod proxy_http
    sudo a2enmod rewrite
    sudo a2enmod ssl

    # installing mysql hangs when selecting a password unless we set it first
    sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password secret'
    sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password secret'
    sudo apt-get -y install mysql-server-5.5 php5-mysql

    # install OwlServer as a live repo with symlink
    sudo mkdir -p /opt/OwlServer
    sudo chown vagrant:vagrant /opt/OwlServer
    cd /opt/OwlServer
    git init
    git remote add origin https://github.com/pingdynasty/OwlServer.git 
    git pull origin dev
    # symlink wordpress directory
    sudo mkdir -p /var/www/hoxtonowl.com/staging
    sudo ln -s /opt/OwlServer/web/wordpress /var/www/hoxtonowl.com/staging/httpdocs
    # symlink api directory
    sudo mkdir -p /srv/owl
    sudo ln -s  /opt/OwlServer/web/api /srv/owl/
    # install nodejs and npm
    sudo apt-get install -y nodejs npm
    sudo ln -fs /usr/bin/nodejs /usr/bin/node
    if [ ! -d "/srv/owl/api/node_modules" ]; then
      echo "Installing node.js modules..."
      cd /srv/owl/api && npm install
    fi

    echo installling wordpress
    cd
    wget -c -q https://wordpress.org/wordpress-4.4.2.zip
    unzip -q wordpress-4.4.2.zip
    sudo rsync -rav wordpress/ /var/www/hoxtonowl.com/staging/httpdocs
    sudo ln -fs /opt/OwlProgram.online/Build/docs/html /var/www/hoxtonowl.com/staging/httpdocs/docs
    sudo cp /vagrant/data/wp-config.php /var/www/hoxtonowl.com/staging/httpdocs

    echo setting up databases
    # set up mysql databases
    mysql -uroot -psecret < /vagrant/conf/create-databases.sql
    zcat /vagrant/data/owl_staging_wp.sql.gz|mysql -uowl -powl owl_staging_wp
    zcat /vagrant/data/owl_staging_mediawiki.sql.gz|mysql -uowl_mediawiki -psecret owl_staging_mediawiki
    # set up mongo database
    cd /tmp
    unzip /vagrant/data/owl_staging.zip
    mongorestore --drop --collection patches --db owl_staging owl_staging/patches.bson
    rm -rf owl_staging

    # install the Composer php package manager
    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer

    echo copying deploy scripts
    sudo mkdir -p /srv/owl/deployment/
    sudo cp /vagrant/scripts/deploy-api.sh /srv/owl/deployment/
    sudo mkdir -p /var/www/hoxtonowl.com/staging/deployment/
    sudo cp /vagrant/scripts/deploy-website.sh /var/www/hoxtonowl.com/staging/deployment/
    sudo cp /vagrant/scripts/owl-api /etc/init.d/
    sudo cp /vagrant/scripts/owl-api.service /etc/systemd/system/
    # sudo bash /var/www/hoxtonowl.com/staging/deployment/deploy-website.sh
    # sudo bash /srv/owl/deployment/deploy-api.sh
    sudo cp /vagrant/scripts/api-settings.js /srv/owl/api

    # copy compiled patches
    sudo mkdir -p /var/www/hoxtonowl.com/staging/patch-builder/build
    sudo mkdir -p /var/www/hoxtonowl.com/staging/patch-builder/build-js
    sudo cp /vagrant/data/build/*.syx /var/www/hoxtonowl.com/staging/patch-builder/build
    sudo cp /vagrant/data/build-js/*.js /var/www/hoxtonowl.com/staging/patch-builder/build-js
    sudo chown -R www-data:www-data /var/www/hoxtonowl.com/staging/patch-builder/

    echo installing mediawiki
    sudo apt-get -y install php-apc php5-intl imagemagick
    cd
    wget -c -q 'https://releases.wikimedia.org/mediawiki/1.26/mediawiki-1.26.2.tar.gz'
    tar xf mediawiki-1.26.2.tar.gz
    mv mediawiki-1.26.2 /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/
    sudo cp /vagrant/data/LocalSettings.php /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/
    wget -c -q 'https://gitlab.com/CiaranG/wpmw/repository/archive.zip?ref=master'
    unzip 'archive.zip?ref=master'
    sudo cp wpmw-master*/AuthWP.php /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/extensions/
    sudo chown -R www-data:www-data /opt/OwlServer/web/wordpress/mediawiki/cache
    cd  /opt/OwlServer/web/wordpress/mediawiki/
    php5 ./maintenance/update.php
    # symlink mediawiki skin
    sudo ln -s /opt/OwlServer/web/mediawiki/skins/HoxtonOWL2014 /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/skins/HoxtonOWL2014

    sudo apache2ctl restart

  SHELL

end
