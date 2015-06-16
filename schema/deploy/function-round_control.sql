-- Deploy function-round_control

BEGIN;


CREATE OR REPLACE FUNCTION round_control()
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

	IF 	(GET_CHAR_VARIABLE('STATUS') = 'Running')
		AND (GET_CHAR_VARIABLE('ROUND_START_DATE')::timestamp + GET_CHAR_VARIABLE('ROUND_LENGTH')::interval > 'now'::timestamp )
	THEN
		RETURN 'f';
	END IF;


	UPDATE round_stats SET
        	avg_damage_taken = current_round_stats.avg_damage_taken,
                avg_damage_done = current_round_stats.avg_damage_done,
                avg_planets_conquered = current_round_stats.avg_planets_conquered,
                avg_planets_lost = current_round_stats.avg_planets_lost,
                avg_ships_built = current_round_stats.avg_ships_built,
                avg_ships_lost = current_round_stats.avg_ships_lost,
                avg_ship_upgrades =current_round_stats.avg_ship_upgrades,
                avg_fuel_mined = current_round_stats.avg_fuel_mined
        FROM current_round_stats
        WHERE round_stats.round_id=(SELECT last_value FROM round_seq);

	FOR players IN SELECT * FROM player LOOP
		UPDATE player_round_stats SET 
			damage_taken = least(2147483647, current_player_stats.damage_taken),
			damage_done = least(2147483647,current_player_stats.damage_done),
			planets_conquered = least(32767,current_player_stats.planets_conquered),
			planets_lost = least(32767,current_player_stats.planets_lost),
			ships_built = least(32767,current_player_stats.ships_built),
			ships_lost = least(32767,current_player_stats.ships_lost),
			ship_upgrades =least(2147483647,current_player_stats.ship_upgrades),
			fuel_mined = current_player_stats.fuel_mined,
			last_updated=NOW()
		FROM current_player_stats
		WHERE player_round_stats.player_id=players.id AND current_player_stats.player_id=players.id AND player_round_stats.round_id=(select last_value from round_seq);

		UPDATE player_overall_stats SET 
			damage_taken = player_overall_stats.damage_taken + player_round_stats.damage_taken,
			damage_done = player_overall_stats.damage_done + player_round_stats.damage_done,
			planets_conquered = player_overall_stats.planets_conquered + player_round_stats.planets_conquered,
			planets_lost = player_overall_stats.planets_lost + player_round_stats.planets_lost,
			ships_built = player_overall_stats.ships_built +player_round_stats.ships_built,
			ships_lost = player_overall_stats.ships_lost + player_round_stats.ships_lost,
			ship_upgrades = player_overall_stats.ship_upgrades + player_round_stats.ship_upgrades,
			fuel_mined = player_overall_stats.fuel_mined + player_round_stats.fuel_mined
		FROM player_round_stats
		WHERE player_overall_stats.player_id=player_round_stats.player_id 
			and player_overall_stats.player_id=players.id and player_round_stats.round_id=(select last_value from round_seq);
	END LOOP;


	FOR trophies IN SELECT id FROM trophy WHERE approved='t' ORDER by run_order ASC LOOP
		EXECUTE 'INSERT INTO player_trophy SELECT * FROM trophy_script_' || trophies.id ||'((SELECT last_value FROM round_seq)::integer);';
	END LOOP;

	alter table planet disable trigger all;
	alter table fleet disable trigger all;
	alter table planet_miners disable trigger all;
	alter table ship_flight_recorder disable trigger all;
	alter table ship_control disable trigger all;
	alter table ship disable trigger all;
	alter table event disable trigger all;

	--Deactive all fleets
        update fleet set runtime='0 minutes', enabled='f';

	--add archives of stats and events
	CREATE TEMP TABLE tmp_current_round_archive AS SELECT (SELECT last_value FROM round_seq), event.* FROM event;
	EXECUTE 'COPY tmp_current_round_archive TO ''/hell/schemaversus_round_' || (SELECT last_value FROM round_seq) || '.csv''  WITH DELIMITER ''|''';

	--Delete everything else
        DELETE FROM planet_miners;
        DELETE FROM ship_flight_recorder;
        DELETE FROM ship_control;
        DELETE FROM ship;
        DELETE FROM event;
        DELETE from planet;

	UPDATE fleet SET last_script_update_tic=0;

    alter sequence event_id_seq restart with 1;
    alter sequence ship_id_seq restart with 1;
    alter sequence tic_seq restart with 1;
	alter sequence planet_id_seq restart with 1;
	
	


	--PERFORM nextval('round_seq');
	PERFORM SET_CHAR_VARIABLE('STATUS','Waiting');

    RETURN 't';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMIT;
