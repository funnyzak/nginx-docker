FROM funnyzak/alpine-glibc:latest

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=1.23.3

ENV NGINX_VERSION=nginx-${VERSION}
ENV TZ Asia/Shanghai

ENV TMP_PATH=/mnt/tmp
ENV HEADERS_MORE_NGINX_MODULE=0.36
ENV FANCY_INDEX=0.5.2
# install nginx dependencies
RUN apk --update add wget openssl-dev pcre-dev zlib-dev build-base \
    gd gd-dev \
    perl perl-dev \
    libxslt libxslt-dev libxml2 libxml2-dev geoip geoip-dev

# download nginx source
RUN mkdir -p ${TMP_PATH} && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz -O ${TMP_PATH}/${NGINX_VERSION}.tar.gz

# download headers-more-nginx-module from github
RUN cd ${TMP_PATH} && \
    wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_NGINX_MODULE}.tar.gz -O headers-more-nginx-module.tar.gz && \
    tar -zxvf headers-more-nginx-module.tar.gz \
    && mv headers-more-nginx-module-${HEADERS_MORE_NGINX_MODULE} headers-more-nginx-module

# download ngx-fancyindex from github
RUN cd ${TMP_PATH} && \
    wget http://github.com/aperezdc/ngx-fancyindex/archive/v${FANCY_INDEX}.tar.gz -O ngx-fancyindex.tar.gz && \
    tar -zxvf ngx-fancyindex.tar.gz \
    && mv ngx-fancyindex-${FANCY_INDEX} ngx-fancyindex

# create nginx user
RUN addgroup -S nginx && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

# make nginx source
RUN cd ${TMP_PATH} && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    cd ${TMP_PATH}/${NGINX_VERSION} && \
    ./configure --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib64/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --user=nginx \
    --group=nginx \
    --build=Alpine \
    --add-module=${TMP_PATH}/headers-more-nginx-module \
    --add-module=${TMP_PATH}/ngx-fancyindex \
    --with-select_module \
    --with-poll_module \
    --with-threads \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-http_perl_module=dynamic \
    --with-perl_modules_path=/usr/lib64/perl5 \
    --with-perl=/usr/bin/perl \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-mail=dynamic \
    --with-mail_ssl_module \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-stream_ssl_preread_module \
    --with-compat \
    --with-pcre-jit \
    --with-openssl-opt=no-nextprotoneg && \
    make && make install && \
    ln -s /usr/lib64/nginx/modules /etc/nginx/modules && \
    apk del build-base && \
    rm -rf ${TMP_PATH} && \
    rm -rf /var/cache/apk/*

# Copy custom Nginx configuration files to the container
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/conf.d /etc/nginx/conf.d

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /etc/nginx

EXPOSE 80 443

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]