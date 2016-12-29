# BareOS director Dockerfile
FROM       debian:latest
MAINTAINER Barcus <fjfc83@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install wget

RUN wget -q http://download.bareos.org/bareos/release/latest/Debian_8/Release.key -O- | apt-key add - && \
    echo 'deb download.bareos.org/bareos/release/latest/Debian_8/ /' > /etc/apt/sources.list.d/bareos.list && \
    echo 'bareos-database-common bareos-database-common/dbconfig-install boolean false' | debconf-set-selections && \
    echo 'bareos-database-common bareos-database-common/install-error select ignore' | debconf-set-selections && \
    echo 'bareos-database-common bareos-database-common/database-type select mysql' | debconf-set-selections && \
    echo 'bareos-database-common bareos-database-common/missing-db-package-error select ignore' | debconf-set-selections && \
    echo 'postfix postfix/main_mailer_type select No configuration' | debconf-set-selections && \
    apt-get update -qq && \
    apt-get install -qq -y bareos bareos-database-mysql mysql-client && \
    apt-clean

COPY docker-entrypoint.sh /
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-dir.tgz /etc/bareos

EXPOSE 9101

VOLUME /etc/bareos

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-dir", "-u", "bareos", "-f"]
