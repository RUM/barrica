create table if not exists
	articles (
		  id uuid primary key
		, title varchar(256) not null
		, subtitle varchar(256)
		, file varchar(50)
		, quote text
		, content text
		, cover text
		, asset varchar(256) default null
		, tags jsonb default '[]'
		, starred boolean default false
		, online boolean default false
		, doc_only boolean default false
		, release_id uuid references releases (id) on update cascade
		, metadata jsonb default '{
		  "section": 0,

		  "references": [{
		    "name": null
		  , "url": null
		  }]
		}'
	);

grant all on articles to rumadmin;

grant select on table articles to guest;

create function articles_with_tags(tags_array jsonb)
returns table(id uuid)
language plpgsql immutable as $$ begin
	return query
		select articles.id
			from articles
			where tags::jsonb ?| array(select jsonb_array_elements_text(tags_array));
			-- where tags::jsonb ?& array(select jsonb_array_elements_text(tags_array));
end $$;

create or replace function articles_suggestion(i int)
returns table(id uuid)
language plpgsql immutable as $$ begin
	return query
		select articles.id
			from articles
			where starred and online
			order by random()
			limit i;
end $$;

create function articles_clean_up()
returns trigger
language plpgsql as $$ begin
	new.content = trim_or_null(new.content);
	new.quote = trim_or_null(new.quote);

	new.tags = to_json(array(select lower(trim(json_array_elements_text(new.tags::json)))))::jsonb - '';

	return new;
end $$;

create trigger articles_clean_up
	before update on articles
	for each row
	execute procedure articles_clean_up();

create trigger insert_uuid
	before insert on articles
	for each row
	execute procedure insert_uuid();

create function section_name(articles)
returns text as $$
	select (metadata::jsonb->>'sections')::jsonb->>($1.metadata::jsonb->>'section')::integer
		from releases
		where id = $1.release_id;
$$ language sql;

create function release_name(articles)
returns text as $$
	select name
		from releases
		where id = $1.release_id;
$$ language sql;

create function release_date(articles)
returns date as $$
	select date
		from releases
		where id = $1.release_id;
$$ language sql;

create function release_month_year(articles)
returns text as $$
	select month_year($1.release_date);
$$ language sql;

create function seo_title(articles)
returns text as $$
	select seo_string($1.title);
$$ language sql;

create function plain_title(articles)
returns text as $$
	select strip_md($1.title);
$$ language sql;

create or replace function publish_collabs()
returns trigger
language plpgsql as $$ begin
	if tg_op = 'UPDATE' and new.online then
		update collabs set online = true where id in (select collab_id from collaborations where article_id = new.id and relation not in ('guest', 'producer', 'host'));
	end if;

	return new;
end $$;

create trigger publish_collabs
	after update on articles
	for each row
	execute procedure publish_collabs();
