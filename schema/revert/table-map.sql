-- Revert schemaverse:table-map from pg

BEGIN;

DROP TABLE map;

COMMIT;
