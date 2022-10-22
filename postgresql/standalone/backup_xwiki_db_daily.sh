TODAY=$(date +"%Y%m%d%H%M")

pg_dump xwiki | gzip > /backups/xwiki_db_${TODAY}.sql.gz