create table if not exists
  collabs (
    id       uuid primary key
  , fname    varchar(50) not null
  , lname    varchar(50) not null
  , sinopsis text
  , starred  boolean default false
  , online   boolean default false
  , metadata jsonb default '{
      "image": null
    }'
  );

grant all on collabs to rumadmin;

grant select on table collabs to guest;

create trigger insert_uuid
  before insert on collabs
  for each row
  execute procedure insert_uuid();

create function name(collabs) returns text as $$
  select $1.fname || ' ' || $1.lname;
$$ language sql;

create function seo_name(collabs)
returns text as $$
  select seo_string($1.name);
$$ language sql;

create or replace function collabs_suggestion(i int)
returns table(id uuid)
language plpgsql immutable as $$ begin
  return query
    select collabs.id
      from collabs
      where starred and online
      order by random()
      limit i;
end $$;

