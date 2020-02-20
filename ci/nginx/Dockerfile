FROM registry.access.redhat.com/ubi8/ubi-minimal

LABEL name="pipelies-index" \
      vendor="Kabanero" \
      version="1" \
      release="1" \
      summary="Nginx container to host Kabanero pipelines" \
      description="Nginx container to host Kabanero pipelines"

COPY nginx/nginx.repo  /etc/yum.repos.d/nginx.repo

RUN microdnf install nginx findutils \
    && mkdir /var/cache/nginx \
    && chown -R nginx:0 /var/log/nginx/ /var/cache/nginx /usr/share/nginx \
    && chmod -R g=u /var/log/nginx/ /var/cache/nginx /usr/share/nginx \
    && mkdir /licenses \
    && cp /usr/share/doc/nginx*/* /licenses

COPY nginx/nginx.conf  /etc/nginx/nginx.conf
COPY nginx/nginx-ssl.conf  /etc/nginx/nginx-ssl.conf
COPY nginx/startup.sh  /opt/startup.sh
COPY assets            /opt/www/public

EXPOSE 8080
EXPOSE 8443

RUN touch /var/run/nginx.pid && \
  chown -R nginx:0 /var/run/nginx.pid /var/cache/nginx /opt/www/public /etc/nginx /run && \
  chmod -R g=u /opt/www/public /var/cache/nginx /etc/nginx /var/run/nginx.pid /run

USER nginx

ENTRYPOINT ["/opt/startup.sh"]
