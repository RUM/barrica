create extension pgcrypto;
create extension pgjwt;
create extension unaccent;

create role rumadmin;

create function insert_uuid()
returns trigger
language plpgsql as $$ begin

  new.id = gen_random_uuid();
  return new;

end $$;

-- create function insert_metadata()
-- returns trigger
-- language plpgsql as $$ begin

--   new.metadata = (select json->'metadata' from table_schemas where name = TG_ARGV[0])::jsonb || new.metadata;
--   return new;

-- end $$;
