# Nginx Docker

nginx with multiple modules.

[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/nginx.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/nginx.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)

 **Modules**

- ngx_http_geoip_module.so
- ngx_http_image_filter_module.so
- ngx_http_perl_module.so
- ngx_http_xslt_filter_module.so
- ngx_mail_module.so
- ngx_stream_geoip_module.so
- ngx_stream_module.so
- 
## Build

```
# docker: funnyzak:nginx:1.21.4
docker build -—build-arg NGINX_TAG=1.21.4 -t funnyzak/nginx:1.21.4 .
```
## Usage

```
docker run -d -t -i --name nginx --restart always --privileged=true -p 81:80 funnyzak/nginx
```
## Conf
 
###  Nginx.conf
 
```
load_module /usr/lib64/nginx/modules/ngx_http_image_filter_module.so;
load_module /usr/lib64/nginx/modules/ngx_stream_module.so;
load_module /usr/lib64/nginx/modules/ngx_http_geoip_module.so;
load_module /usr/lib64/nginx/modules/ngx_http_xslt_filter_module.so;
load_module /usr/lib64/nginx/modules/ngx_stream_geoip_module.so;
# load_module /usr/lib64/nginx/modules/ngx_http_perl_module.so;
# load_module /usr/lib64/nginx/modules/ngx_mail_module.so;

user  nginx;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  ‘$remote_addr - $remote_user [$time_local] “$request” ‘
    #                  ‘$status $body_bytes_sent “$http_referer” ‘
    #                  ‘”$http_user_agent” “$http_x_forwarded_for”’;

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```
 
## Examples

### docker-compose

```
version: “3.3”
services:
  nginx:
    image: funnyzak/nginx
    container_name: nginx
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/conf.d:/etc/nginx/conf.d
    restart: always
    ports:
      - “1688:80” 
```

Now, running `docker-compose up -d` will run the application for you.


## Reference

- [MaxMind (GeoIp Data)](https://www.maxmind.com/en/accounts/288367/geoip/downloads)
- [Nginx Book](https://ericrap.notion.site/Nginx-1c32ea493c134c36977d8fbd14226079)
- [Nginx Help](https://docs.nginx.com/)