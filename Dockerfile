FROM ubuntu:20.04
LABEL maintainer="Marty Sloan"

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN set -x \
    && apt-get update && apt-get install -y gnupg gosu \
    && gosu nobody true

ENV PHP_VERSION=8.1

RUN apt-get install expect wget build-essential software-properties-common apt-utils -y \
    && add-apt-repository ppa:ondrej/php \
    && apt-get install php${PHP_VERSION}-fpm libncurses5 -y

COPY ./buildFiles /root

RUN mkdir -p /opt/informix/clientsdk

WORKDIR /root

RUN wget -qO- "https://cloud.karmatek.io/s/Ydfjq5Rgbbmaqid/download?path=%2Fphp-informix&files=clientsdk.4.10.FC7DE.LINUX.tar" | tar xf - -C /opt/informix/clientsdk
RUN wget -qO- "https://cloud.karmatek.io/s/Ydfjq5Rgbbmaqid/download?path=%2Fphp-informix&files=PDO_INFORMIX-1.3.6.tgz" | tar xzf - -C /opt/informix

RUN groupadd informix \
    && useradd -g informix -p supersecret -d /dev/null informix \
    && chown -R informix.informix /opt/informix \
    && export INFORMIXDIR=/opt/informix

# The Informix installer is supposed to run silent (./installclientsdk -i silent -f ./installer.properties)
# but every time it fails with exit code 40 (InstallAnywhere code).  We use expect instead....
WORKDIR /opt/informix/clientsdk
RUN mv /root/csdkInstaller.exp ./ && chown informix: csdkInstaller.exp && chmod +x csdkInstaller.exp
RUN ./csdkInstaller.exp


RUN apt-get install -y php${PHP_VERSION}-dev
RUN ln -s $(php-config --include-dir)/ext /usr/include/php/ext
WORKDIR /opt/informix/PDO_INFORMIX-1.3.6
ENV INFORMIXDIR=/opt/informix
RUN phpize
RUN ./configure --with-pdo-informix=/opt/informix
RUN make
RUN make install

RUN mv /root/pdo_informix.ini /etc/php/${PHP_VERSION}/mods-available
RUN ln -s /etc/php/${PHP_VERSION}/mods-available/pdo_informix.ini /etc/php/${PHP_VERSION}/cli/conf.d/pdo_informix.ini
# RUN cp /opt/informix/OAT/PHP_5.4.4/lib/php/extensions/pdo_informix.so $(php-config --extension-dir)
RUN cp /opt/informix/lib/esql/libifgls.so /lib/x86_64-linux-gnu
RUN cp /opt/informix/lib/esql/libifglx.so /lib/x86_64-linux-gnu