create table if not exists
	announcements (
		  id uuid primary key
		, title varchar(50) not null
		, text_body text not null
		, html_body text
		, sent date
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

	new.text_body = trim_or_null(new.text_body);
	new.html_body = trim_or_null(new.html_body);
	new.title = trim_or_null(new.title);

	return new;
end $$;

create trigger announcements_cleanup
	before update on announcements
	for each row
	execute procedure announcements_cleanup();

create or replace function announcements_keep_sent()
returns trigger
language plpgsql immutable as $$ begin
	if ((old.sent is not null) and (tg_op = 'DELETE')) then
		raise exception 'Cannot delete sent announcements.';
	end if;
end $$;

create trigger announcements_keep_sent
	before delete on announcements
	for each row
	execute procedure announcements_keep_sent();
