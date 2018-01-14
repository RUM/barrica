create type collaboration_types as enum ('author', 'co-author', 'translator', 'editor', 'guest', 'producer', 'host');

create table if not exists
  collaborations (
    relation   collaboration_types
  , collab_id  uuid references collabs  (id) on update cascade
  , article_id uuid references articles (id) on update cascade
  , constraint collaboration_pkey primary key (collab_id, article_id)
  );

grant all on collaborations to rumadmin;

grant select on table collaborations to guest;

alter table collaborations
  drop constraint collaborations_article_id_fkey,
  add constraint collaborations_article_id_fkey
  foreign key (article_id) references articles(id)
  on delete cascade;

alter table collaborations
  drop constraint collaborations_collab_id_fkey,
  add constraint collaborations_collab_id_fkey
  foreign key (collab_id) references collabs(id)
  on delete cascade;

create view release_collabs as
  select
    release_id, releases.name as release_name,
    article_id, plain_title(articles) as title, articles.online as article_online,
    collab_id, name(collabs) as collab_name, collabs.online as collab_online,
    collaborations.relation from collabs
    join collaborations on collab_id = collabs.id
    join articles on articles.id = article_id
    join releases on release_id = releases.id;

grant select on table release_collabs to guest;
grant select on table release_collabs to rumadmin;
