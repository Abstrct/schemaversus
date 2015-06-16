-- Deploy schemaverse:table-map to pg

BEGIN;

create table map (
	id integer,
	name character varying,
	location point,
	fuel integer,
	difficulty integer,
	mine_limit integer,
	starting_player integer
);

COMMIT;
