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
  imagemagick \
  software-properties-common

# Install certbot
RUN add-apt-repository ppa:certbot/certbot -y
RUN apt-get update && apt-get install -y python-certbot-nginx

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

RUN \curl -sSL https://get.rvm.io | bash

RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc

RUN /bin/bash -l -c 'rvm requirements'
RUN /bin/bash -l -c 'rvm install $RUBY_VERSION && rvm use $RUBY_VERSION --default'
RUN /bin/bash -l -c 'rvm rubygems current'

RUN /bin/bash -l -c "gem install passenger --no-rdoc --no-ri"

RUN /bin/bash -l -c "passenger-install-nginx-module --auto --auto-download --prefix=/etc/nginx"

RUN /bin/bash -l -c 'gem install bundler'

RUN mkdir -p /etc/nginx/conf/sites-available /etc/ssl/certs /etc/ssl/private /var/log/nginx/ /app

COPY ./config/nginx/nginx.conf /etc/nginx/conf/nginx.conf

COPY ./scripts/nginx.sh .

RUN mv /nginx.sh /etc/init.d && mv /etc/init.d/nginx.sh /etc/init.d/nginx && chmod a+x /etc/init.d/nginx

RUN apt-get -y install nodejs

WORKDIR /app

EXPOSE 80
EXPOSE 443

CMD /etc/nginx/sbin/nginx -g 'daemon off;'
