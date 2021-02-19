#!/bin/bash

# Source progress bar
source ./progress_bar.sh
# Make sure that the progress bar is cleaned up when user presses ctrl+c
enable_trapping
# Create progress bar
setup_scroll_area

echo "Обновление базы данных пакетов..."
sudo apt update
draw_progress_bar 5
echo "Установка инструментов для сборки NGINX..."
sudo apt install -y build-essential
draw_progress_bar 15
echo "Установка зависимостей для сборки NGINX..."
sudo apt install -y libpcre3-dev libssl-dev zlib1g-dev
draw_progress_bar 25

mkdir -p build; cd build

echo "Клонирование репозитория модуля RTMP для NGINX..."
git clone https://github.com/arut/nginx-rtmp-module.git
draw_progress_bar 30
echo "Клонирование репозитория с исходниками NGINX..."
git clone https://github.com/nginx/nginx.git
draw_progress_bar 40

cd nginx

echo "Компиляция NGINX..."
./auto/configure --add-module=../nginx-rtmp-module --with-http_ssl_module --with-file-aio
draw_progress_bar 55
echo "Сборка NGINX..."
make
draw_progress_bar 70
echo "Установка NGINX..."
sudo make install
draw_progress_bar 85

cd ../..
cp /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
rm /usr/local/nginx/conf/nginx.conf
cp nginx.conf /usr/local/nginx/conf/nginx.conf

block_progress_bar 90
read -p "Введите порт прослушиваемый RTMP-сервером (по умолчанию 1935): " RTMP_PORT
read -p "Введите порт прослушиваемый HTTP-сервером (по умолчанию 80): " HTTP_PORT

if [ -z "$RTMP_PORT" ]; then RTMP_PORT=1935; fi
if [ -z "$HTTP_PORT" ]; then HTTP_PORT=80; fi

sed -i -e 's/RTMP_PORT/'$RTMP_PORT'/; s/HTTP_PORT/'$HTTP_PORT'/' ./nginx.conf

draw_progress_bar 95

echo "Создание скрипта запуска NGINX и добавление в автозагрузку..."
cp nginx /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx
sudo update-rc.d nginx defaults

draw_progress_bar 100

destroy_scroll_area

#sudo reboot
