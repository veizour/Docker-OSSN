#!/bin/bash

# Check if config exists. If not, copy in the sample config
if [ -f /config/proxy-config.conf ]; then
  echo "Using existing config file."
else
  echo "Creating config from template."
  mv /etc/apache2/000-default.conf /config/proxy-config.conf
  cp /root/.htpasswd /config/.htpasswd
fi

# Add Persistent Cron Configuration Capability
if [ -f /config/crons.conf ]; then
  echo "Using existing Cron config file."
#  crontab /config/crons.conf
#  cron
else
  echo "Copying blank  Cron config file."
  cp /root/crons.conf /config/crons.conf
#  crontab /config/crons.conf
#  cron
fi

if [ -f /var/www/html/ossn ]; then
  echo "Using existing OSSN install"
else
  wget https://www.opensource-socialnetwork.org/download_ossn/latest/build.zip --directory-prefix=/tmp
  unzip /tmp/build.zip -d /tmp
  cp -R /tmp/ossn/. /var/www/html/ossn/.
  unzip /tmp/build.zip -d /tmp
  cp -R /tmp/ossn/. /var/www/html/ossn/.

  # Generate ossn conf files
  echo "<VirtualHost *:80>" > /etc/apache2/sites-enabled/000-default.conf
  echo "ServerAdmin "$adminlogin  >> /etc/apache2/sites-enabled/000-default.conf
  echo "DocumentRoot /var/www/html/"  >> /etc/apache2/sites-enabled/000-default.conf
  echo "ServerName "$servername  >> /etc/apache2/sites-enabled/000-default.conf
  echo "" >> /etc/apache2/sites-enabled/000-default.conf
  echo "<Directory /var/www/html/>"  >> /etc/apache2/sites-enabled/000-default.conf
  echo "     Options FollowSymlinks" >> /etc/apache2/sites-enabled/000-default.conf
  echo "     AllowOverride All" >> /etc/apache2/sites-enabled/000-default.conf
  echo "     Require all granted" >> /etc/apache2/sites-enabled/000-default.conf
  echo "</Directory>" >> /etc/apache2/sites-enabled/000-default.conf
  echo "" >> /etc/apache2/sites-enabled/000-default.conf
  echo "ErrorLog ${APACHE_LOG_DIR}/ossn_error.log" >> /etc/apache2/sites-enabled/000-default.conf
  echo "CustomLog ${APACHE_LOG_DIR}/ossn_access.log combined" >> /etc/apache2/sites-enabled/000-default.conf
  echo "" >> /etc/apache2/sites-enabled/000-default.conf
  echo "</VirtualHost>" >> /etc/apache2/sites-enabled/000-default.conf

  echo "<?php" > /var/www/html/ossn/configurations/ossn.config.site
  echo "/**" >> /var/www/html/ossn/configurations/ossn.config.site
  echo " * Open Source Social Network" >> /var/www/html/ossn/configurations/ossn.config.site
  echo " *" >> /var/www/html/ossn/configurations/ossn.config.site
  echo " * @package   (softlab24.com).ossn" >> /var/www/html/ossn/configurations/ossn.config.site
  echo " * @author    OSSN Core Team <info@softlab24.com>" >> /var/www/html/ossn/configurations/ossn.config.site
  echo " * @copyright (C) SOFTLAB24 LIMITED" >> /var/www/html/ossn/configurations/ossn.config.site
  echo " * @license   Open Source Social Network License (OSSN LICENSE)  http://www.opensource-socialnetwork.org/licence" >> /var/www/html/ossn/configurations/ossn.config.site
  echo " * @link      https://www.opensource-socialnetwork.org/" >> /var/www/html/ossn/configurations/ossn.config.site
  echo " */" >> /var/www/html/ossn/configurations/ossn.config.site
  echo "" >> /var/www/html/ossn/configurations/ossn.config.site
  echo "$Ossn->url = '"$servername"';" >> /var/www/html/ossn/configurations/ossn.config.site
  echo "$Ossn->userdata = '"$DataDirectory"';" >> /var/www/html/ossn/configurations/ossn.config.site

  echo "<?php" > /var/www/html/ossn/configurations/ossn.config.db
  echo "/**" >> /var/www/html/ossn/configurations/ossn.config.db
  echo " * Open Source Social Network" >> /var/www/html/ossn/configurations/ossn.config.db
  echo " *" >> /var/www/html/ossn/configurations/ossn.config.db
  echo " * @package   (softlab24.com).ossn" >> /var/www/html/ossn/configurations/ossn.config.db
  echo " * @author    OSSN Core Team <info@softlab24.com>" >> /var/www/html/ossn/configurations/ossn.config.db
  echo " * @copyright (C) SOFTLAB24 LIMITED" >> /var/www/html/ossn/configurations/ossn.config.db
  echo " * @license   Open Source Social Network License (OSSN LICENSE)  http://www.opensource-socialnetwork.org/licence" >> /var/www/html/ossn/configurations/ossn.config.db
  echo " * @link      https://www.opensource-socialnetwork.org/" >> /var/www/html/ossn/configurations/ossn.config.db
  echo " */" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "// replace <<host>> with your database host name;" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "$Ossn->host = '"$DBHost"';" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "// replace <<port>> with your database host name;" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "$Ossn->port = '"$DBPort"';" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "// replace <<user>> with your database username;" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "$Ossn->user = '"$DBUser"';" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "// replace <<password>> with your database password;" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "$Ossn->password = '"$DBPassword"';" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "// replace <<dbname>> with your database name;" >> /var/www/html/ossn/configurations/ossn.config.db
  echo "$Ossn->database = '"$DBName"';" >> /var/www/html/ossn/configurations/ossn.config.db
fi
