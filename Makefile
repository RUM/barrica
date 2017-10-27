# In config.mk:
#
# PASSWD =
# PG_PROD = postgres://...
# PG_DEV = postgres://postgres@localhost
# DBNAME = rum
# DB_DEV = $(PG_DEV)/$(DBNAME)
# DB_PROD = $(PG_PROD)/$(DBNAME)
#
# DB = $(DB_DEV)
# ifdef production
# DB = $(DB_PROD)
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

# ONLY TO BE RAN IN DEV:

build:
	@for file in db releases collabs articles collaborations mailing pages suggestions; do \
		psql $(DB_DEV) --file=sql/$$file.sql ; \
	done

restore:
	@psql $(DB_DEV) \
		--command="SET session_replication_role = replica;" \
		--file=./rum.sql

snippet:
	@psql $(DB_DEV) -f snippet.sql


drop:
	@psql $(TEMPLATE1) -c "drop   database $(DBNAME);"
	@psql $(TEMPLATE1) -c "create database $(DBNAME);"

rebuild: dump drop build restore
