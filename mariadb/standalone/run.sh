#!/bin/sh

set -x

# execute any pre-init scripts
for i in /scripts/pre-init.d/*sh
do
	if [ -e "${i}" ]; then
		echo "[i] pre-init.d - processing $i"
		. "${i}"
	fi
done

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ -d /var/lib/mysql/mysql ]; then
	echo "[i] MySQL directory already present, skipping creation"
	chown -R mysql:mysql /var/lib/mysql
else
	echo "[i] MySQL data directory not found, creating initial DBs"
	sleep 15 # debug

	chown -R mysql:mysql /var/lib/mysql
	mysql_install_db --user=mysql --ldata=/var/lib/mysql

	if [ "$MARIADB_ROOT_PASSWORD" = "" ]; then
		MARIADB_ROOT_PASSWORD=`pwgen 16 1`
		echo "[i] MySQL root Password: $MARIADB_ROOT_PASSWORD"
	fi

	MARIADB_DATABASE=${MARIADB_DATABASE:-""}
	MARIADB_USER=${MARIADB_USER:-""}
	MARIADB_PASSWORD=${MARIADB_PASSWORD:-""}

	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
	    return 1
	fi

	cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES ;
GRANT ALL ON *.* TO 'root'@'%' identified by '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION ;
GRANT ALL ON *.* TO 'root'@'localhost' identified by '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION ;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MARIADB_ROOT_PASSWORD}') ;
DROP DATABASE IF EXISTS test ;

DROP USER IF EXISTS ''@'localhost';
DROP USER IF EXISTS ''@'mariadb-0';
DELETE FROM mysql.user WHERE `user`.`Host` = '' AND `user`.`User` = 'PUBLIC';
DELETE FROM mysql.user WHERE `user`.`Host` = 'localhost' AND `user`.`User` = 'mysql';

FLUSH PRIVILEGES ;
EOF

	if [ "$MARIADB_DATABASE" != "" ]; then
	    echo "[i] Creating database: $MARIADB_DATABASE"
		if [ "$MARIADB_CHARSET" != "" ] && [ "$MARIADB_COLLATION" != "" ]; then
			echo "[i] with character set [$MARIADB_CHARSET] and collation [$MARIADB_COLLATION]"
			echo "CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\` CHARACTER SET $MARIADB_CHARSET COLLATE $MARIADB_COLLATION;" >> $tfile
		else
			echo "[i] with character set: 'utf8' and collation: 'utf8_general_ci'"
			echo "CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
		fi

	 if [ "$MARIADB_USER" != "" ]; then
		echo "[i] Creating user: $MARIADB_USER with password $MARIADB_PASSWORD"
		echo "GRANT ALL ON \`$MARIADB_DATABASE\`.* to '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';" >> $tfile
	    fi
	fi

	/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < $tfile
	rm -f $tfile

	for f in /docker-entrypoint-initdb.d/*; do
		case "$f" in
			*.sql)    echo "$0: running $f"; /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < "$f"; echo ;;
			*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < "$f"; echo ;;
			*)        echo "$0: ignoring or entrypoint initdb empty $f" ;;
		esac
		echo
	done

	echo
	echo 'MySQL init process done. Ready for start up.'
	echo

	echo "exec /usr/bin/mysqld --user=mysql --console --skip-name-resolve --skip-networking=0" "$@"
fi

# execute any pre-exec scripts
for i in /scripts/pre-exec.d/*sh
do
	if [ -e "${i}" ]; then
		echo "[i] pre-exec.d - processing $i"
		. ${i}
	fi
done

du -sh /tmp # debug

/mysqld_exporter  --mysqld.username root &
exec /usr/bin/mysqld --user=mysql --console --skip-name-resolve --skip-networking=0 $@
