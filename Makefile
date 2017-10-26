# In config.mk:
#
# PASSWD =
# PG_PROD = postgres://...
# PG_DEV = postgres://postgres@localhost
# DBNAME = rum
# DB = $(PG_DEV)/$(DBNAME)
#
# ifdef production
# DB = $(PG_PROD)/$(DBNAME)
# endif
#
# TEMPLATE = $(PG)/template1

# or...
include config.mk

console:
	@psql $(DB) \
		--variable="private_key=`cat ./rum-secret.key`" \
		--variable="key_passwd=`cat ./rum-secret-passwd.txt`"

dump:
	@pg_dump $(DB) \
		--format=p \
		--data-only \
		--no-owner \
		--no-acl > $(DBNAME)-$$(date +'%Y-%m-%d--%T').sql

list:
	@psql $(DB) \
		--pset="pager=off" \
		--command="\dt[+]"

build:
	@for file in db releases collabs articles collaborations mailing pages suggestions; do \
		psql $(DB) --file=sql/$$file.sql ; \
	done

restore:
	@psql $(DB) \
		--command="SET session_replication_role = replica;" \
		--file=./rum.sql

snippet:
	@psql $(DB) -f snippet.sql


drop:
	@psql $(TEMPLATE1) -c "drop   database $(DBNAME);"
	@psql $(TEMPLATE1) -c "create database $(DBNAME);"

rebuild: dump drop build restore
