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
    && apt install php8.1-fpm -y
