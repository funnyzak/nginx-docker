# Nginx Docker

[![Build Status][build-status-image]][build-status]
[![Docker Stars][docker-star-image]][docker-hub-url]
[![Docker Pulls][docker-pull-image]][docker-hub-url]
[![GitHub release (latest by date)][latest-release]][repository-url]
[![GitHub][license-image]][repository-url]

A nginx docker image with some useful modules.

Download size of this image is:

[![Image Size][docker-image-size]][docker-hub-url]

[Docker hub image: funnyzak/nginx][docker-hub-url]

**Docker Pull Command**: `docker pull funnyzak/nginx:latest`

## Installed Modules

- [ngx_http_geoip_module.so](https://nginx.org/en/docs/http/ngx_http_geoip_module.html)
- [ngx_http_image_filter_module.so](https://nginx.org/en/docs/http/ngx_http_image_filter_module.html)
- ngx_http_perl_module.so
- ngx_http_xslt_filter_module.so
- ngx_mail_module.so
- ngx_stream_geoip_module.so
- ngx_stream_module.so
- [headers-more-nginx-module](https://github.com/openresty/headers-more-nginx-module)
- ...

More modules can be found in [Dockerfile](https://github.com/funnyzak/nginx-docker/blob/main/Dockerfile).

## Usage

### docker

First, create a `nginx.conf` file in your project directory, and then run the following command:

```bash
docker run -d -t -i --name nginx --restar on-failure \
  -v /path/to/nginx.conf:/etc/nginx/nginx.conf \
  -v /path/to/conf.d:/etc/nginx/conf.d \
  -p 1688:80 \
  funnyzak/nginx
```

### docker-compose

First, create a `docker-compose.yml` file in your project directory:

```yaml
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
    restart: on-failure
    ports:
      - “1688:80” 
```

Now, running `docker-compose up -d` will run the application for you.

### Docker Build

```bash
docker build \
--build-arg VCS_REF=`git rev-parse --short HEAD` \
--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
--build-arg VERSION="1.23.3"
-t funnyzak/nginx:1.23.3 .
```

## Conf Configuration

### Nginx.conf

```conf
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

## Reference

- [MaxMind (GeoIp Data)](https://www.maxmind.com/en/accounts/288367/geoip/downloads)
- [Nginx Book](https://ericrap.notion.site/Nginx-1c32ea493c134c36977d8fbd14226079)
- [Nginx Help](https://docs.nginx.com/)

## Contribution

If you have any questions or suggestions, please feel free to submit an issue or pull request.

<a href="https://github.com/funnyzak/vue-starter/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=funnyzak/nginx-docker" />
</a>

## License

MIT License © 2022 [funnyzak](https://github.com/funnyzak)

[build-status-image]: https://github.com/funnyzak/nginx-docker/actions/workflows/build.yml/badge.svg
[build-status]: https://github.com/funnyzak/nginx-docker/actions
[repository-url]: https://github.com/funnyzak/nginx-docker
[license-image]: https://img.shields.io/github/license/funnyzak/nginx-docker?style=flat-square&logo=github&logoColor=white&label=license
[latest-release]: https://img.shields.io/github/v/release/funnyzak/nginx-docker
[docker-star-image]: https://img.shields.io/docker/stars/funnyzak/nginx.svg?style=flat-square
[docker-pull-image]: https://img.shields.io/docker/pulls/funnyzak/nginx.svg?style=flat-square
[docker-image-size]: https://img.shields.io/docker/image-size/funnyzak/nginx
[docker-hub-url]: https://hub.docker.com/r/funnyzak/nginx
