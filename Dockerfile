FROM ubuntu:20.04
LABEL maintainer="Marty Sloan"

ENV TZ=UTC
ENV INFORMIXDIR=/opt/informix

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN set -x \
    && apt-get update && apt-get install -y gnupg gosu \
    && gosu nobody true

ENV PHP_VERSION=8.1

RUN apt-get install expect wget build-essential software-properties-common apt-utils nano -y \
    && add-apt-repository ppa:ondrej/php \
    && apt-get install php${PHP_VERSION}-fpm php${PHP_VERSION}-dev php${PHP_VERSION}-mysql libncurses5 -y

RUN rm -rf /var/lib/apt/lists/*

COPY ./buildFiles /root

RUN mkdir -p /opt/informix/clientsdk

RUN wget -qO- "https://cloud.karmatek.io/s/Ydfjq5Rgbbmaqid/download?path=%2Fphp-informix&files=clientsdk.4.10.FC7DE.LINUX.tar" | tar xf - -C /opt/informix/clientsdk
RUN wget -qO- "https://cloud.karmatek.io/s/Ydfjq5Rgbbmaqid/download?path=%2Fphp-informix&files=PDO_INFORMIX-1.3.6.tgz" | tar xzf - -C /opt/informix

RUN groupadd informix \
    && adduser --system --no-create-home --group informix \
    && chown -R informix.informix /opt/informix

# The Informix installer is supposed to run silently (./installclientsdk -i silent -f ./installer.properties)
# but every time it fails with exit code 40 (InstallAnywhere code).  We use expect instead....
WORKDIR /opt/informix/clientsdk
RUN mv /root/csdkInstaller.exp ./ && chown informix: csdkInstaller.exp && chmod +x csdkInstaller.exp
RUN ./csdkInstaller.exp


RUN ln -s $(php-config --include-dir)/ext /usr/include/php/ext
WORKDIR /opt/informix/PDO_INFORMIX-1.3.6
RUN phpize
RUN ./configure --with-pdo-informix=/opt/informix
RUN make
RUN make install

RUN mv /root/pdo_informix.ini /etc/php/${PHP_VERSION}/mods-available
RUN ln -s /etc/php/${PHP_VERSION}/mods-available/pdo_informix.ini /etc/php/${PHP_VERSION}/cli/conf.d/pdo_informix.ini
RUN cp /opt/informix/lib/esql/libifgl[s,x].so /lib/x86_64-linux-gnu

WORKDIR /root
RUN rm -rf /tmp/* /opt/informix/clientsdk /opt/informix/*.log /opt/informix/OAT /opt/informix/uninstall /opt/informix/PDO_INFORMIX-1.3.6