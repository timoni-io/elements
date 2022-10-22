FROM postgres:14.2-alpine
WORKDIR /docker-entrypoint.d
RUN echo 'sed -i "s/host all all all scram-sha-256/host all all all password/g" /var/lib/postgresql/pgdata/pg_hba.conf' > /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "logging_collector = on" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_directory = 'log'" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_file_mode = 0600" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_rotation_age = 1d" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_rotation_size = 10MB" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh                     
RUN echo 'echo "log_truncate_on_rotation = on" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_connections = on" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_duration = on" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_hostname = on" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_line_prefix = '%m [%p] '" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_statement = 'all'" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN echo 'echo "log_timezone = 'Europe/Warsaw'" >> /var/lib/postgresql/pgdata/postgresql.conf' >> /docker-entrypoint.d/update_pg_access.sh
RUN chmod +rx /docker-entrypoint.d/update_pg_access.sh
