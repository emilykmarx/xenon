# Assumes run from wtf-project
FROM ubuntu:focal

RUN set -ex; \
    groupadd --gid 999 --system mysql; \
    useradd --uid 999 --system --home-dir /var/lib/mysql --no-create-home --gid mysql \
    mysql

# Note: this installs the version of percona that's in the apt repo now
# (5.7.44-48-1.focal, whereas tt had 5.7.34-37.1).
# If this becomes a problem, check percona instructions to install a specific version

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends gnupg2 wget lsb-release curl; \
    wget -P /tmp --no-check-certificate https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb; \
    dpkg -i /tmp/percona-release_latest.$(lsb_release -sc)_all.deb; \
    apt-get update; \
    export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true; \
    {   echo percona-server-server-5.7 percona-server-server-5.7/root-pass password ''; \
        echo percona-server-server-5.7 percona-server-server-5.7/re-root-pass password ''; \
        echo tzdata tzdata/Areas select Asia; \
        echo tzdata tzdata/Zones/Asia select Shanghai; \
    } | debconf-set-selections; \
    apt-get install -y --no-install-recommends libjemalloc1 libmecab2 tzdata; \
    apt-get install -y --no-install-recommends percona-server-server-5.7 \
        percona-server-common-5.7 \
        percona-server-tokudb-5.7; \
    echo "LD_PRELOAD=/usr/lib64/libjemalloc.so.1" >> /etc/default/mysql; \
    echo "THP_SETTING=never" >> /etc/default/mysql; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/mysql /etc/alternatives/my.cnf /etc/mysql/*; \
    mkdir -p /var/lib/mysql /var/log/mysql /var/run/mysqld /etc/mysql/conf.d /docker-entrypoint-initdb.d; \
    chown -R mysql:mysql /var/lib/mysql /var/log/mysql /var/run/mysqld /etc/mysql; \
    chmod 1777 /var/run/mysqld

VOLUME [/var/lib/mysql /var/log/mysql]
COPY xenon/src/build/percona/tt_my.cnf /etc/mysql/my.cnf
COPY xenon/src/build/percona/tt_docker_entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 3306
CMD ["mysqld"]
