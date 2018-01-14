create extension pgcrypto;
create extension pgjwt;
create extension unaccent;

create type months as enum ('enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre');

create role rumadmin;
create role guest nologin;

create function insert_uuid()
returns trigger
language plpgsql as $$ begin
  new.id = gen_random_uuid();
  return new;
end $$;

create function strip_md(text)
returns text
language plpgsql as $$ begin
  return regexp_replace($1, '[#*_]+', '', 'g');
end $$;

create function seo_string(text)
returns text
language plpgsql as $$ begin
  return
    regexp_replace(
      trim(lower(regexp_replace(unaccent($1), '["¿?_*.,:/&\\]+', '', 'g'))),
      '\s+', '-', 'g');
end $$;

create function month_year(anyelement)
returns text
language plpgsql as $$ begin
  return
    initcap((enum_range(NULL::months))[extract(month from $1.date)]::text)
    || ' de ' || extract(year from $1.date)::text;
end $$;

-- create function insert_metadata()
-- returns trigger
-- language plpgsql as $$ begin
--   new.metadata = (select json->'metadata' from table_schemas where name = TG_ARGV[0])::jsonb || new.metadata;
--   return new;
-- end $$;
--
-- create trigger insert_metadata
--   before insert or update on a_table
--   for each row
--   execute procedure insert_metadata('releases');
