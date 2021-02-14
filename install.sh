#!/bin/bash

sudo apt update
sudo apt install -y build-essential
sudo apt install -y libpcre3-dev libssl-dev zlib1g-dev

mkdir -p build
cd build
git clone https://github.com/arut/nginx-rtmp-module.git
git clone https://github.com/nginx/nginx.git
cd nginx
./auto/configure --add-module=../nginx-rtmp-module --with-http_ssl_module --with-file-aio
make
sudo make install

cd ../..
cp /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
rm /usr/local/nginx/conf/nginx.conf
cp nginx.conf /usr/local/nginx/conf/nginx.conf
cp nginx /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx
sudo update-rc.d nginx defaults
sudo reboot