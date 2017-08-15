FROM nginx

RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y \
  vim \
  wget

RUN mkdir -p /etc/nginx/sites-available

COPY ./config/nginx/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /app
RUN mkdir -p /logs

WORKDIR /app

CMD nginx -g 'daemon off;'
