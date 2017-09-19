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

-- create trigger insert_metadata
--   before insert or update on releases
--   for each row
--   execute procedure insert_metadata('releases');
