#!/bin/bash

/etc/init.d/nginx start

tail -f /etc/nginx/logs/error.log -f /etc/nginx/logs/access.log
