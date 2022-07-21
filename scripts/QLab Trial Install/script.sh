#!/usr/bin/env bash

file="QLab.zip"
url='https://figure53.com/downloads/QLab.zip'

curl -s -o /tmp/${file} ${url};

unzip /tmp/QLab.zip -d /Applications/;

rm -f /tmp/QLab.zip

exit 0