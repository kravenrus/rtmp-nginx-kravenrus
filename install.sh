#!/bin/bash
clear
# Source progress bar
source ./progress_bar.sh
# Make sure that the progress bar is cleaned up when user presses ctrl+c
enable_trapping
# Create progress bar
setup_scroll_area

echo -en "Обновление базы данных пакетов..."
sudo apt update > /dev/null 2>&1
echo "Успешно!"; draw_progress_bar 5
echo -en "Установка инструментов для сборки NGINX..."
sudo apt install -y build-essential > /dev/null 2>&1
echo "Успешно!"; draw_progress_bar 15
echo -en "Установка зависимостей для сборки NGINX..."
sudo apt install -y libpcre3-dev libssl-dev zlib1g-dev > /dev/null 2>&1
echo "Успешно!"; draw_progress_bar 25

mkdir -p build; cd build > /dev/null 2>&1

echo -en "Клонирование репозитория модуля RTMP для NGINX..."
git clone https://github.com/arut/nginx-rtmp-module.git > /dev/null 2>&1
echo "Успешно!"; draw_progress_bar 30
echo -en "Клонирование репозитория с исходниками NGINX..."
git clone https://github.com/nginx/nginx.git > /dev/null 2>&1
echo "Успешно!"; draw_progress_bar 40

cd nginx > /dev/null 2>&1

echo -en "Компиляция NGINX..."
./auto/configure --add-module=../nginx-rtmp-module --with-http_ssl_module --with-file-aio > /dev/null 2>&1
echo "Успешно!"; draw_progress_bar 55
echo -en "Сборка NGINX..."
make > /dev/null 2>&1
echo "Успешно!"; draw_progress_bar 70
echo -en "Установка NGINX..."
sudo make install > /dev/null 2>&1
echo "Успешно!"; draw_progress_bar 85

cd ../.. > /dev/null 2>&1
cp /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak > /dev/null 2>&1
rm /usr/local/nginx/conf/nginx.conf > /dev/null 2>&1
cp nginx.conf /usr/local/nginx/conf/nginx.conf > /dev/null 2>&1

block_progress_bar 90
read -p "Введите порт прослушиваемый RTMP-сервером (по умолчанию 1935): " RTMP_PORT
read -p "Введите порт прослушиваемый HTTP-сервером (по умолчанию 80): " HTTP_PORT

if [ -z "$RTMP_PORT" ]; then RTMP_PORT=1935; fi > /dev/null 2>&1
if [ -z "$HTTP_PORT" ]; then HTTP_PORT=80; fi > /dev/null 2>&1

sed -i -e 's/RTMP_PORT/'$RTMP_PORT'/; s/HTTP_PORT/'$HTTP_PORT'/' /usr/local/nginx/conf/nginx.conf > /dev/null 2>&1

echo "Успешно!"; draw_progress_bar 95

echo -en "Создание скрипта запуска NGINX и добавление в автозагрузку..."
cp nginx /etc/init.d/nginx > /dev/null 2>&1
sudo chmod +x /etc/init.d/nginx > /dev/null 2>&1
sudo update-rc.d nginx defaults > /dev/null 2>&1

echo "Успешно!"; draw_progress_bar 100

destroy_scroll_area

#sudo reboot
