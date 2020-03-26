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
if [ -f /web/html/ossn ]; then
  echo "Using OSSN folder found."
else
  echo "Populating OSSN folder."
  RUN cp -R /tmp/ossn/. /web/html/ossn/.
fi

# Check for OSSN DB config and add
if [ -f /config/ossn.config.db ]; then
  echo "Using saved OSSN DB config file."
else
  echo "Creating OSSN DB config from template."
  ln -s /config/ossn.config.db /web/html/ossn/configurations/ossn.config.db
  mv /etc/apache2/ossn.config.db /config/ossn.config.db
fi

# Check for OSSN Site config and add
if [ -f /config/ossn.config.site ]; then
  echo "Using saved OSSN Site config file."
else
  echo "Creating OSSN Site config from template."
  ln -s /config/ossn.config.site /web/html/ossn/configurations/ossn.config.site
  mv /etc/apache2/ossn.config.site /config/ossn.config.site
  RUN service apache2 restart
fi
