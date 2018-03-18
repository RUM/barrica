create table if not exists
  announcements (
    id       uuid primary key
  , title    varchar(50) not null
  , content  text not null
  , due      date
  , sent     date
  );

grant all on announcements to rumadmin;

create trigger insert_uuid
  before insert on announcements
  for each row
  execute procedure insert_uuid();

create or replace function announcements_cleanup()
returns trigger
language plpgsql immutable as $$ begin
  if ((old.sent is not null) and (old.sent != new.sent)) then
    raise exception 'Cannot update sent announcements.';
  end if;

  if (new.sent != current_date) then
    raise exception 'Sent has to be set to TODAY.';
  end if;

  new.content = trim_or_null(new.content);
  new.title = trim_or_null(new.title);

  return new;
end $$;

create trigger announcements_cleanup
  before update on announcements
  for each row
  execute procedure announcements_cleanup();
