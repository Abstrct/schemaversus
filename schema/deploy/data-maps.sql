-- Deploy schemaverse:data-maps to pg

BEGIN;

INSERT INTO maps VALUES 

-- Map 1
--			X
--			X
--	1		X		2
--			X
--			X
--
--

	(1, 'Elephantopolis', POINT(10000,0), 10000000,7, 30, 1),
	(1, 'Blowfish Meadows', POINT(-10000,0), 10000000,7, 30, 2),	

	(1, 'Erelephant', POINT(0,20000), 	10000000,7, 30, NULL),	
	(1, 'Erelephant', POINT(0,10000), 	10000000,7, 30, NULL),	
	(1, 'Erelephant', POINT(0,0), 		10000000,7, 30, NULL),	
	(1, 'Erelephant', POINT(0,-10000), 	10000000,7, 30, NULL),
	(1, 'Erelephant', POINT(0,-20000), 	10000000,7, 30, NULL)

-- End Map 1	
	
	;
);

COMMIT;
