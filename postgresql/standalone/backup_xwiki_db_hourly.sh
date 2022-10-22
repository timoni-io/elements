HOUR=$(date +"%H")

pg_dump xwiki | gzip > /backups/xwiki_db_${HOUR}.sql.gz