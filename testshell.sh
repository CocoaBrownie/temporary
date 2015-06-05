#!/bin/bash


## WORDPRESS設定ファイルのパス
WP_CONF_PATH='/var/www/html/wp-config.php'

## LOGファイルのパス
LOG_NAME='wp-ip-reset.log'
LOG_PATH="$(pwd)/${LOG_NAME}"

# 自分に割り当てられたPublicIPを取得
PUBLIC_IP="'`curl -s http://169.254.169.254/latest/meta-data/public-ipv4/`'"

## DB情報取得
DB_NAME=`grep "^define('DB_NAME" ${WP_CONF_PATH} | sed -e "s/define('DB_NAME', '\(.*\)');/\1/" | tr -d "\r"`
DB_USER=`grep "^define('DB_USER" ${WP_CONF_PATH} | sed -e "s/define('DB_USER', '\(.*\)');/\1/" | tr -d "\r"`
DB_PASSWORD=`grep "^define('DB_PASSWORD" ${WP_CONF_PATH} | sed -e "s/define('DB_PASSWORD', '\(.*\)');/\1/" | tr -d "\r"`
DB_HOST=`grep "^define('DB_HOST" ${WP_CONF_PATH} | sed -e "s/define('DB_HOST', '\(.*\)');/\1/" | tr -d "\r"`

## LOGING
echo '####################' >> ${LOG_PATH}
echo 実行日時：`date` >> ${LOG_PATH}
echo LOG_PATH      ${LOG_PATH} >> ${LOG_PATH}
echo PUBLIC_IP     ${PUBLIC_IP} >> ${LOG_PATH}
echo DB_NAME       ${DB_NAME} >> ${LOG_PATH}
echo DB_USER       ${DB_USER} >> ${LOG_PATH}
echo DB_PASSWORD   ${DB_PASSWORD} >> ${LOG_PATH}
echo DB_HOST       ${DB_HOST} >> ${LOG_PATH}

## DB接続
mysql -h ${DB_HOST} -D ${DB_NAME} -u ${DB_USER} -p${DB_PASSWORD} -e"select * from wp_options where option_name = 'siteurl';" >> ${LOG_PATH}
mysql -h ${DB_HOST} -D ${DB_NAME} -u ${DB_USER} -p${DB_PASSWORD} -e"select * from wp_options where option_name = 'home';" >> ${LOG_PATH}

mysql -h ${DB_HOST} -D ${DB_NAME} -u ${DB_USER} -p${DB_PASSWORD} -e"update wp_options set option_value = ${PUBLIC_IP} where option_name = 'siteurl';" >> ${LOG_PATH}
mysql -h ${DB_HOST} -D ${DB_NAME} -u ${DB_USER} -p${DB_PASSWORD} -e"update wp_options set option_value = ${PUBLIC_IP} where option_name = 'home';" >> ${LOG_PATH}

mysql -h ${DB_HOST} -D ${DB_NAME} -u ${DB_USER} -p${DB_PASSWORD} -e"select * from wp_options where option_name = 'siteurl';" >> ${LOG_PATH}
mysql -h ${DB_HOST} -D ${DB_NAME} -u ${DB_USER} -p${DB_PASSWORD} -e"select * from wp_options where option_name = 'home';" >> ${LOG_PATH}


## 終了
exit
