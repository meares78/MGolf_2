-- First ensure we have a clean slate for handicaps
DELETE FROM player_handicaps;

DO $$
DECLARE
    v_player_id uuid;
BEGIN
    -- Chris Meares
    SELECT id INTO v_player_id FROM players WHERE name = 'Chris Meares';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', 4),
            ('Palmer', 'Gold', 1),
            ('Palmer', 'Gold/Blue', 1),
            ('Palmer', 'Senior', 0),
            ('Nicklaus', 'Tips', 5),
            ('Nicklaus', 'Gold/Blue', 4),
            ('Nicklaus', 'Blue', 2),
            ('Nicklaus', 'Senior', 0),
            ('Watson', 'Tips', 6),
            ('Watson', 'Gold', 3),
            ('Watson', 'Blue', 1),
            ('SouthernDunes', 'Tips', 6),
            ('SouthernDunes', 'Blue', 3),
            ('SouthernDunes', 'White', 1),
            ('SouthernDunes', 'Senior', 0)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Dan Ayars
    SELECT id INTO v_player_id FROM players WHERE name = 'Dan Ayars';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', -1),
            ('Palmer', 'Gold', -3),
            ('Palmer', 'Gold/Blue', -4),
            ('Palmer', 'Senior', -5),
            ('Nicklaus', 'Tips', 0),
            ('Nicklaus', 'Gold/Blue', -1),
            ('Nicklaus', 'Blue', -3),
            ('Nicklaus', 'Senior', -4),
            ('Watson', 'Tips', 1),
            ('Watson', 'Gold', -1),
            ('Watson', 'Blue', -3),
            ('SouthernDunes', 'Tips', 1),
            ('SouthernDunes', 'Blue', -1),
            ('SouthernDunes', 'White', -4),
            ('SouthernDunes', 'Senior', -5)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Dave Ayars
    SELECT id INTO v_player_id FROM players WHERE name = 'Dave Ayars';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', 7),
            ('Palmer', 'Gold', 4),
            ('Palmer', 'Gold/Blue', 3),
            ('Palmer', 'Senior', 2),
            ('Nicklaus', 'Tips', 8),
            ('Nicklaus', 'Gold/Blue', 6),
            ('Nicklaus', 'Blue', 4),
            ('Nicklaus', 'Senior', 2),
            ('Watson', 'Tips', 8),
            ('Watson', 'Gold', 6),
            ('Watson', 'Blue', 3),
            ('SouthernDunes', 'Tips', 8),
            ('SouthernDunes', 'Blue', 6),
            ('SouthernDunes', 'White', 3),
            ('SouthernDunes', 'Senior', 2)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Ed Kochanek
    SELECT id INTO v_player_id FROM players WHERE name = 'Ed Kochanek';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', 5),
            ('Palmer', 'Gold', 3),
            ('Palmer', 'Gold/Blue', 2),
            ('Palmer', 'Senior', 1),
            ('Nicklaus', 'Tips', 7),
            ('Nicklaus', 'Gold/Blue', 5),
            ('Nicklaus', 'Blue', 3),
            ('Nicklaus', 'Senior', 1),
            ('Watson', 'Tips', 7),
            ('Watson', 'Gold', 5),
            ('Watson', 'Blue', 2),
            ('SouthernDunes', 'Tips', 7),
            ('SouthernDunes', 'Blue', 5),
            ('SouthernDunes', 'White', 2),
            ('SouthernDunes', 'Senior', 1)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Gil Moniz
    SELECT id INTO v_player_id FROM players WHERE name = 'Gil Moniz';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', 7),
            ('Palmer', 'Gold', 4),
            ('Palmer', 'Gold/Blue', 3),
            ('Palmer', 'Senior', 2),
            ('Nicklaus', 'Tips', 8),
            ('Nicklaus', 'Gold/Blue', 6),
            ('Nicklaus', 'Blue', 4),
            ('Nicklaus', 'Senior', 2),
            ('Watson', 'Tips', 8),
            ('Watson', 'Gold', 6),
            ('Watson', 'Blue', 3),
            ('SouthernDunes', 'Tips', 8),
            ('SouthernDunes', 'Blue', 6),
            ('SouthernDunes', 'White', 3),
            ('SouthernDunes', 'Senior', 2)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Jimmy Gillespie
    SELECT id INTO v_player_id FROM players WHERE name = 'Jimmy Gillespie';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', 2),
            ('Palmer', 'Gold', -1),
            ('Palmer', 'Gold/Blue', -2),
            ('Palmer', 'Senior', -2),
            ('Nicklaus', 'Tips', 3),
            ('Nicklaus', 'Gold/Blue', 1),
            ('Nicklaus', 'Blue', 0),
            ('Nicklaus', 'Senior', -2),
            ('Watson', 'Tips', 3),
            ('Watson', 'Gold', 1),
            ('Watson', 'Blue', -1),
            ('SouthernDunes', 'Tips', 3),
            ('SouthernDunes', 'Blue', 1),
            ('SouthernDunes', 'White', -1),
            ('SouthernDunes', 'Senior', -2)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Joey Russo
    SELECT id INTO v_player_id FROM players WHERE name = 'Joey Russo';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', -1),
            ('Palmer', 'Gold', -3),
            ('Palmer', 'Gold/Blue', -4),
            ('Palmer', 'Senior', -5),
            ('Nicklaus', 'Tips', 0),
            ('Nicklaus', 'Gold/Blue', -1),
            ('Nicklaus', 'Blue', -3),
            ('Nicklaus', 'Senior', -4),
            ('Watson', 'Tips', 1),
            ('Watson', 'Gold', -1),
            ('Watson', 'Blue', -3),
            ('SouthernDunes', 'Tips', 1),
            ('SouthernDunes', 'Blue', -2),
            ('SouthernDunes', 'White', -4),
            ('SouthernDunes', 'Senior', -5)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Joe Zulli
    SELECT id INTO v_player_id FROM players WHERE name = 'Joe Zulli';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', 4),
            ('Palmer', 'Gold', 1),
            ('Palmer', 'Gold/Blue', 0),
            ('Palmer', 'Senior', -1),
            ('Nicklaus', 'Tips', 5),
            ('Nicklaus', 'Gold/Blue', 3),
            ('Nicklaus', 'Blue', 1),
            ('Nicklaus', 'Senior', 0),
            ('Watson', 'Tips', 5),
            ('Watson', 'Gold', 3),
            ('Watson', 'Blue', 1),
            ('SouthernDunes', 'Tips', 5),
            ('SouthernDunes', 'Blue', 3),
            ('SouthernDunes', 'White', 0),
            ('SouthernDunes', 'Senior', -1)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- John O'Brien
    SELECT id INTO v_player_id FROM players WHERE name = 'John O''Brien';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', 9),
            ('Palmer', 'Gold', 6),
            ('Palmer', 'Gold/Blue', 5),
            ('Palmer', 'Senior', 4),
            ('Nicklaus', 'Tips', 10),
            ('Nicklaus', 'Gold/Blue', 8),
            ('Nicklaus', 'Blue', 7),
            ('Nicklaus', 'Senior', 5),
            ('Watson', 'Tips', 10),
            ('Watson', 'Gold', 8),
            ('Watson', 'Blue', 6),
            ('SouthernDunes', 'Tips', 11),
            ('SouthernDunes', 'Blue', 8),
            ('SouthernDunes', 'White', 6),
            ('SouthernDunes', 'Senior', 5)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Rocky Dare
    SELECT id INTO v_player_id FROM players WHERE name = 'Rocky Dare';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', 7),
            ('Palmer', 'Gold', 4),
            ('Palmer', 'Gold/Blue', 4),
            ('Palmer', 'Senior', 3),
            ('Nicklaus', 'Tips', 9),
            ('Nicklaus', 'Gold/Blue', 7),
            ('Nicklaus', 'Blue', 5),
            ('Nicklaus', 'Senior', 3),
            ('Watson', 'Tips', 9),
            ('Watson', 'Gold', 6),
            ('Watson', 'Blue', 4),
            ('SouthernDunes', 'Tips', 9),
            ('SouthernDunes', 'Blue', 7),
            ('SouthernDunes', 'White', 4),
            ('SouthernDunes', 'Senior', 3)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Ryan Cass
    SELECT id INTO v_player_id FROM players WHERE name = 'Ryan Cass';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', 1),
            ('Palmer', 'Gold', -1),
            ('Palmer', 'Gold/Blue', -2),
            ('Palmer', 'Senior', -3),
            ('Nicklaus', 'Tips', 3),
            ('Nicklaus', 'Gold/Blue', 1),
            ('Nicklaus', 'Blue', -1),
            ('Nicklaus', 'Senior', -2),
            ('Watson', 'Tips', 3),
            ('Watson', 'Gold', 1),
            ('Watson', 'Blue', -1),
            ('SouthernDunes', 'Tips', 3),
            ('SouthernDunes', 'Blue', 1),
            ('SouthernDunes', 'White', -2),
            ('SouthernDunes', 'Senior', -3)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Tim Tullio
    SELECT id INTO v_player_id FROM players WHERE name = 'Tim Tullio';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips', 6),
            ('Palmer', 'Gold', 3),
            ('Palmer', 'Gold/Blue', 2),
            ('Palmer', 'Senior', 2),
            ('Nicklaus', 'Tips', 7),
            ('Nicklaus', 'Gold/Blue', 5),
            ('Nicklaus', 'Blue', 4),
            ('Nicklaus', 'Senior', 2),
            ('Watson', 'Tips', 7),
            ('Watson', 'Gold', 5),
            ('Watson', 'Blue', 3),
            ('SouthernDunes', 'Tips', 8),
            ('SouthernDunes', 'Blue', 5),
            ('SouthernDunes', 'White', 3),
            ('SouthernDunes', 'Senior', 2)
        ) AS t(course_name, tee_name, handicap);
    END IF;
END $$;