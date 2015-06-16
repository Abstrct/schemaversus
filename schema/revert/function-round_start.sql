-- Revert schemaverse:function-round_start from pg

BEGIN;

DROP FUNCTION round_start(integer);

COMMIT;
