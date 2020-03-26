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

if [ -f /etc/apache2/sites-enabled/000-default.conf ]; then
  rm /etc/apache2/sites-enabled/000-default.conf
fi
if [ -f var/www/html/ossn/configurations/ossn.config.site ]; then
  rm var/www/html/ossn/configurations/ossn.config.site
fi
if [ -f /var/www/html/ossn/configurations/ossn.config.db ]; then
  rm /var/www/html/ossn/configurations/ossn.config.db
fi
# Generate ossn conf files
RUN echo \
     "<VirtualHost *:80>\n" \
     "ServerAdmin "$adminlogin"\n" \
     "DocumentRoot /var/www/html/\n" \
     "ServerName "$servername"\n" \
     "\n" \
     "<Directory /var/www/html/>\n" \ 
     "     Options FollowSymlinks\n" \
     "     AllowOverride All\n" \
     "     Require all granted\n" \
     "</Directory>\n" \
     "\n" \
     "ErrorLog ${APACHE_LOG_DIR}/ossn_error.log\n" \
     "CustomLog ${APACHE_LOG_DIR}/ossn_access.log combined\n" \
     "\n" \
     "</VirtualHost>" > /etc/apache2/sites-enabled/000-default.conf
     
RUN echo \
     "<?php\n" \
     "/**\n" \
     " * Open Source Social Network\n" \
     " *\n" \
     " * @package   (softlab24.com).ossn\n" \
     " * @author    OSSN Core Team <info@softlab24.com>\n" \
     " * @copyright (C) SOFTLAB24 LIMITED\n" \
     " * @license   Open Source Social Network License (OSSN LICENSE)  http://www.opensource-socialnetwork.org/licence\n" \
     " * @link      https://www.opensource-socialnetwork.org/\n" \
     " */\n" \
     "\n" \
     "$Ossn->url = '"$servername"';\n" \
     "$Ossn->userdata = '"$DataDirectory"';\n" > /var/www/html/ossn/configurations/ossn.config.site

RUN echo \
     "<?php\n" \
     "/**\n" \
     " * Open Source Social Network\n" \
     " *\n" \
     " * @package   (softlab24.com).ossn\n" \
     " * @author    OSSN Core Team <info@softlab24.com>\n" \
     " * @copyright (C) SOFTLAB24 LIMITED\n" \
     " * @license   Open Source Social Network License (OSSN LICENSE)  http://www.opensource-socialnetwork.org/licence\n" \
     " * @link      https://www.opensource-socialnetwork.org/\n" \
     " */\n" \
     "\n" \
     "// replace <<host>> with your database host name;\n" \
     "$Ossn->host = '"$DBHost"';\n" \
     "\n" \
     "// replace <<port>> with your database host name;\n" \
     "$Ossn->port = '"$DBPort"';\n" \
     "\n" \
     "// replace <<user>> with your database username;\n" \
     "$Ossn->user = '"$DBUser"';\n" \
     "\n" \
     "// replace <<password>> with your database password;\n" \
     "$Ossn->password = '"$DBPassword"';\n" \
     "\n" \
     "// replace <<dbname>> with your database name;\n" \
     "$Ossn->database = '"$DBName"';" > /var/www/html/ossn/configurations/ossn.config.db
