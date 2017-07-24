FROM php:7
RUN apt-get update
RUN apt-get install -y git \
                       wget \
                       alien \
                       libaio1 \
                       apt-transport-https \
                       curl \
                       libmcrypt-dev \
                       zlib1g-dev \
                       libxslt-dev \
                       libpng-dev

WORKDIR /tmp

# Install Composer
RUN curl https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer

# Instaling and configuring oracle client
ADD ./oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
ADD ./oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

RUN alien -i oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm

RUN alien -i oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

ENV LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
RUN echo "/usr/lib/oracle/12.1/client64/lib/" > /etc/ld.so.conf.d/oracle.conf && chmod o+r /etc/ld.so.conf.d/oracle.conf
ENV ORACLE_HOME=/usr/lib/oracle/12.1/client64
ENV C_INCLUDE_PATH=/usr/include/oracle/12.1/client64/
RUN ls -al /usr/include/oracle/12.1/client*/*
RUN ls -al $ORACLE_HOME/lib
RUN ln -s /usr/include/oracle/12.1/client64 $ORACLE_HOME/include

RUN docker-php-ext-install -j$(nproc) oci8 \
                                        pdo \
                                        pdo_oci \
                                        pcntl \
                                        mcrypt \
                                        mbstring \
                                        tokenizer \
                                        zip \
                                        mysqli \
                                        pdo_mysql \
                                        xsl \
                                        gd


ENV XDEBUGINI_PATH=/usr/local/etc/php/conf.d/xdebug.ini
RUN yes | pecl install xdebug
RUN echo "zend_extension="`find /usr/local/lib/php/extensions/ -iname 'xdebug.so'` > $XDEBUGINI_PATH \
    && echo "xdebug.remote_enable=on" >> $XDEBUGINI_PATH \
    && echo "xdebug.remote_autostart=on" >> $XDEBUGINI_PATH \
    && echo "xdebug.remote_connect_back=on" >> $XDEBUGINI_PATH \
    && echo "xdebug.idkey=xdbg" >> $XDEBUGINI_PATH \
    && echo "xdebug.remote_handler=dbgp" >> $XDEBUGINI_PATH \
    && echo "xdebug.profiler_enable=0" >> $XDEBUGINI_PATH \
    && echo "xdebug.profiler_output_dir=\"/var/www/html\""  >> $XDEBUGINI_PATH \
    && echo "xdebug.remote_port=9000"  >> $XDEBUGINI_PATH

RUN echo "xdebug.remote_host="`/sbin/ip route|awk '/default/ { print $3 }'` >> $XDEBUGINI_PATH

ENV DIR=/var/www/html/
RUN mkdir -p $DIR
WORKDIR $DIR
