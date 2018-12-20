FROM php:5.6.39-fpm-stretch

ENV NGINX_VERSION 1.15.3

RUN set -x && \
    apt-get update && \
    apt-get install -y vim busybox apt-utils build-essential libtool python-setuptools \
          libpcre3 libpcre3-dev libpcre++-dev zlib1g-dev openssl libssl-dev \
	  libfreetype6-dev libjpeg62-turbo-dev libpng-dev libfreetype6-dev \
	  libbz2-dev libmcrypt-dev libmhash-dev libxml2-dev libmemcached-dev \
    && docker-php-ext-install -j$(nproc) bz2 mcrypt bcmath gettext mysql mysqli pcntl pdo_mysql \
       shmop soap sockets sysvmsg sysvsem sysvshm xmlrpc zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

ADD files/ /tmp/files/

RUN	set -x && \
	#
	cd /tmp/files/ && \
	tar xf memcached-2.2.0.tgz && \
	cd memcached-2.2.0 && \
	/usr/local/bin/phpize && \
	./configure --with-libmemcached-dir=/usr/ && \
	make && make install && \
	docker-php-ext-enable memcached && \
	#
	#
	cd /tmp/files/ && \
	tar xf redis-4.2.0.tgz && \
	cd redis-4.2.0 && \
	/usr/local/bin/phpize && \
	./configure && \
	make && make install && \
	docker-php-ext-enable redis  && \
	#
	#
	cd /tmp/files/ && \
	tar xf swoole-1.7.18.tgz && \
	cd swoole-1.7.18 && \
	/usr/local/bin/phpize && \
	./configure && \
	make && make install && \
	docker-php-ext-enable swoole  && \
	#
	#
	cd /tmp/files/ && \
	tar xf xdebug-2.4.0.tgz && \
	cd xdebug-2.4.0 && \
	/usr/local/bin/phpize && \
	./configure && \
	make && make install && \
	docker-php-ext-enable xdebug  && \
	#
	#
	cd /tmp/files/ && \
	tar xf zend-loader-php5.6-linux-x86_64.tgz && \
	cd zend-loader-php5.6-linux-x86_64 && \
	mkdir -p /usr/local/zend/ && \
	cp *.so /usr/local/zend/ && \
	#
	#
	curl -Lk http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | gunzip | tar x -C /tmp/files && \
	#
	cd /tmp/files/nginx-$NGINX_VERSION && \
	#Add user
        mkdir -p /opt/www && \
        useradd -r -s /sbin/nologin -d /opt/www -m -k no www && \
	./configure --prefix=/opt/nginx \
          --user=www --group=www \
          --error-log-path=/var/log/nginx_error.log \
          --http-log-path=/var/log/nginx_access.log \
          --pid-path=/var/run/nginx.pid \
          --with-pcre \
          --with-http_ssl_module \
          --without-mail_pop3_module \
          --without-mail_imap_module \
          --with-http_gzip_static_module && \
	make && make install 
	

RUN cp -f /tmp/files/start.sh /start.sh && \
	cp -f /tmp/files/nginx.conf /opt/nginx/conf/nginx.conf && \
        cp -f /tmp/files/supervisord.conf /etc/supervisord.conf && \
	cp -f /tmp/files/index.php /opt/www && \
	#
	#Install supervisor
	easy_install supervisor
	
EXPOSE 80 443
ENTRYPOINT ["/start.sh"]
	
	
	
	

