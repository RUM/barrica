create table if not exists
  mailing (
    id            uuid primary key
  , email         varchar(50)
  , email_hash    bytea
  , email_sha     varchar(64) unique
  , confirmed     bool default false
  , news          bool default false
  , release       bool default false
  , paper         bool default false
  , delete_link   varchar(100)
  , settings_link varchar(100)
  );

grant all on mailing to rumadmin;

create or replace function signup(email text, news boolean, release boolean, paper boolean)
returns boolean
language plpgsql as $$ begin

  insert into mailing
    (email, news, release, paper)
    values ($1, $2, $3, $4);

  return true;

end $$;


create or replace function encrypt_email()
returns trigger
language plpgsql as $$ begin

  if tg_op = 'INSERT' then
    new.email_sha = encode(digest(digest(new.email, 'sha256'), 'sha256'), 'hex');
    new.email_hash = pgp_pub_encrypt(new.email, dearmor(current_setting('app.pub_key')));
    new.email = NULL;

    return new;
  end if;

end $$;

create trigger encrypt_email
  before insert on mailing
  for each row
  execute procedure encrypt_email();

create trigger insert_uuid
  before insert on mailing
  for each row
  execute procedure insert_uuid();
