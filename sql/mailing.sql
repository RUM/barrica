create table if not exists
	mailing (
		  id uuid primary key
		, created date
		, email varchar(128)
		, email_hash bytea
		, email_sha varchar(64) unique
		, confirmed bool default false
		, news bool default false
		, release bool default false
		, paper bool default false
		, test bool default false
		, delete_link varchar(100)
		, settings_link varchar(100)
	);

grant all on mailing to rumadmin;

create function signup(email text, news boolean, release boolean, paper boolean)
returns boolean
language plpgsql as $$ begin
	insert into mailing
		(email, news, release, paper)
		values ($1, $2, $3, $4);

		return true;
end $$;

create function sha_email(email text)
returns text
language plpgsql as $$ begin
	return encode(digest(digest(email, 'sha256'), 'sha256'), 'hex');
end $$;

create function encrypt_email()
returns trigger
language plpgsql as $$ begin
	if tg_op = 'INSERT' then
		new.email_sha = sha_email(new.email);
		new.email_hash = pgp_pub_encrypt(new.email, dearmor(current_setting('app.pub_key')));
		new.email = NULL;

		return new;
	end if;
end $$;

create or replace function decrypted_email(mailing)
returns text
language plpgsql as $$ begin
	return pgp_pub_decrypt($1.email_hash, dearmor(current_setting('s.pk')), current_setting('s.pw'));
end $$;

create function insert_created()
returns trigger
language plpgsql as $$ begin
	if tg_op = 'INSERT' then
		new.created = current_date;

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

create trigger insert_created
  before insert on mailing
  for each row
  execute procedure insert_created();
