FROM phusion/baseimage:0.11
MAINTAINER veizour

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV LC_ALL          C.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8
ENV TERM xterm

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]


# Configure user nobody to match unRAID's settings
 RUN \
 usermod -u 99 nobody && \
 usermod -g 100 nobody && \
 usermod -d /home nobody && \
 chown -R nobody:users /home


RUN add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y mc
RUN apt-get install -y tmux
RUN apt-get install -y wget

# Install proxy Dependencies
RUN apt-get update -y
RUN apt-get install -y apache2
RUN apt-get install -y php7.1 php7.1-common libapache2-mod-php7.1 php7.1-mcrypt php7.1-cli php7.1-xml \
                       php7.1-mysql php7.1-mysqlnd php7.1-gd php7.1-imagick php7.1-recode php7.1-tidy php7.1-xmlrpc \
                       php-curl php7.1-mbstring php7.1-soap php7.1-intl php7.1-ldap php7.1-imap php-xml \
                       php7.1-sqlite php7.1-mcrypt php7.1-zip inotify-tools

RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*
 
RUN service apache2 restart
RUN rm -R -f /var/www
RUN mkdir -p /var/www/html/ossn/
  
ADD https://www.opensource-socialnetwork.org/download_ossn/latest/build.zip /tmp/build.zip
RUN unzip /tmp/build.zip -d /tmp
RUN cp -R /tmp/ossn/. /var/www/html/ossn/.

# Update apache configuration with this one
RUN \
  mv /etc/apache2/sites-available/000-default.conf /etc/apache2/000-default.conf && \
  rm /etc/apache2/sites-available/* && \
  rm /etc/apache2/apache2.conf && \
  ln -s /config/proxy-config.conf /etc/apache2/sites-available/000-default.conf && \
  ln -s /var/log/apache2 /logs && \
  ln -s -v /web /var/www

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
     "</VirtualHost>" > /etc/apache2/000-default.conf
     
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

#ADD proxy-config.conf /etc/apache2/000-default.conf
ADD apache2.conf /etc/apache2/apache2.conf
ADD ports.conf /etc/apache2/ports.conf
#ADD ossn.config.db /var/www/html/ossn/configurations/ossn.config.db
#ADD ossn.config.site /var/www/html/ossn/configurations/ossn.config.site

# Manually set the apache environment variables in order to get apache to work immediately.
RUN \
echo www-data > /etc/container_environment/APACHE_RUN_USER && \
echo www-data > /etc/container_environment/APACHE_RUN_GROUP && \
echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR && \
echo /var/lock/apache2 > /etc/container_environment/APACHE_LOCK_DIR && \
echo /var/run/apache2.pid > /etc/container_environment/APACHE_PID_FILE && \
echo /var/run/apache2 > /etc/container_environment/APACHE_RUN_DIR

# Expose Ports
EXPOSE 80 443

# The www directory and proxy config location
#VOLUME ["/config", "/web", "/logs"]
VOLUME ["/config", "/logs", "/data", "/web"]

RUN chown -R www-data:www-data /var/www/html/ossn/
RUN chmod -R 755 /var/www/html/ossn/
RUN chown -R www-data:www-data /data

# Add our crontab file
ADD crons.conf /root/crons.conf

# Add firstrun.sh to execute during container startup
ADD firstrun.sh /etc/my_init.d/firstrun.sh
RUN chmod +x /etc/my_init.d/firstrun.sh

# Add inotify.sh to execute during container startup
RUN mkdir /etc/service/inotify
ADD inotify.sh /etc/service/inotify/run
RUN chmod +x /etc/service/inotify/run

# Add apache to runit
RUN mkdir /etc/service/apache
ADD apache-run.sh /etc/service/apache/run
RUN chmod +x /etc/service/apache/run
ADD apache-finish.sh /etc/service/apache/finish
RUN chmod +x /etc/service/apache/finish

RUN a2enmod rewrite
