#!/bin/bash

# for f in /mnt/configs/*
#  do cp -f $f /var/www/html/config/
# done
# if [ ! -L /var/www/html/files ]; then
# 	ln -s /mnt/files /var/www/html/files
# fi
/usr/local/bundle/bin/puma -C /var/www/html/config/puma.rb
