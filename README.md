# OwlVagrant - developing the OwlServer project on a Vagrant VM

Usage:

* Install [VirtualBox](https://www.virtualbox.org/).
* Install [Vagrant](https://www.vagrantup.com/).
* Install the `vagrant-vbguest` plugin (on Debian based systems, you will need to install the package `ruby-dev` for this to work):
```
vagrant plugin install vagrant-vbguest
```
* Clone this repository:
```
git clone https://github.com/pingdynasty/OwlServer.git OwlVagrant/
```
* Clone [OwlServer](https://github.com/pingdynasty/OwlServer) into an adjacent directory called 'OwlServer':
```
git clone https://github.com/pingdynasty/OwlServer.git OwlServer/
```
* Add the required files to the `OwlVagrant/data` directory (see [`data/README.md`](data/README.md) for details)
* Start Vagrant:
```
vagrant up
```
* Edit your hosts file to point `staging.hoxtonowl.com` at `192.168.50.4`, e.g. on OSX: `sudo nano /etc/hosts` and add a new line with `192.168.50.4 staging.hoxtonowl.com`
* Browse to https://staging.hoxtonowl.com (allow the insecure certificate)
