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
if [ -f /var/www/html ]; then
  echo "Using OSSN folder found."
else
  echo "Populating OSSN folder."
  wget https://www.opensource-socialnetwork.org/download_ossn/latest/build.zip -P /tmp/
  unzip /tmp/build.zip -d /tmp
  rm /tmp/build.zip
  if [ -d /var/www/html ]; then
    echo "mkdir /var/www/html"
    mkdir -p -v /var/www/html
  fi
  echo "moving ossn"
  mv -v -f /tmp/ossn /var/www/html/
fi

# Check for OSSN DB config and add
if [ -f /var/www/html/configurations/ossn.config.db.php ]; then
  echo "Using saved OSSN DB config file."
else
  echo "Creating OSSN DB config from template."
  cp /var/www/html/configurations/ossn.config.db.example.php /var/www/html/configurations/ossn.config.db.php
  sed -i "s/replace <<host>>/populate host/g" /var/www/html/configurations/ossn.config.db.php
  sed -i "s/<<host>>/${DBHost}/g" /var/www/html/configurations/ossn.config.db.php
  sed -i "s/replace <<port>>/populate port/g" /var/www/html/configurations/ossn.config.db.php
  sed -i "s/<<port>>/${DBPort}/g" /var/www/html/configurations/ossn.config.db.php
  sed -i "s/replace <<user>>/populate username/g" /var/www/html/configurations/ossn.config.db.php
  sed -i "s/<<user>>/${DBUser}/g" /var/www/html/configurations/ossn.config.db.php
  sed -i "s/replace <<password>>/populate password/g" /var/www/html/configurations/ossn.config.db.php
  sed -i "s/<<password>>/${DBPassword}/g" /var/www/html/configurations/ossn.config.db.php
  sed -i "s/replace <<dbname>>/populate server name/g" /var/www/html/configurations/ossn.config.db.php
  sed -i "s/<<dbname>>/${DBName}/g" /var/www/html/configurations/ossn.config.db.php
fi

# Check for OSSN Site config and add
if [ -f /var/www/html/configurations/ossn.config.site ]; then
  echo "Using saved OSSN Site config file."
else
  echo "Creating OSSN Site config from template."
  cp /var/www/html/configurations/ossn.config.site.example.php /var/www/html/configurations/ossn.config.site.php
     sed -i "s~<<siteurl>>~${servername}~g" /var/www/html/configurations/ossn.config.site.php
  sed -i "s~<<datadir>>~${DataDirectory}~g" /var/www/html/configurations/ossn.config.site.php
fi
