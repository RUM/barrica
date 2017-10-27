create table if not exists
  articles (
    id         uuid primary key
  , title      varchar(256) not null
  , subtitle   varchar(256)
  , file       varchar(50)
  , date       date
  , quote      text
  , content    text
  , cover      text
  , tags       jsonb default '[]'
  , starred    boolean default false
  , online     boolean default false
  , doc_only   boolean default false
  , release_id uuid references releases (id) on update cascade
  , metadata   jsonb default '{
    "section": 0,

    "references": [{
      "name": null
    , "url": null
    }]
    }'
  );

grant all on articles to rumadmin;

grant select on table articles to guest;

create function articles_with_tags($1 jsonb)
returns table(id uuid)
language plpgsql immutable as $$ begin
  return query
    select articles.id
      from articles
      where tags::jsonb ?| array(select jsonb_array_elements_text($1));
      -- where tags::jsonb ?& array(select jsonb_array_elements_text(tags_array));
end $$;

create function strip_tags()
returns trigger
language plpgsql as $$ begin
  new.tags = to_json(array(select lower(trim(json_array_elements_text(new.tags::json)))))::jsonb - '';

  return new;
end $$;

create trigger strip_tags
  before update on articles
  for each row
  execute procedure strip_tags();

create trigger insert_uuid
  before insert on articles
  for each row
  execute procedure insert_uuid();

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
    update collabs set online = true where id in (select collab_id from collaborations where article_id = new.id);
  end if;

  return new;
end $$;

create trigger publish_collabs
  after update on articles
  for each row
  execute procedure publish_collabs();
