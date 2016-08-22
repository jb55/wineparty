

do $$
declare
  william_id bigint;
  vanessa_id bigint;
  anwar_id   bigint;
  talica_id  bigint;
  team_a bigint;
  team_b bigint;
  a_party_id bigint;
begin

  delete from user_team;
  delete from teams;
  delete from party;
  delete from users;
  delete from sessions;

  insert into party (name) values ('Rags to Riches')
    returning party_id into a_party_id;

  insert into teams (name, party_id) values ('Mossy Bread', a_party_id)
    returning team_id into team_a;

  insert into teams (name, party_id) values ('Grape Nation', a_party_id)
    returning team_id into team_b;

  insert into users (name) values ('Vanessa')
    returning user_id into vanessa_id;

  insert into users (name) values ('William')
    returning user_id into william_id;

  insert into users (name) values ('Talica')
    returning user_id into talica_id;

  insert into users (name) values ('Anwar')
    returning user_id into anwar_id;

  insert into user_team (user_id, team_id) values
    (talica_id,  team_b),
    (anwar_id,   team_b),
    (william_id, team_a),
    (vanessa_id, team_a);

  insert into sessions (session_id, user_id, team_id, party_id) values
    (1, william_id, team_a, a_party_id);

end$$
