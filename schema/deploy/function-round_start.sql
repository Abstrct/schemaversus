-- Deploy schemaverse:function-round_start to pg

BEGIN;



CREATE OR REPLACE FUNCTION round_start(queue_id INTEGER)
  RETURNS boolean AS
$BODY$
DECLARE
	new_planet record;
	trophies RECORD;
	players RECORD;
	p RECORD;
BEGIN

	IF NOT SESSION_USER = 'schemaverse' THEN
		RETURN 'f';
	END IF;	

	IF 	(GET_CHAR_VARIABLE('STATUS') != 'Waiting')
	THEN
		RETURN 'f';
	END IF;

    update fleet set runtime='0 minutes', enabled='f';
	UPDATE fleet SET last_script_update_tic=0;


	-- Disable old players, set all resources to zero
	
	-- Enable new players, give them actual resources

	-- prepare new stat records for relevant players
	
	-- Build the new map, assign start player positions
	

	

    
	PERFORM nextval('round_seq');
	PERFORM SET_CHAR_VARIABLE('STATUS','Running');

    RETURN 't';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


COMMIT;
