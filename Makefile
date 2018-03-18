# In default.mk:
#
# PASSWD =
# PG_PROD = postgres://...
# PG_DEV = postgres://postgres@localhost
# DBNAME = rum
# DB_DEV = $(PG_DEV)/$(DBNAME)
# DB_PROD = $(PG_PROD)/$(DBNAME)
#
# TIME = $(shell date +'%Y-%m-%d--%T')
# DUMP = $(DBNAME)-$(TIME).sql
#
# DB = $(DB_DEV)
#
# ifeq ($(env), production)
# DB = $(DB_PROD)
# endif
#
# TEMPLATE = $(PG)/template1
#
# PGP_PRIVATE_KEY = somefile
# PGP_KEY_PASSWD =
# PGP_PUBLIC_KEY =

# or...
include default.mk

console:
	@psql $(DB) \
		--variable="private_key=`cat $(PGP_PRIVATE_KEY)`" \
		--variable="key_passwd=$(PGP_KEY_PASSWD)" \
		--variable="public_key=`cat $(PGP_PUBLIC_KEY)`"

dump:
	@pg_dump $(DB) \
		--format=p \
		--data-only \
		--no-owner \
		--no-acl > $(DUMP)

	@ln -sf $(DUMP) ./dumps/rum-latest.sql

list:
	@psql $(DB) \
		--pset="pager=off" \
		--command="\dt[+]"

# ONLY TO BE RAN IN DEV:

build:
	@for file in db releases collabs articles collaborations mailing pages suggestions announcements; do \
		psql $(DB_DEV) --file=sql/$$file.sql ; \
	done

restore:
	@psql $(DB_DEV) \
		--command="SET session_replication_role = replica;" \
		--file=./dumps/rum-latest.sql

snippet:
	@psql $(DB_DEV) -f snippet.sql


drop:
	@psql $(TEMPLATE1) -c "drop   database $(DBNAME)_dev;"
	@psql $(TEMPLATE1) -c "create database $(DBNAME)_dev;"

rebuild: drop build restore
