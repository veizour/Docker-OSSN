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
 
RUN \
  service apache2 restart && \
  rm -R -f /var/www && \
  ln -s /web /var/www
  
RUN cd /tmp/.
ADD https://www.opensource-socialnetwork.org/download_ossn/latest/build.zip /tmp/build.zip
RUN unzip /tmp/build.zip -d /tmp
RUN cp -r /tmp/ossn /var/www/html/.

RUN chown -R www-data:www-data /var/www/html/ossn/
RUN chmod -R 755 /var/www/html/ossn/
RUN chown -R www-data:www-data /var/www/html/ossn_data
  
# Update apache configuration with this one
RUN \
  mv /etc/apache2/sites-available/000-default.conf /etc/apache2/000-default.conf && \
  rm /etc/apache2/sites-available/* && \
  rm /etc/apache2/apache2.conf && \
  ln -s /config/proxy-config.conf /etc/apache2/sites-available/000-default.conf && \
  ln -s /var/log/apache2 /logs

# Update ossn.config.db configs with variables
RUN \
  set 's/<<host>>/${DBHost}/g' ossn.config.db && \
  set 's/<<port>>/${DBPort}/g' ossn.config.db && \
  set 's/<<password>>/${DBPassword}/g' ossn.config.db && \
  set 's/<<dbname>>/${DBUsername}/g' ossn.config.db

# Update ossn.config.site configs with variables
RUN \
  set 's/<<siteurl>>/${SiteURL}/g' ossn.config.site && \
  set 's/<<datadir>>/${DataDirectory}/g' ossn.config.site

# Update ossn.conf configs with variables
RUN \
  set 's/<<admin@server>>/${adminlogin}/g' ossn.conf && \
  set 's/<<servername>>/${servername}/g' ossn.conf
  
ADD ossn.conf /etc/apache2/000-default.conf
ADD apache2.conf /etc/apache2/apache2.conf
ADD ports.conf /etc/apache2/ports.conf
ADD ossn.config.db /var/www/html/ossn/configuration/ossn.config.db
ADD ossn.config.site /var/www/html/ossn/configuration/ossn.config.site

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
