create table if not exists
  suggestions (
    id       uuid primary key
  , type     varchar(50)
  , name     varchar(50) not null
  , sinopsis text
  , content  text
  , starred  boolean default false
  , external_link varchar(256)
  , external_link_text varchar(256)
  );

grant all on suggestions to rumadmin;

grant select on table suggestions to guest;

create trigger insert_uuid
  before insert on suggestions
  for each row
  execute procedure insert_uuid();
