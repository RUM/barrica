create table if not exists
  pages (
    id varchar(20) primary key
  , content text
  );

grant all on pages to rumadmin;

grant select on table pages to guest;
