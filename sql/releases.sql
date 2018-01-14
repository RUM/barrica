create table if not exists
  releases (
    id       uuid primary key
  , number   integer not null
  , date     date
  , name     varchar(50)
  , quote    text
  , file     varchar(50)
  , cover    varchar(50)
  , online   bool default false
  , metadata jsonb default '{}'
  );

grant all on releases to rumadmin;

grant select on table releases to guest;

create trigger insert_uuid
  before insert on releases
  for each row
  execute procedure insert_uuid();

create function seo_name(releases)
returns text as $$
  select seo_string($1.name);
$$ language sql;

create function publish_articles()
returns trigger
language plpgsql as $$ begin
  if tg_op = 'UPDATE' then
    update articles set online = new.online where release_id = new.id;
  end if;

  return new;
end $$;

create trigger publish_articles
  after update on releases
  for each row
  execute procedure publish_articles();
