-- Deploy schemaverse:table-queue to pg

BEGIN;

CREATE TABLE round_queue (
	id serial primary key,
	players integer[],
	map_id integer,
	timespan interval default '10 minutes'::interval
);

COMMIT;
