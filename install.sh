#!/bin/bash

# Install App dependencies
yum update -y
amazon-linux-extras install mariadb10.5 -y
amazon-linux-extras install php8.2 -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
yum list installed httpd mariadb-server php-mysqlnd
rm /var/www/html/phpinfo.php

# mysql_secure_installation
systemctl start mariadb
systemctl enable mariadb
systemctl start mariadb

wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# configure the database
mysql -u root<<E0F
CREATE USER 'wordpress-user'@'localhost' IDENTIFIED BY 'najib';
CREATE DATABASE `wordpress-db`;
GRANT ALL PRIVILEGES ON `wordpress-db`.* TO 'wordpress-user'@'localhost';
FLUSH PRIVILEGES;
exit
E0F


# Replace the db values
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i "s/'database_name_here'/'wordpress-db'/g" wordpress/wp-config.php
sed -i "s/'username_here'/'wordpress-user'/g" wordpress/wp-config.php
sed -i "s/'password_here'/'najib'/g" wordpress/wp-config.php

# sed -i "s/'put your unique phrase here'/\' #U\$$+[RXN8:b^-L 0(WU_+ c+WFkI~c]o]-bHw+)/Aj[wTwSiZ<Qb[mghEXcRh-'/1" wordpress/wp-config.php
# sed -i "s/'put your unique phrase here'/\'Zsz._P=l/|y.Lq)XjlkwS1y5NJ76E6EJ.AV0pCKZZB,*~*r ?6OP\$eJT@;+(ndLg'/1" wordpress/wp-config.php
# sed -i "s/'put your unique phrase here'/\'ju}qwre3V*+8f_zOWf?{LlGsQ]Ye@2Jh^,8x>)Y |;(^[Iw]Pi+LG#A4R?7N\`YB3'/1" wordpress/wp-config.php
# sed -i "s/'put your unique phrase here'/\'P(g62HeZxEes|LnI^i=H,[XwK9I&[2s|:?0N}VJM%?;v2v]v+;+^9eXUahg@::Cj'/1" wordpress/wp-config.php
# sed -i "s/'put your unique phrase here'/\'C\$DpB4Hj[JK:?{ql`sRVa:{:7yShy(9A@5wg+`JJVb1fk%_-Bx*M4(qc[Qg%JT!h'/1" wordpress/wp-config.php
# sed -i "s/'put your unique phrase here'/\'d!uRu#}+q#{f\$Z?Z9uFPG.${+S{n~1M&%@~gL>U>NV<zpD-@2-Es7Q1O-bp28EKv'/1" wordpress/wp-config.php
# sed -i "s/'put your unique phrase here'/\'\;j{00P*owZf)kVD+FVLn-~ >.|Y%Ug4#I^*LVd9QeZ^&XmK|e(76miC+&W&+^0P\//1" wordpress/wp-config.php
# sed -i "s/'put your unique phrase here'/\'-97r*V\/cgxLmp?Zy4zUU4r99QQ_rGs2LTd%P;|_e1tS)8_B\/,.6[=UK<J_y9?JWG'/1" wordpress/wp-config.php


cp -r wordpress/* /var/www/html/
mkdir /var/www/html/blog
cp -r wordpress/* /var/www/html/blog/

sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# Apache File permissions
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0644 {} \;
sudo systemctl restart httpd
sudo systemctl enable httpd && sudo systemctl enable mariadb

if sudo systemctl status mariadb | grep -q 'running'; then
    echo "database is running"
else
    sudo systemctl start mariadb
fi

if sudo systemctl status httpd | grep -q 'running'; then
    echo "apache is running"
else
    sudo systemctl start httpd
fi
