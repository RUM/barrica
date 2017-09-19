create type collaboration_types as enum ('author', 'co-author', 'translator', 'editor');

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
