#!/usr/bin/env bash

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
. "${STACK_ROOT}/scripts/util.sh"

infomsg "# SoluTech APM(Apache,PHP,MariaDB) Configuration"
infomsg "----------------------------------------------------------------------"
infomsg "MariaDB have been installed in"
infomsg "  $HOME/IPX-Storage/DATABASE/mariadb"
infomsg "  - config : (global) $HOME/IPX-Storage/DATABASE/mariadb/etc/my.cnf"
infomsg "  - config : (custom) $HOME/IPX-Storage/DATABASE/mariadb/etc/my.cnf.d/my-custom.cnf"
echo
infomsg "Apache have been installed in"
infomsg "  $HOME/IPX-Web/WAS_v2.0/httpd"
infomsg "  - config : (global) $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf"
infomsg "  - config : (custom) $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra-ex/httpd-php.conf"
infomsg "  - config : (custom) $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra-ex/httpd-vhosts-macro.conf"
infomsg "  - config : (custom) $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra-ex/httpd-vhosts-wrapper.conf"
infomsg "  - config : (custom) $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra-ssl/openssl-custom.conf"
infomsg "  - config : (custom) $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra-ssl/server.crt"
infomsg "  - config : (custom) $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra-ssl/server.key"
echo
infomsg "PHP have been installed in"
infomsg "  $HOME/IPX-Web/WAS_v2.0/php"
infomsg "  - config : (global) $HOME/IPX-Web/WAS_v2.0/php/php.ini"
infomsg "  - config : (custom) $HOME/IPX-Web/WAS_v2.0/php/etc.d/php-custom.ini"
#echo
#infomsg "node have been installed in"
#infomsg "  $HOME/IPX-Web/WAS_v2.0/node"
echo
infomsg "----------------------------------------------------------------------"
infowarn "!!IMPORTANT: Additional settings for Firewall                        "
infowarn "  - must run as root (or sudo )                                      "
infowarn "  - Add more port settings if needed                                 "
echo
infomsg "Firewall for Apache/PHP                                               "
infomsg "  \$sudo firewall-cmd --add-port=80/tcp --permanent                   "
infomsg "  \$sudo firewall-cmd --add-port=443/tcp --permanent                  "
infomsg "  \$sudo firewall-cmd --reload                                        "
#echo
#infomsg "Firewall for node                                                     "
#infomsg "  \$sudo firewall-cmd --add-port=9000/tcp --permanent                 "
#infomsg "  \$sudo firewall-cmd --reload                                        "
echo
infomsg "Firewall for MaraiDB                                                  "
infomsg "  \$sudo firewall-cmd --add-port=3306/tcp --permanent                 "
infomsg "  \$sudo firewall-cmd --reload                                        "
echo
infomsg "----------------------------------------------------------------------"
infowarn "!!IMPORTANT: Additional settings to run service                      "
infowarn "  - must run as root (or sudo )                                      "
echo
infomsg "If you want to control the service in the soluipx account, please set the execute permission."
infomsg "  \$visudo -f /etc/sudoers"
infomsg ""  
infomsg "  root    ALL=(ALL)       ALL"
infomsg "  ## Allow soluipx of the users to ipx-web"
infomsg "  #soluipx ALL=NOPASSWD: /usr/bin/systemctl enable httpd"
infomsg "  #soluipx ALL=NOPASSWD: /usr/bin/systemctl enable httpd.service"
infomsg "  #soluipx ALL=NOPASSWD: /usr/bin/systemctl disable httpd"
infomsg "  #soluipx ALL=NOPASSWD: /usr/bin/systemctl disable httpd.service"
infomsg "  soluipx ALL=NOPASSWD: /usr/bin/systemctl start httpd"
infomsg "  soluipx ALL=NOPASSWD: /usr/bin/systemctl start httpd.service"
infomsg "  soluipx ALL=NOPASSWD: /usr/bin/systemctl stop httpd"
infomsg "  soluipx ALL=NOPASSWD: /usr/bin/systemctl stop httpd.service"
infomsg "  soluipx ALL=NOPASSWD: /usr/bin/systemctl kill -s 9 httpd"
infomsg "" 
infomsg "  #soluipx ALL=NOPASSWD: /usr/bin/systemctl enable mariadb"
infomsg "  #soluipx ALL=NOPASSWD: /usr/bin/systemctl enable mariadb.service"
infomsg "  #soluipx ALL=NOPASSWD: /usr/bin/systemctl disable mariadb"
infomsg "  #soluipx ALL=NOPASSWD: /usr/bin/systemctl disable mariadb.service"
infomsg "  soluipx ALL=NOPASSWD: /usr/bin/systemctl start mariadb"
infomsg "  soluipx ALL=NOPASSWD: /usr/bin/systemctl start mariadb.service"
infomsg "  soluipx ALL=NOPASSWD: /usr/bin/systemctl stop mariadb"
infomsg "  soluipx ALL=NOPASSWD: /usr/bin/systemctl stop mariadb.service"
infomsg "  soluipx ALL=NOPASSWD: /usr/bin/systemctl kill -s 9 mariadb"
echo
infomsg "Copy the apache configuration file (root)"
infomsg "  \$cp /home/soluipx/web-stack/systemd-files/apache/httpd.service /etc/systemd/system/httpd.service"
echo
infomsg "Apache autorun setting at boot (soluipx)"
infomsg "  \$systemctl enable|disable httpd.service"
echo
infomsg "Apache running (soluipx)"
infomsg "  \$systemctl status|start|stop httpd.service"
#echo
#infomsg "Service for node"
#infomsg "  \$sudo /home/soluipx/IPX-Web/WAS_v2.0/node/bin/pm2 startup "
#infomsg "  \$cd /home/soluipx/IPX-Web/nodejsRoot/[PACKAGE]"
#infomsg "  \$pm2 start app.js [--name appName]"
#infomsg "  \$pm2 save"
#infomsg "Run"
#infomsg "  \$pm2 start|stop|reload|delete [id|appName]"
echo
infomsg "Copy the MariaDB configuration file (root)"
infomsg "  \$cp /home/soluipx/web-stack/systemd-files/mariadb/mariadb.service /etc/systemd/system/mariadb.service"
echo
infomsg "MariaDB autorun setting at boot (soluipx)"
infomsg "  \$systemctl enable|disable mariadb.service"
echo
infomsg "MariaDB running (soluipx)"
infomsg "  \$systemctl status|start|stop mariadb.service"
echo
infomsg "----------------------------------------------------------------------"
infowarn "!!IMPORTANT: Additional settings to run service                      "
infowarn "  - must run as root (or sudo )                                      "
echo
infomsg "MariaDB init (soluipx)"
infomsg "  \$sudo /home/soluipx/IPX-Storage/DATABASE/mariadb/bin/mysql_secure_installation \ "
infomsg "  --defaults-file=/home/soluipx/IPX-Storage/DATABASE/mariadb/etc/my.cnf \ "
infomsg "  --basedir=/home/soluipx/IPX-Storage/DATABASE/mariadb"
echo
infomsg "MariaDB Connect (soluipx)"
infomsg "  \$sudo /home/soluipx/IPX-Storage/DATABASE/mariadb/bin/mysql \ "
infomsg "  --defaults-file=/home/soluipx/IPX-Storage/DATABASE/mariadb/etc/my.cnf "
echo
infomsg "MariaDB Add User (soluipx)"
infomsg "  MariaDB> GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' identified by 'PASSWORD';"
infomsg "  MariaDB> GRANT ALL PRIVILEGES ON *.* TO 'admin'@'127.0.0.1' identified by 'PASSWORD';"
infomsg "  MariaDB> GRANT ALL PRIVILEGES ON *.* TO 'admin'@'\x25' identified by 'PASSWORD';"
infomsg "  MariaDB> FLUSH PRIVILEGES;"
echo
