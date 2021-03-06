#!/bin/bash

if [ $pull = "true" ]; then
  if [ -f /var/www/html/configurations/ossn.config.db.php ]; then
    mv -f /var/www/html/configurations/ossn.config.db.php /tmp/ossn.config.db.php
  fi
  if [ -f /var/www/html/configurations/ossn.config.site.php ]; then
    mv -f /var/www/html/configurations/ossn.config.site.php /tmp/ossn.config.site.php
  fi
  rm -R /var/www/html
fi
  
# Check if config exists. If not, copy in the sample config
if [ -f /config/proxy-config.conf ]; then
  echo "Using saved config file."
else
  echo "Creating config from template."
  sed -i "s/admin@example.com/${adminlogin}/g" /etc/apache2/000-default.conf
  sed -i "s/example.com/${servername}/g" /etc/apache2/000-default.conf
  cp -f /etc/apache2/000-default.conf /config/proxy-config.conf
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
if [ -d /var/www/html ]; then
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

if [ -f /tmp/ossn.config.db.php ]; then
  mv -f /tmp/ossn.config.db.php /var/www/html/configurations/ossn.config.db.php
fi
if [ -f /tmp/ossn.config.site.php ]; then
  mv -f /tmp/ossn.config.site.php /var/www/html/configurations/ossn.config.site.php
fi
