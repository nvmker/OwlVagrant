# OwlVagrant - developing the OwlServer project on a Vagrant VM

Usage:

* Install [VirtualBox](https://www.virtualbox.org/)
* Install [Vagrant](https://www.vagrantup.com/)
* Install the 'vagrant-vbguest' plugin: `vagrant plugin install vagrant-vbguest`
* Clone this repo e.g. git clone git clone https://github.com/pingdynasty/OwlServer.git OwlVagrant/
* Clone [OwlServer](https://github.com/pingdynasty/OwlServer) into an adjacent directory called 'OwlServer' e.g. `git clone https://github.com/pingdynasty/OwlServer.git OwlServer/`
* Add the required files to the 'OwlVagrant/data' directory (see data/README.md for details)
* Run `vagrant up`
* Edit your hosts file to point staging.hoxtonowl.com at 192.168.50.4, e.g. on OSX: `sudo nano /etc/hosts` and add a new line with `192.168.50.4 staging.hoxtonowl.com`
* Browse to https://staging.hoxtonowl.com (allow the insecure certificate)