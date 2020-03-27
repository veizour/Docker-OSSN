FROM phusion/baseimage:0.11
MAINTAINER nando

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

# Install proxy Dependencies
RUN apt-get install -y apache2
RUN apt-get install -y php7.1 libapache2-mod-php7.1 php7.1-mcrypt php7.1-cli php7.1-xml php7.1-zip \
                       php7.1-mysql php7.1-mysqlnd php7.1-gd php7.1-imagick php7.1-recode php7.1-tidy \
                       php-curl php7.1-mbstring php7.1-soap php7.1-intl php7.1-ldap php7.1-imap php-xml \
                       php7.1-sqlite php7.1-mcrypt php7.1-common php7.1-xmlrpc inotify-tools

RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*
 
RUN \
  service apache2 restart && \
  rm -R -f /var/www && \
  mkdir -p /var/www/html/ossn/configurations && \
  ln -s /web /var/www

RUN \
  mv /etc/apache2/sites-available/000-default.conf /etc/apache2/000-default.conf && \
  rm /etc/apache2/sites-available/* && \
  rm /etc/apache2/apache2.conf && \
  ln -s /config/proxy-config.conf /etc/apache2/sites-available/000-default.conf && \
  ln -s /config/ossn.config.site /var/www/html/ossn/configurations/ossn.config.site && \
  ln -s /config/ossn.config.db /var/www/html/ossn/configurations/ossn.config.db && \
  ln -s /var/log/apache2 /logs

# Update apache configuration with this one
RUN \
echo "<VirtualHost *:80>" > /etc/apache2/000-default.conf && \
echo "ServerAdmin "${adminlogin}  >> /etc/apache2/000-default.conf && \
echo "DocumentRoot /var/www/html/ossn"  >> /etc/apache2/000-default.conf && \
echo "ServerName "${servername}  >> /etc/apache2/000-default.conf && \
echo "" >> /etc/apache2/000-default.conf && \
echo "<Directory /var/www/html/ossn>"  >> /etc/apache2/000-default.conf && \
echo "     Options FollowSymlinks" >> /etc/apache2/000-default.conf && \
echo "     AllowOverride All" >> /etc/apache2/000-default.conf && \
echo "     Require all granted" >> /etc/apache2/000-default.conf && \
echo "</Directory>" >> /etc/apache2/000-default.conf && \
echo "" >> /etc/apache2/000-default.conf && \
echo "ErrorLog ${APACHE_LOG_DIR}/ossn_error.log" >> /etc/apache2/000-default.conf && \
echo "CustomLog ${APACHE_LOG_DIR}/ossn_access.log combined" >> /etc/apache2/000-default.conf && \
echo "" >> /etc/apache2/000-default.conf && \
echo "</VirtualHost>" >> /etc/apache2/000-default.conf

RUN \
echo "<?php" > /etc/apache2/ossn.config.site && \
echo "/**" >> /etc/apache2/ossn.config.site && \
echo " * Open Source Social Network" >> /etc/apache2/ossn.config.site && \
echo " *" >> /etc/apache2/ossn.config.site && \
echo " * @package   (softlab24.com).ossn" >> /etc/apache2/ossn.config.site && \
echo " * @author    OSSN Core Team <info@softlab24.com>" >> /etc/apache2/ossn.config.site && \
echo " * @copyright (C) SOFTLAB24 LIMITED" >> /etc/apache2/ossn.config.site && \
echo " * @license   Open Source Social Network License (OSSN LICENSE)  http://www.opensource-socialnetwork.org/licence" >> /etc/apache2/ossn.config.site && \
echo " * @link      https://www.opensource-socialnetwork.org/" >> /etc/apache2/ossn.config.site && \
echo " */" >> /etc/apache2/ossn.config.site && \
echo "" >> /etc/apache2/ossn.config.site && \
echo "$Ossn->url = '"${servername}"';" >> /etc/apache2/ossn.config.site && \
echo "$Ossn->userdata = '"${DataDirectory}"';" >> /etc/apache2/ossn.config.site

RUN \
echo "<?php" > /etc/apache2/ossn.config.db && \
echo "/**" >> /etc/apache2/ossn.config.db && \
echo " * Open Source Social Network" >> /etc/apache2/ossn.config.db && \
echo " *" >> /etc/apache2/ossn.config.db && \
echo " * @package   (softlab24.com).ossn" >> /etc/apache2/ossn.config.db && \
echo " * @author    OSSN Core Team <info@softlab24.com>" >> /etc/apache2/ossn.config.db && \
echo " * @copyright (C) SOFTLAB24 LIMITED" >> /etc/apache2/ossn.config.db && \
echo " * @license   Open Source Social Network License (OSSN LICENSE)  http://www.opensource-socialnetwork.org/licence" >> /etc/apache2/ossn.config.db && \
echo " * @link      https://www.opensource-socialnetwork.org/" >> /etc/apache2/ossn.config.db && \
echo " */" >> /etc/apache2/ossn.config.db && \
echo "" >> /etc/apache2/ossn.config.db && \
echo "// replace <<host>> with your database host name;" >> /etc/apache2/ossn.config.db && \
echo "$Ossn->host = '"${DBHost}"';" >> /etc/apache2/ossn.config.db && \
echo "" >> /etc/apache2/ossn.config.db && \
echo "// replace <<port>> with your database host name;" >> /etc/apache2/ossn.config.db && \
echo "$Ossn->port = '"${DBPort}"';" >> /etc/apache2/ossn.config.db && \
echo "" >> /etc/apache2/ossn.config.db && \
echo "// replace <<user>> with your database username;" >> /etc/apache2/ossn.config.db && \
echo "$Ossn->user = '"${DBUser}"';" >> /etc/apache2/ossn.config.db && \
echo "" >> /etc/apache2/ossn.config.db && \
echo "// replace <<password>> with your database password;" >> /etc/apache2/ossn.config.db && \
echo "$Ossn->password = '"${DBPassword}"';" >> /etc/apache2/ossn.config.db && \
echo "" >> /etc/apache2/ossn.config.db && \
echo "// replace <<dbname>> with your database name;" >> /etc/apache2/ossn.config.db && \
echo "$Ossn->database = '"${DBName}"';" >> /etc/apache2/ossn.config.db

ADD apache2.conf /etc/apache2/apache2.conf
ADD ports.conf /etc/apache2/ports.conf


# Manually set the apache environment variables in order to get apache to work immediately.
RUN \
echo www-data > /etc/container_environment/APACHE_RUN_USER && \
echo www-data > /etc/container_environment/APACHE_RUN_GROUP && \
echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR && \
echo /var/lock/apache2 > /etc/container_environment/APACHE_LOCK_DIR && \
echo /var/run/apache2.pid > /etc/container_environment/APACHE_PID_FILE && \
echo /var/run/apache2 > /etc/container_environment/APACHE_RUN_DIR

ADD https://www.opensource-socialnetwork.org/download_ossn/latest/build.zip /tmp/build.zip
RUN unzip /tmp/build.zip -d /tmp
RUN rm /tmp/build.zip

# Expose Ports
EXPOSE 80 443

# The www directory and proxy config location
VOLUME ["/config", "/web", "/logs"]

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
