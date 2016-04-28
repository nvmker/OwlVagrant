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

  config.vm.synced_folder "../OwlServer", "/opt/OwlServer",
    owner: "vagrant",
    group: "www-data",
    mount_options: ["dmode=775,fmode=664"]

#  config.hostsupdater.aliases = ["staging.hoxtonowl.com", "ulrike.pingdynasty.com"]

  config.vm.provision "shell", inline: <<-SHELL

    # update hosts file (todo: use hostsupdater plugin)
    cp /vagrant/scripts/hosts /etc/hosts

    echo installing services
    cp -f /vagrant/scripts/owl-api /etc/init.d/
    cp -f /vagrant/scripts/owl-api.service /etc/systemd/system/
    touch /var/log/owl-api.log
    chmod o+w /var/log/owl-api.log
    touch /var/log/owl-api.err
    chmod o+w /var/log/owl-api.err
    systemctl daemon-reload
    update-rc.d mongodb enable
    update-rc.d owl-api enable

    # `apt-key update` will update apt's list of secure packages
    export DEBIAN_FRONTEND=noninteractive
    apt-key update
    apt-get update
    groupadd -f hoxtonowl
    apt-get -y install git unzip

    # install apache and mongodb
    apt-get install -y apache2 php5 libapache2-mod-php5 libapache2-mod-proxy-html mongodb openssl
    mkdir -p /var/www
    rsync -rav /vagrant/html/ /var/www

    cp /vagrant/apacheconf/* /etc/apache2/sites-available/
    a2ensite staging.hoxtonowl.com
    a2ensite staging.hoxtonowl.com-ssl
    a2enmod proxy_html
    a2enmod proxy_http
    a2enmod rewrite
    a2enmod ssl

    # installing mysql hangs when selecting a password unless we set it first
    debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password secret'
    debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password secret'
    apt-get -y install mysql-server-5.5 php5-mysql

    # install OwlServer as a live repo with symlinks
    if [ ! -d "/opt/OwlServer" ]; then
      mkdir -p /opt/OwlServer
      # chown vagrant:vagrant /opt/OwlServer
      cd /opt/OwlServer
      git init
      git remote add origin https://github.com/pingdynasty/OwlServer.git
      git pull origin dev
    fi
    # symlink wordpress directory
    mkdir -p /var/www/hoxtonowl.com/staging
    ln -fns /opt/OwlServer/web/wordpress /var/www/hoxtonowl.com/staging/httpdocs
    # symlink api directory
    mkdir -p /srv/owl
    ln -fns  /opt/OwlServer/web/api /srv/owl/
    cp -f /vagrant/scripts/api-settings.js /srv/owl/api/
    # install nodejs and npm
    apt-get install -y nodejs npm
    ln -fns /usr/bin/nodejs /usr/bin/node
    if [ ! -d "/srv/owl/api/node_modules" ]; then
      echo "Installing node.js modules..."
      cd /srv/owl/api && npm install
    fi
    mkdir -p /var/www/hoxtonowl.com/staging/logs/
    chown -R www-data:www-data /var/www/hoxtonowl.com/staging/logs/
    chmod -f 664 /var/www/hoxtonowl.com/staging/logs/*
    mkdir -p /var/www/hoxtonowl.com/staging/httpdocs/wp-content/uploads
    chown -R www-data /var/www/hoxtonowl.com/staging/httpdocs/wp-content/uploads
    mkdir -p /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/images
    chown -R www-data /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/images
    # symlink scripts
    ln -fns /opt/OwlServer/web/scripts/patch-builder /var/www/hoxtonowl.com/staging/patch-builder
    ln -fns /opt/OwlServer/web/scripts/deployment /var/www/hoxtonowl.com/staging/deployment
    ln -fns /opt/OwlServer/web/scripts/backup /var/www/hoxtonowl.com/staging/backup

    echo installling wordpress
    cd
    wget -c https://wordpress.org/wordpress-4.4.2.zip
    unzip -qo wordpress-4.4.2.zip
    rsync -rav wordpress/ /var/www/hoxtonowl.com/staging/httpdocs
    ln -fns /opt/OwlProgram.online/Build/docs/html /var/www/hoxtonowl.com/staging/httpdocs/docs
    cp /vagrant/data/wp-config.php /var/www/hoxtonowl.com/staging/httpdocs

    echo installing wordpress plugins
    cd /var/www/hoxtonowl.com/staging/httpdocs/wp-content/plugins/
    wget https://downloads.wordpress.org/plugin/theme-my-login.6.4.4.zip
    unzip theme-my-login.6.4.4.zip && rm theme-my-login.6.4.4.zip
    wget https://downloads.wordpress.org/plugin/bbpress.2.5.8.zip
    unzip bbpress.2.5.8.zip && rm bbpress.2.5.8.zip
    wget https://downloads.wordpress.org/plugin/wordfence.6.0.24.zip
    unzip wordfence.6.0.24.zip && rm wordfence.6.0.24.zip
    wget https://downloads.wordpress.org/plugin/shadowbox-js.3.0.3.10.2.zip
    unzip shadowbox-js.3.0.3.10.2.zip && rm shadowbox-js.3.0.3.10.2.zip
    wget https://downloads.wordpress.org/plugin/jetpack.3.9.4.zip
    unzip jetpack.3.9.4.zip && rm jetpack.3.9.4.zip
    wget https://downloads.wordpress.org/plugin/anti-captcha.20141103.zip
    unzip anti-captcha.20141103.zip && rm anti-captcha.20141103.zip
    wget https://downloads.wordpress.org/plugin/bad-behavior.2.2.18.zip
    unzip bad-behavior.2.2.18.zip && rm bad-behavior.2.2.18.zip
    wget https://downloads.wordpress.org/plugin/cookie-law-info.1.5.3.zip
    unzip cookie-law-info.1.5.3.zip && rm cookie-law-info.1.5.3.zip

    echo setting up databases
    # set up mysql databases
    mysql -uroot -psecret < /vagrant/conf/create-databases.sql
    zcat /vagrant/data/owl_staging_wp.sql.gz|mysql -uowl -powl owl_staging_wp
    zcat /vagrant/data/owl_staging_mediawiki.sql.gz|mysql -uowl_mediawiki -psecret owl_staging_mediawiki
    # set up mongo database
    cd /tmp
    unzip -qo /vagrant/data/owl_staging.zip
    mongorestore --drop --collection patches --db owl_staging owl_staging/patches.bson
    rm -rf owl_staging

    # install the Composer php package manager
    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    mv composer.phar /usr/local/bin/composer

    # copy compiled patches
    mkdir -p /var/www/hoxtonowl.com/staging/patch-builder/build
    mkdir -p /var/www/hoxtonowl.com/staging/patch-builder/build-js
    cp /vagrant/data/build/*.syx /var/www/hoxtonowl.com/staging/patch-builder/build
    cp /vagrant/data/build-js/*.js /var/www/hoxtonowl.com/staging/patch-builder/build-js
    chown -R www-data:www-data /var/www/hoxtonowl.com/staging/patch-builder/

    echo installing mediawiki
    apt-get -y install php-apc php5-intl imagemagick
    cd
    wget -c 'https://releases.wikimedia.org/mediawiki/1.26/mediawiki-1.26.2.tar.gz'
    tar xf mediawiki-1.26.2.tar.gz
    mkdir -p  /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/
    rsync -ra mediawiki-1.26.2/ /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/
    cp /vagrant/data/LocalSettings.php /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/
    wget -c 'https://gitlab.com/CiaranG/wpmw/repository/archive.zip?ref=master'
    unzip -qo 'archive.zip?ref=master'
    mkdir -p /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/extensions/
    cp wpmw-master*/AuthWP.php /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/extensions/
    chown -R www-data:www-data /opt/OwlServer/web/wordpress/mediawiki/cache
    # symlink mediawiki skin
    mkdir -p /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/skins
    ln -fns /opt/OwlServer/web/mediawiki/skins/HoxtonOWL2014 /var/www/hoxtonowl.com/staging/httpdocs/mediawiki/skins/HoxtonOWL2014
    cd  /opt/OwlServer/web/wordpress/mediawiki/
    php5 ./maintenance/update.php --quick

    # echo configuring online compiler
    # bash /vagrant/scripts/configure-compilers.sh

    echo restarting services
    service owl-api stop
    service owl-api start
    apache2ctl restart

  SHELL

end
