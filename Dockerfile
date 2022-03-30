FROM ubuntu:20.04
LABEL maintainer="Marty Sloan"

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN set -x \
    && apt-get update && apt-get install -y gnupg gosu \
    && gosu nobody true

RUN apt update \
    && apt install software-properties-common -y \
    && add-apt-repository ppa:ondrej/php \
    && apt install php8.1-fpm libncurses5 -y

COPY ./build-packages /root

RUN mkdir -p /opt/informix/clientsdk
RUN tar xf /root/PDO_INFORMIX-1.3.3.tar -C /opt/informix/
RUN tar xf /root/clientsdk.4.10.FC7DE.LINUX.tar -C /opt/informix/clientsdk
RUN mv /root/csdk.properties /opt/informix/clientsdk

RUN groupadd informix \
    && useradd -g informix -p supersecret -d /dev/null informix \
    && chown -R informix.informix /opt/informix \
    && export INFORMIXDIR=/opt/informix

RUN cd /opt/informix/clientsdk && ./installclientsdk -i silent -f ./csdk.properties