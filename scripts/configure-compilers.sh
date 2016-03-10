#!/bin/bash
mkdir -p /opt/OwlProgram.online
# chown vagrant:vagrant /opt/OwlProgram.online
cd /opt/OwlProgram.online
git init
git remote add origin https://github.com/pingdynasty/OwlProgram.git 
git pull origin master
# install arm gcc
if [ ! -d "/opt/OwlProgram.online/Tools/gcc-arm-none-eabi-5_2-2015q4" ]; then
    echo installing arm gcc compiler
    cd /opt/OwlProgram.online/Tools
    wget -c 'https://launchpad.net/gcc-arm-embedded/5.0/5-2015-q4-major/+download/gcc-arm-none-eabi-5_2-2015q4-20151219-linux.tar.bz2'
    tar xf gcc-arm-none-eabi-5_2-2015q4-20151219-linux.tar.bz2
    # sudo dpkg --add-architecture i386
    # sudo apt-get update
    sudo apt-get -y install lib32z1 lib32ncurses5
fi
if [ ! -d ~emsdk_portable ]; then
    echo installing emscripten
    cd
    sudo apt-get install -y build-essential cmake python2.7 default-jre
    wget -c 'https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz'
    tar xf emsdk-portable.tar.gz
    cd emsdk_portable
    ./emsdk update
    ./emsdk install latest
fi
