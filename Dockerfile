FROM centos:centos7 AS builder

# build nginx version eg: 1.21.4
ARG NGINX_VERSION

# temp dir
ARG TMP_DIR=/mnt/tmp

# nginx source extract dir
ARG NGINX_SOURCE=${TMP_DIR}/nginx-${NGINX_VERSION}

RUN set -x && \
  yum update -y && \
  yum install -y gcc \
  wget tree man \
  pcre pcre-devel \
  zlib zlib-devel \
  openssl openssl-devel \
  gd gd-devel \
  perl perl-devel perl-ExtUtils-Embed \
  libxslt libxslt-devel libxml2 libxml2-devel \
  GeoIP GeoIP-devel && \
  yum groupinstall -y 'Development Tools'


RUN mkdir -p ${TMP_DIR} 
# Download sources
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O ${TMP_DIR}/nginx.tar.gz

# extract nginx package 
RUN tar -zxC ${TMP_DIR} -f ${TMP_DIR}/nginx.tar.gz

# compiler nginx source
RUN mkdir -p /var/log/nginx && mkdir -p /var/cache/nginx && \
  cd ${NGINX_SOURCE} && \
  # cp man/nginx.8 /usr/share/man/man8 \
  # gzip /usr/share/man/man8/nginx.8 \
  # ls /usr/share/man/man8/ | grep nginx.8.gz \
  ./configure --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib64/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --user=nginx \
    --group=nginx \
    --build=CentOS \
    --with-select_module \
    --with-poll_module \
    --with-threads \
    --with-file-aio \
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
    rm -rf ${TMP_DIR}



FROM centos:centos7

COPY --from=builder /var/log /var/log
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /usr/lib64/nginx/modules /usr/lib64/nginx/modules
COPY --from=builder /var/cache/nginx /var/cache/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d /etc/nginx/conf.d

RUN set -x && \ 
  yum update -y && \
  yum install -y pcre pcre-devel \
  zlib zlib-devel \
  openssl openssl-devel \
  gd gd-devel \
  perl perl-devel perl-ExtUtils-Embed \
  libxslt libxslt-devel libxml2 libxml2-devel \
  GeoIP GeoIP-devel && \
  useradd --system --home /var/cache/nginx --shell /sbin/nologin --comment "nginx user" --user-group nginx && \
  ln -sf /dev/stdout /var/log/nginx/access.log && \ 
  ln -sf /dev/stderr /var/log/nginx/error.log 

WORKDIR /usr/sbin/

EXPOSE 80 443

CMD ["/usr/sbin/nginx","-g","daemon off;"]





