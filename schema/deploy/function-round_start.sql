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
	
	map_counter INTEGER;
	
	
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
	UPDATE player set balance=0, fuel_reserve=0, disabled='t' WHERE id <> 0;

	
	-- Enable new players, give them actual resources
	UPDATE player set disabled='f', balance=10000, fuel_reserve=100000 where id = any (select unnest(round_queue.players) from round_queue where round_queue.id = queue_id);

	
	-- Build the new map, assign start player positions
	INSERT INTO planet (id, name, mine_limit, difficulty, fuel, location, location_x, location_y, conqueror_id) 
		SELECT 
			extval('planet_id_seq'),
			map.name, 
			map.mine_limit, 
			map.difficulty, 
			map.fuel, 
			map.location, 
			map.location[0], 
			map.location[1], 
			case map.starting_player WHEN NULL THEN NULL ELSE (select player.id FROM player WHERE NOT disabled order by ID offset starting_player limit 1)  END	
		FROM map WHERE map.id = (select round_queue.id FROM round_queue WHERE id=queue_id);
	
	UPDATE variable SET char_value='now'::timestamp WHERE name='ROUND_START_DATE';
    
	PERFORM nextval('round_seq');

	-- prepare new stat records for relevant players	
	FOR players IN SELECT * from player WHERE ID <> 0 AND not disabled LOOP
		INSERT INTO player_round_stats(player_id, round_id) VALUES (players.id, (select last_value from round_seq));
	END LOOP;
	INSERT INTO round_stats(round_id) VALUES((SELECT last_value FROM round_seq));
	

	PERFORM SET_CHAR_VARIABLE('STATUS','Running');

    RETURN 't';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


COMMIT;
