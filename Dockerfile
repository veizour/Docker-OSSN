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
  ln -s -v /web /var/www
  
ADD https://www.opensource-socialnetwork.org/download_ossn/latest/build.zip /tmp/build.zip
RUN unzip /tmp/build.zip -d /tmp
RUN cp -R /tmp/ossn/. /var/www/html/ossn
RUN ls /
RUN ls /var
RUN ls /var/www
RUN ls /web

