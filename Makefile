# In config.mk:
#
# PASSWD =
# PG = postgres://postgres@localhost
# DBNAME = rum
# TEMPLATE = $(PG)/template1
# DB = $(PG)/$(DBNAME)
# SQLS = db releases collabs articles collaborations mailing pages suggestions

include config.mk

drop:
	@psql $(TEMPLATE) -c "drop   database $(DBNAME);"
	@psql $(TEMPLATE) -c "create database $(DBNAME);"

build:
	@for file in $(SQLS); do \
		psql $(DB) -f sql/$$file.sql ; \
	done

dump:
	@pg_dump $(DB) -Fp --data-only --no-owner --no-acl > /tmp/$(DBNAME).sql
	@mv /tmp/$(DBNAME).sql $(DBNAME)-$$(date +'%Y-%m-%d--%T').sql

restore:
	@cp /tmp/$(DBNAME).sql ./data/rum.sql
	@psql $(DB) -c "SET session_replication_role = replica;" -f ./data/rum.sql

snippet:
	@psql $(DB) -f snippet.sql

list:
	@psql $(DB) -P pager=off -c "\dt[+]"

console:
	@psql $(DB) -v "private_key=`cat ./rum-secret.key`" -v "key_passwd=`cat ./rum-secret-passwd.txt`"

rebuild: dump drop build restore

restore-local:
	@psql postgres://postgres@localhost/rum -c "SET session_replication_role = replica;" -f ./data/rum.sql

restore-new:
	@psql $(DB) -c "SET session_replication_role = replica;" -f ./data/rum.sql
