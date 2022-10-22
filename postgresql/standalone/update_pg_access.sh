#!/bin/sh

set -ex

sed -i "s/host all all all scram-sha-256/host all all all password/g" /var/lib/postgresql/pgdata/pg_hba.conf
echo "logging_collector = on" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_directory = log" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_filename = postgresql-%Y-%m-%d_%H%M%S.log" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_file_mode = 0600" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_rotation_age = 1d" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_rotation_size = 10MB" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_truncate_on_rotation = on" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_connections = on" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_duration = on" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_hostname = on" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_line_prefix = %m [%p] " >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_statement = all" >> /var/lib/postgresql/pgdata/postgresql.conf
echo "log_timezone = Europe/Warsaw" >> /var/lib/postgresql/pgdata/postgresql.conf
