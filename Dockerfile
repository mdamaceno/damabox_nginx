FROM ubuntu:16.04

RUN apt-get update && apt-get -y upgrade

ENV RUBY_VERSION=2.4.0
ENV NGINX_WORKER_PROCESSES=1
ENV NGINX_WORKER_CONNECTIONS=1024
ENV NGINX_KEEPALIVE_TIMEOUT=65

ENV DEBIAN_FRONTEND noninteractive
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get install -y \
  vim \
  curl \
  libcurl4-gnutls-dev \
  git \
  libxslt-dev \
  libxml2-dev \
  libpq-dev \
  libffi-dev \
  imagemagick

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

RUN \curl -sSL https://get.rvm.io | bash

RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc

RUN /bin/bash -l -c 'rvm requirements'
RUN /bin/bash -l -c 'rvm install $RUBY_VERSION && rvm use $RUBY_VERSION --default'
RUN /bin/bash -l -c 'rvm rubygems current'

RUN /bin/bash -l -c "gem install passenger --no-rdoc --no-ri"

RUN /bin/bash -l -c "passenger-install-nginx-module --auto --auto-download --prefix=/etc/nginx"

RUN /bin/bash -l -c 'gem install bundler'

RUN mkdir -p /etc/nginx/conf/sites-available

COPY ./config/nginx/nginx.conf /etc/nginx/conf/nginx.conf

RUN apt-get -y install nodejs

RUN mkdir -p /var/log/nginx/

RUN mkdir /app

WORKDIR /app

CMD /etc/nginx/sbin/nginx -g 'daemon off;'
