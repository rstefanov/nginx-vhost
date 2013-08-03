#!/bin/bash
# @author: Radoslav Stefanov
# http://www.rstefanov.org 
# http://www.directhost.bg
# Created:   07/25/2013
# Modified:  07/27/2013
# Modified:  08/03/2013
# You are free to edit this file to suit your needs. :)

yes | cp fastcgi.conf /etc/nginx/fastcgi.conf

if [ ! -d /etc/sites-available ]; then
    mkdir -p /etc/sites-available;
fi;

if [ ! -d /etc/sites-enabled ]; then
    mkdir -p /etc/sites-enabled;
fi;

NGINX_CONFIG='/etc/sites-available'
NGINX_SITES_ENABLED='/etc/sites-enabled'
WEB_SERVER_GROUP='nginx'
PHP_INI_DIR='/etc/php-fpm.d'
NGINX_INIT='/etc/init.d/nginx'
PHP_FPM_INIT='/etc/init.d/php-fpm'
 
SED=`which sed`
CURRENT_DIR=`dirname $0`

if [ -z $1 ]; then
    echo "No domain name given"
    exit 1
fi
DOMAIN=$1

PATTERN="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
    DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
    echo "Creating hosting for:" $DOMAIN
else
    echo "invalid domain name"
    exit 1 
fi

echo "Please specify the username for this site?"
read USERNAME
HOME_DIR=$USERNAME
useradd -m $USERNAME

CONFIG=$NGINX_CONFIG/$DOMAIN.conf
cp $CURRENT_DIR/nginx.vhost.conf.template $CONFIG
$SED -i "s/@@HOSTNAME@@/$DOMAIN/g" $CONFIG
$SED -i "s#@@PATH@@#\/home\/"$USERNAME$PUBLIC_HTML_DIR"#g" $CONFIG
$SED -i "s/@@LOG_PATH@@/\/home\/$USERNAME\/_logs/g" $CONFIG
$SED -i "s#@@SOCKET@@#/var/run/"$USERNAME"_fpm.sock#g" $CONFIG

FPMCONF="$PHP_INI_DIR/$DOMAIN.pool.conf"

cp $CURRENT_DIR/pool.conf.template $FPMCONF

$SED -i "s/@@USER@@/$USERNAME/g" $FPMCONF
$SED -i "s/@@HOME_DIR@@/\/home\/$USERNAME/g" $FPMCONF

usermod -aG $USERNAME $WEB_SERVER_GROUP

chmod g+rx /home/$HOME_DIR
chmod 600 $CONFIG

ln -s $CONFIG $NGINX_SITES_ENABLED/$DOMAIN.conf

mkdir -p /home/$HOME_DIR$PUBLIC_HTML_DIR/htdocs
yes | cp test.php /home/$HOME_DIR/htdocs/
yes | cp test.html /home/$HOME_DIR/htdocs/
mkdir /home/$HOME_DIR/_logs
chmod 750 /home/$HOME_DIR -R
chmod 770 /home/$HOME_DIR/_logs
chmod 750 /home/$HOME_DIR$PUBLIC_HTML_DIR
chown $USERNAME:$USERNAME /home/$HOME_DIR/ -R

$NGINX_INIT reload
$PHP_FPM_INIT reload
