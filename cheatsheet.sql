-- Schemaversus Cheat Sheet
-- Schemaversus.com
-- Scheaverse.com 
-- https://github.com/Abstrct/schemaversus

-- Create some ships on your home planet to mine some resources
INSERT INTO my_ships(name) SELECT 'Home Mining' FROM generate_series(0,10);


-- What planet to I own?
SELECT * FROM planets WHERE conqueror_id = GET_PLAYER_ID(SESSION_USER);

-- OK, mine that planet automatically by updating the state of those ships: 
-- UPDATE my_ships SET action='MINE', action_target_id=1 WHERE name = 'Home Mining';


-- Or, a slightly fancier way that includes the planet ID automatically 
UPDATE my_ships SET action='MINE', action_target_id=planets.id FROM planets WHERE planets.conqueror_id = GET_PLAYER_ID(SESSION_USER) AND my_ships.name = 'Home Mining';

-- Now that your sweet sweet resoruces are rolling in, lets convert the fuel to cash so we can build more
SELECT convert_resource('FUEL', fuel_reserve/2) FROM my_player;


-- Let's upgrade those ships to mine harder 
SELECT UPGRADE(id, 'PROSPECTING', 100) FROM my_ships WHERE name = 'Home Mining';


-- If you find you are out of funds, make sure you convert some fuel over to money again. You likely have lots of fuel!


-- Now lets try to get to the next planet over...

INSERT INTO my_ships(name) VALUES ('Explorer');

-- Which planet is closest?
-- (Scariest SQL yet D:  )
SELECT 
	my_ships.id 		as my_ship_id,
	my_ships.name 		as my_ship_name,
	planets.id 			as planet_id,
	planets.name 		as planet_name,
	planets.location 	as planet_location,
	my_ships.location <-> planets.location as planet_distance,
	get_player_username(conqueror_id) AS owner 
FROM my_ships, planets 
WHERE my_ships.name = 'Explorer'
ORDER BY my_ships.location <-> planets.location ASC;



-- Lets go thataway
UPDATE my_ships 
	SET 
		-- MOVE THIS WAY
		destination=POINT(0,0), 
		target_speed=max_speed,
		
		-- KEEP TRYING THIS UNTIL IT STARTS BEING SUCCESSFUL
		action='MINE',
		action_target_id=5 
	WHERE name = 'Explorer';



-- Thats probably going slow though! So upgrade that a bit too
SELECT 
	UPGRADE(id, 'MAX_SPEED', 500),
	UPGRADE(id, 'MAX_FUEL', 1300)
FROM my_ships
WHERE name = 'Explorer';



-- Lets set the new target_speed since our ship rocks so much
UPDATE my_ships 
	SET 
		-- MOVE THIS WAY
		destination=POINT(0,0), 
		target_speed=max_speed	
	WHERE name = 'Explorer';




-- rinse, lather, repeat
-- More ships! More upgrades! More universal domination

-- what the hell is actually going on?

-- humans
SELECT read_event(id) FROM my_events ORDER BY tic DESC LIMIT 100;

-- computars
SELECT * FROM my_events ORDER BY tic DESC LIMIT 100;
