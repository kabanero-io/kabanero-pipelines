#!/bin/sh

CONF_FILE=
if [ -f "/etc/tls/private/tls.crt" -a -f  "/etc/tls/private/tls.key" ]; then
    CONF_FILE="-c /etc/nginx/nginx-ssl.conf"
fi

exec nginx $CONF_FILE
