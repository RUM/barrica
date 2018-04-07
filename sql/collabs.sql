create table if not exists
	collabs (
		  id uuid primary key
		, fname varchar(50) not null
		, lname varchar(50) not null
		, aka varchar(50)
		, sinopsis text
		, starred boolean default false
		, online boolean default false
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

create function name(collabs)
returns text as $$
	select
		coalesce(nullif($1.fname || ' ', '_ '), '') ||
		coalesce(nullif($1.lname || ' ', '_ '), '') ||
		coalesce('"' || $1.aka || '"', '');
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

create or replace view collabs_index_letters as
	select array(
		select distinct on (t) unaccent(left(coalesce(nullif(lname, '_'), aka),1)) as t
		from collabs
		where online
		order by t asc);

grant select on table collabs_index_letters to guest;
