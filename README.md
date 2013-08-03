Nginx automated virtual host
===========

This is a simple bash script for automated Nginx virtual host creation. It can help you with administration
of multiple websites on the same server. Dont forget to make it executable with chmod +x nginx.sh

## How to use this script?

* Add a new domain name: ./nginx.sh example.com

* Remove domain name: ./remove.sh example.com

Everything is automated except a small change you need to do manually at nginx.conf.
* Replace: include /etc/nginx/conf.d/*.conf;
* With: include /etc/sites-enabled/*.conf;

Thats all!
