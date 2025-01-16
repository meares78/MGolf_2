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
            ('Palmer', 'Tips-Black', 4),
            ('Palmer', 'Men-Gold', 1),
            ('Palmer', 'Men-Gold/Blue', 1),
            ('Palmer', 'Senior-Blue', 0),
            ('Nicklaus', 'Tips-Gold', 5),
            ('Nicklaus', 'Men-Gold/Blue', 4),
            ('Nicklaus', 'Men-Blue', 2),
            ('Nicklaus', 'Senior-White', 0),
            ('Watson', 'Tips-Black', 6),
            ('Watson', 'Men-Gold', 3),
            ('Watson', 'Men-Blue', 1),
            ('SouthernDunes', 'Tips-Black', 6),
            ('SouthernDunes', 'Men-Blue', 3),
            ('SouthernDunes', 'Men-White', 1)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Dan Ayars
    SELECT id INTO v_player_id FROM players WHERE name = 'Dan Ayars';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', -1),
            ('Palmer', 'Men-Gold', -3),
            ('Palmer', 'Men-Gold/Blue', -4),
            ('Palmer', 'Senior-Blue', -5),
            ('Nicklaus', 'Tips-Gold', 0),
            ('Nicklaus', 'Men-Gold/Blue', -1),
            ('Nicklaus', 'Men-Blue', -3),
            ('Nicklaus', 'Senior-White', -4),
            ('Watson', 'Tips-Black', 1),
            ('Watson', 'Men-Gold', -1),
            ('Watson', 'Men-Blue', -3),
            ('SouthernDunes', 'Tips-Black', 1),
            ('SouthernDunes', 'Men-Blue', -1),
            ('SouthernDunes', 'Men-White', -4)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Dave Ayars
    SELECT id INTO v_player_id FROM players WHERE name = 'Dave Ayars';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', 7),
            ('Palmer', 'Men-Gold', 4),
            ('Palmer', 'Men-Gold/Blue', 3),
            ('Palmer', 'Senior-Blue', 2),
            ('Nicklaus', 'Tips-Gold', 8),
            ('Nicklaus', 'Men-Gold/Blue', 6),
            ('Nicklaus', 'Men-Blue', 4),
            ('Nicklaus', 'Senior-White', 2),
            ('Watson', 'Tips-Black', 8),
            ('Watson', 'Men-Gold', 6),
            ('Watson', 'Men-Blue', 3),
            ('SouthernDunes', 'Tips-Black', 8),
            ('SouthernDunes', 'Men-Blue', 6),
            ('SouthernDunes', 'Men-White', 3)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Ed Kochanek
    SELECT id INTO v_player_id FROM players WHERE name = 'Ed Kochanek';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', 5),
            ('Palmer', 'Men-Gold', 3),
            ('Palmer', 'Men-Gold/Blue', 2),
            ('Palmer', 'Senior-Blue', 1),
            ('Nicklaus', 'Tips-Gold', 7),
            ('Nicklaus', 'Men-Gold/Blue', 5),
            ('Nicklaus', 'Men-Blue', 3),
            ('Nicklaus', 'Senior-White', 1),
            ('Watson', 'Tips-Black', 7),
            ('Watson', 'Men-Gold', 5),
            ('Watson', 'Men-Blue', 2),
            ('SouthernDunes', 'Tips-Black', 7),
            ('SouthernDunes', 'Men-Blue', 5),
            ('SouthernDunes', 'Men-White', 2)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Gil Moniz
    SELECT id INTO v_player_id FROM players WHERE name = 'Gil Moniz';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', 7),
            ('Palmer', 'Men-Gold', 4),
            ('Palmer', 'Men-Gold/Blue', 3),
            ('Palmer', 'Senior-Blue', 2),
            ('Nicklaus', 'Tips-Gold', 8),
            ('Nicklaus', 'Men-Gold/Blue', 6),
            ('Nicklaus', 'Men-Blue', 4),
            ('Nicklaus', 'Senior-White', 2),
            ('Watson', 'Tips-Black', 8),
            ('Watson', 'Men-Gold', 6),
            ('Watson', 'Men-Blue', 3),
            ('SouthernDunes', 'Tips-Black', 8),
            ('SouthernDunes', 'Men-Blue', 6),
            ('SouthernDunes', 'Men-White', 3)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Jimmy Gillespie
    SELECT id INTO v_player_id FROM players WHERE name = 'Jimmy Gillespie';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', 2),
            ('Palmer', 'Men-Gold', -1),
            ('Palmer', 'Men-Gold/Blue', -2),
            ('Palmer', 'Senior-Blue', -2),
            ('Nicklaus', 'Tips-Gold', 3),
            ('Nicklaus', 'Men-Gold/Blue', 1),
            ('Nicklaus', 'Men-Blue', 0),
            ('Nicklaus', 'Senior-White', -2),
            ('Watson', 'Tips-Black', 3),
            ('Watson', 'Men-Gold', 1),
            ('Watson', 'Men-Blue', -1),
            ('SouthernDunes', 'Tips-Black', 3),
            ('SouthernDunes', 'Men-Blue', 1),
            ('SouthernDunes', 'Men-White', -1)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Joey Russo
    SELECT id INTO v_player_id FROM players WHERE name = 'Joey Russo';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', -1),
            ('Palmer', 'Men-Gold', -3),
            ('Palmer', 'Men-Gold/Blue', -4),
            ('Palmer', 'Senior-Blue', -5),
            ('Nicklaus', 'Tips-Gold', 0),
            ('Nicklaus', 'Men-Gold/Blue', -1),
            ('Nicklaus', 'Men-Blue', -3),
            ('Nicklaus', 'Senior-White', -4),
            ('Watson', 'Tips-Black', 1),
            ('Watson', 'Men-Gold', -1),
            ('Watson', 'Men-Blue', -3),
            ('SouthernDunes', 'Tips-Black', 1),
            ('SouthernDunes', 'Men-Blue', -2),
            ('SouthernDunes', 'Men-White', -4)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Joe Zulli
    SELECT id INTO v_player_id FROM players WHERE name = 'Joe Zulli';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', 4),
            ('Palmer', 'Men-Gold', 1),
            ('Palmer', 'Men-Gold/Blue', 0),
            ('Palmer', 'Senior-Blue', -1),
            ('Nicklaus', 'Tips-Gold', 5),
            ('Nicklaus', 'Men-Gold/Blue', 3),
            ('Nicklaus', 'Men-Blue', 1),
            ('Nicklaus', 'Senior-White', 0),
            ('Watson', 'Tips-Black', 5),
            ('Watson', 'Men-Gold', 3),
            ('Watson', 'Men-Blue', 1),
            ('SouthernDunes', 'Tips-Black', 5),
            ('SouthernDunes', 'Men-Blue', 3),
            ('SouthernDunes', 'Men-White', 0)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- John O'Brien
    SELECT id INTO v_player_id FROM players WHERE name = 'John O''Brien';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', 9),
            ('Palmer', 'Men-Gold', 6),
            ('Palmer', 'Men-Gold/Blue', 5),
            ('Palmer', 'Senior-Blue', 4),
            ('Nicklaus', 'Tips-Gold', 10),
            ('Nicklaus', 'Men-Gold/Blue', 8),
            ('Nicklaus', 'Men-Blue', 7),
            ('Nicklaus', 'Senior-White', 5),
            ('Watson', 'Tips-Black', 10),
            ('Watson', 'Men-Gold', 8),
            ('Watson', 'Men-Blue', 6),
            ('SouthernDunes', 'Tips-Black', 11),
            ('SouthernDunes', 'Men-Blue', 8),
            ('SouthernDunes', 'Men-White', 6)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Rocky Dare
    SELECT id INTO v_player_id FROM players WHERE name = 'Rocky Dare';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', 7),
            ('Palmer', 'Men-Gold', 4),
            ('Palmer', 'Men-Gold/Blue', 4),
            ('Palmer', 'Senior-Blue', 3),
            ('Nicklaus', 'Tips-Gold', 9),
            ('Nicklaus', 'Men-Gold/Blue', 7),
            ('Nicklaus', 'Men-Blue', 5),
            ('Nicklaus', 'Senior-White', 3),
            ('Watson', 'Tips-Black', 9),
            ('Watson', 'Men-Gold', 6),
            ('Watson', 'Men-Blue', 4),
            ('SouthernDunes', 'Tips-Black', 9),
            ('SouthernDunes', 'Men-Blue', 7),
            ('SouthernDunes', 'Men-White', 4)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Ryan Cass
    SELECT id INTO v_player_id FROM players WHERE name = 'Ryan Cass';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', 1),
            ('Palmer', 'Men-Gold', -1),
            ('Palmer', 'Men-Gold/Blue', -2),
            ('Palmer', 'Senior-Blue', -3),
            ('Nicklaus', 'Tips-Gold', 3),
            ('Nicklaus', 'Men-Gold/Blue', 1),
            ('Nicklaus', 'Men-Blue', -1),
            ('Nicklaus', 'Senior-White', -2),
            ('Watson', 'Tips-Black', 3),
            ('Watson', 'Men-Gold', 1),
            ('Watson', 'Men-Blue', -1),
            ('SouthernDunes', 'Tips-Black', 3),
            ('SouthernDunes', 'Men-Blue', 1),
            ('SouthernDunes', 'Men-White', -2)
        ) AS t(course_name, tee_name, handicap);
    END IF;

    -- Tim Tullio
    SELECT id INTO v_player_id FROM players WHERE name = 'Tim Tullio';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        SELECT v_player_id, course_name, tee_name, handicap
        FROM (VALUES
            ('Palmer', 'Tips-Black', 6),
            ('Palmer', 'Men-Gold', 3),
            ('Palmer', 'Men-Gold/Blue', 2),
            ('Palmer', 'Senior-Blue', 2),
            ('Nicklaus', 'Tips-Gold', 7),
            ('Nicklaus', 'Men-Gold/Blue', 5),
            ('Nicklaus', 'Men-Blue', 4),
            ('Nicklaus', 'Senior-White', 2),
            ('Watson', 'Tips-Black', 7),
            ('Watson', 'Men-Gold', 5),
            ('Watson', 'Men-Blue', 3),
            ('SouthernDunes', 'Tips-Black', 8),
            ('SouthernDunes', 'Men-Blue', 5),
            ('SouthernDunes', 'Men-White', 3)
        ) AS t(course_name, tee_name, handicap);
    END IF;
END $$;