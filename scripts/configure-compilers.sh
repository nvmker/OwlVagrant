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
  cd /opt
  sudo apt-get install -y build-essential cmake python2.7 default-jre
  wget -c 'https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz'
  tar xf emsdk-portable.tar.gz
  cd emsdk_portable
  ./emsdk update
  ./emsdk install emscripten-1.34.1
  cd
  wget https://github.com/pingdynasty/FirmwareSender/releases/download/v0.1/FirmwareSender-linux64.zip
  mv FirmwareSender-linux64.zip /opt/OwlProgram.online/Tools
  cd /opt/OwlProgram.online/Tools
  unzip FirmwareSender-linux64.zip
  rm -f /usr/local/bin/emcc
  cd /usr/local/bin
  ln -s /opt/emsdk_portable/emscripten/1.34.1/emcc emcc
  emcc --version
  mv /root/.emscripten /opt
fi
