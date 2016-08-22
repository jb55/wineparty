drop table if exists party cascade;
create table party
(
  party_id bigserial primary key,
  name text not null check (length(name) > 4)
);


drop table if exists users cascade;
create table users
(
  user_id bigserial primary key,
  name text not null
);


drop table if exists teams cascade;
create table teams
(
  team_id bigserial primary key,
  party_id bigint references party (party_id),
  name text not null
);


drop table if exists sessions;
create table sessions
(
  session_id bigserial primary key,
  user_id bigint not null references users (user_id),
  party_id bigint references party (party_id),
  team_id bigint references teams (team_id)
);


drop table if exists user_team cascade;
create table user_team
(
user_team_id bigserial primary key,
user_id bigint not null references users (user_id),
team_id bigint not null references teams (team_id)
);


drop view if exists user_teams;
create view user_teams as
  select u.name as user_name,
  t.name as team_name,
  u.user_id,
  t.team_id,
  t.party_id,
  ut.user_team_id as user_team_id
  from user_team as ut
  inner join users as u on u.user_id = ut.user_id
  inner join teams as t on t.team_id = ut.team_id;


-- create or replace function session(int) returns json

create or replace function get_session(_session_id int) returns json
as $$
  select row_to_json(t)
  from (
    select
      (
        select row_to_json(d)
        from (
          select * from party
          where party_id=sessions.party_id
        ) d
      ) as party,
      (
        select row_to_json(d)
        from (
          select * from teams
          where team_id=sessions.team_id
        ) d
      ) as team,
      (
        select row_to_json(d)
        from (
          select * from users
          where user_id=sessions.user_id
        ) d
      ) as user
    from sessions
    where session_id=$1
  ) t;
$$
language sql;
