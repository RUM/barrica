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

-- create trigger insert_min_metadata
--   before insert or update on collabs
--   for each row
--   execute procedure insert_metadata('collabs');
