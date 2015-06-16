-- Deploy schemaverse:data-maps to pg

BEGIN;

INSERT INTO map VALUES 

-- Map 1
--			X
--			X
--	1		X		2
--			X
--			X
--
--

	(1, 'Elephantopolis', 	POINT(10000,0), 500000000,2, 30, 0),
	(1, 'Blowfish Meadows', POINT(-10000,0), 500000000,2, 30, 1),	

	(1, 'Erelephant', POINT(0,20000), 	500000000,2, 30, NULL),	
	(1, 'Erelephant', POINT(0,10000), 	500000000,2, 30, NULL),	
	(1, 'Erelephant', POINT(0,0), 		500000000,2, 30, NULL),	
	(1, 'Erelephant', POINT(0,-10000), 	500000000,2, 30, NULL),
	(1, 'Erelephant', POINT(0,-20000), 	500000000,2, 30, NULL)

-- End Map 1	
	
	
;

COMMIT;
