#!/bin/bash

# Check if config exists. If not, copy in the sample config
if [ -f /config/proxy-config.conf ]; then
  echo "Using saved config file."
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

# Check for OSSN folder
if [ -f /var/www/html/ossn ]; then
  echo "Using OSSN folder found."
else
  echo "Populating OSSN folder."
  wget https://www.opensource-socialnetwork.org/download_ossn/latest/build.zip -P /tmp/
  unzip /tmp/build.zip -d /tmp
  rm /tmp/build.zip
  if [ -d /var/www/html ]; 
    then mkdir -p /var/www/html
  fi
  mv /tmp/ossn /var/www/html/.
fi

# Check for OSSN DB config and add
if [ -f /var/www/html/ossn/configurations/ossn.config.db.php ]; then
  echo "Using saved OSSN DB config file."
else
  echo "Creating OSSN DB config from template."
  echo "<?php" > /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "/**" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo " * Open Source Social Network" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo " *" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo " * @package   (softlab24.com).ossn" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo " * @author    OSSN Core Team <info@softlab24.com>" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo " * @copyright (C) SOFTLAB24 LIMITED" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo " * @license   Open Source Social Network License (OSSN LICENSE)  http://www.opensource-socialnetwork.org/licence" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo " * @link      https://www.opensource-socialnetwork.org/" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo " */" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "// replace <<host>> with your database host name;" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "/$Ossn->host = '$DBHost';" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "// replace <<port>> with your database host name;" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "/$Ossn->port = '$DBPort';" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "// replace <<user>> with your database username;" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "/$Ossn->user = '$DBUser';" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "// replace <<password>> with your database password;" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "/$Ossn->password = '$DBPassword';" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "// replace <<dbname>> with your database name;" >> /var/www/html/ossn/configurations/ossn.config.db.php && \
  echo "/$Ossn->database = '$DBName';" >> /var/www/html/ossn/configurations/ossn.config.db.php
fi

# Check for OSSN Site config and add
if [ -f /var/www/html/ossn/configurations/ossn.config.site ]; then
  echo "Using saved OSSN Site config file."
else
  echo "Creating OSSN Site config from template."
  echo "<?php" > /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo "/**" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo " * Open Source Social Network" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo " *" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo " * @package   (softlab24.com).ossn" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo " * @author    OSSN Core Team <info@softlab24.com>" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo " * @copyright (C) SOFTLAB24 LIMITED" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo " * @license   Open Source Social Network License (OSSN LICENSE)  http://www.opensource-socialnetwork.org/licence" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo " * @link      https://www.opensource-socialnetwork.org/" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo " */" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo "" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo "/$Ossn->url = '$servername';" >> /var/www/html/ossn/configurations/ossn.config.site.php && \
  echo "/$Ossn->userdata = '$DataDirectory';" >> /var/www/html/ossn/configurations/ossn.config.site.php
fi
