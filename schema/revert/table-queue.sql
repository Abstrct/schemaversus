-- Revert schemaverse:table-queue from pg

BEGIN;

DROP TABLE round_queue;

COMMIT;
