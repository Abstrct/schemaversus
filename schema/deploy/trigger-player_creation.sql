-- Deploy trigger-player_creation
-- requires: table-player

BEGIN;


CREATE OR REPLACE FUNCTION player_creation()
  RETURNS trigger AS
$BODY$
DECLARE 
	new_planet RECORD;
BEGIN
	execute 'CREATE ROLE ' || NEW.username || ' WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE ENCRYPTED PASSWORD '''|| NEW.password ||'''  IN GROUP players'; 


	INSERT INTO player_overall_stats(player_id) VALUES (NEW.id);



RETURN NEW;
END
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100;


CREATE TRIGGER player_creation
  AFTER INSERT
  ON player
  FOR EACH ROW
  EXECUTE PROCEDURE player_creation();


COMMIT;
