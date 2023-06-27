#!/bin/bash

PG_VERSION=15
DB_BASEDIR=/data/postgresql-${PG_VERSION}

DATADIR=${DB_BASEDIR}/data
LOGSDIR=${DB_BASEDIR}/logs
LOGFILENAME="postgresql.log"

mkdir -p ${LOGSDIR}
if [ ! -d ${DATADIR} ]
then
    echo "Creating data directory ..."
    mkdir -p ${DATADIR}
 	cp -a /var/lib/postgresql/${PG_VERSION}/main/* ${DATADIR}
fi

cp /etc/postgresql/${PG_VERSION}/main/postgresql.conf.orig /etc/postgresql/${PG_VERSION}/main/postgresql.conf

cat <<EOF >> /etc/postgresql/${PG_VERSION}/main/postgresql.conf
data_directory = '${DATADIR}'
logging_collector = true
log_directory = '${LOGSDIR}'
log_filename = '${LOGFILENAME}'
listen_addresses = '0.0.0.0'
wal_level = hot_standby
hot_standby = on
EOF

cat <<EOF > /etc/postgresql/${PG_VERSION}/main/pg_hba.conf
local all all trust
host all all 127.0.0.1/32 trust
EOF

#cat /etc/postgresql/${PG_VERSION}/main/pg_hba.conf.orig >> /etc/postgresql/${PG_VERSION}/main/pg_hba.conf

touch ${LOGSDIR}/${LOGFILENAME}
chown -R postgres ${DB_BASEDIR}
chmod 700 ${DATADIR}

tail -n 0 -F ${LOGSDIR}/${LOGFILENAME}  &

/etc/init.d/postgresql start

pg_ctlcluster ${PG_VERSION} main status -- -w

pg_lsclusters

cd /app
cargo watch -x run &
CARGO_PID=$!
echo "Cargo started with pid = ${CARGO_PID}"

function finish {
  echo "Stopping Postgresql ..."
  /etc/init.d/postgresql stop
  echo "Bye."
  exit 0
}

trap finish SIGTERM SIGINT SIGHUP

sleep infinity &
wait $!
