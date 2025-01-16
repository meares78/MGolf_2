/*
  # Import Player Handicap Data

  1. Changes
    - Import handicap data for all players and course/tee combinations
    - Uses a distinct variable name to avoid column ambiguity
    - Handles gold/blue tees separately from regular tees
    - Maintains data integrity with proper player references

  2. Security
    - Uses existing RLS policies
    - Only admins can manage handicaps
*/

DO $$
DECLARE
    v_player_id uuid;
BEGIN
    -- Chris Meares
    SELECT id INTO v_player_id FROM players WHERE name = 'Chris Meares';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 4),
            (v_player_id, 'Palmer', 'Gold', 1),
            (v_player_id, 'Palmer', 'Gold/Blue', 1),
            (v_player_id, 'Palmer', 'Senior', 0),
            (v_player_id, 'Nicklaus', 'Tips', 5),
            (v_player_id, 'Nicklaus', 'Gold/Blue', 4),
            (v_player_id, 'Nicklaus', 'Blue', 2),
            (v_player_id, 'Nicklaus', 'Senior', 0),
            (v_player_id, 'Watson', 'Tips', 6),
            (v_player_id, 'Watson', 'Gold', 3),
            (v_player_id, 'Watson', 'Blue', 1),
            (v_player_id, 'SouthernDunes', 'Tips', 6),
            (v_player_id, 'SouthernDunes', 'Blue', 3),
            (v_player_id, 'SouthernDunes', 'White', 1),
            (v_player_id, 'SouthernDunes', 'Senior', 0)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- Dan Ayars
    SELECT id INTO v_player_id FROM players WHERE name = 'Dan Ayars';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', -1),
            (v_player_id, 'Palmer', 'Gold', -3),
            (v_player_id, 'Palmer', 'Gold/Blue', -4),
            (v_player_id, 'Palmer', 'Senior', -5),
            (v_player_id, 'Nicklaus', 'Tips', 0),
            (v_player_id, 'Nicklaus', 'Gold/Blue', -1),
            (v_player_id, 'Nicklaus', 'Blue', -3),
            (v_player_id, 'Nicklaus', 'Senior', -4),
            (v_player_id, 'Watson', 'Tips', 1),
            (v_player_id, 'Watson', 'Gold', -1),
            (v_player_id, 'Watson', 'Blue', -3),
            (v_player_id, 'SouthernDunes', 'Tips', 1),
            (v_player_id, 'SouthernDunes', 'Blue', -1),
            (v_player_id, 'SouthernDunes', 'White', -4),
            (v_player_id, 'SouthernDunes', 'Senior', -5)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- Dave Ayars
    SELECT id INTO v_player_id FROM players WHERE name = 'Dave Ayars';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 7),
            (v_player_id, 'Palmer', 'Gold', 4),
            (v_player_id, 'Palmer', 'Gold/Blue', 3),
            (v_player_id, 'Palmer', 'Senior', 2),
            (v_player_id, 'Nicklaus', 'Tips', 8),
            (v_player_id, 'Nicklaus', 'Gold/Blue', 6),
            (v_player_id, 'Nicklaus', 'Blue', 4),
            (v_player_id, 'Nicklaus', 'Senior', 2),
            (v_player_id, 'Watson', 'Tips', 8),
            (v_player_id, 'Watson', 'Gold', 6),
            (v_player_id, 'Watson', 'Blue', 3),
            (v_player_id, 'SouthernDunes', 'Tips', 8),
            (v_player_id, 'SouthernDunes', 'Blue', 6),
            (v_player_id, 'SouthernDunes', 'White', 3),
            (v_player_id, 'SouthernDunes', 'Senior', 2)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- Ed Kochanek
    SELECT id INTO v_player_id FROM players WHERE name = 'Ed Kochanek';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 5),
            (v_player_id, 'Palmer', 'Gold', 3),
            (v_player_id, 'Palmer', 'Gold/Blue', 2),
            (v_player_id, 'Palmer', 'Senior', 1),
            (v_player_id, 'Nicklaus', 'Tips', 7),
            (v_player_id, 'Nicklaus', 'Gold/Blue', 5),
            (v_player_id, 'Nicklaus', 'Blue', 3),
            (v_player_id, 'Nicklaus', 'Senior', 1),
            (v_player_id, 'Watson', 'Tips', 7),
            (v_player_id, 'Watson', 'Gold', 5),
            (v_player_id, 'Watson', 'Blue', 2),
            (v_player_id, 'SouthernDunes', 'Tips', 7),
            (v_player_id, 'SouthernDunes', 'Blue', 5),
            (v_player_id, 'SouthernDunes', 'White', 2),
            (v_player_id, 'SouthernDunes', 'Senior', 1)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- Gil Moniz
    SELECT id INTO v_player_id FROM players WHERE name = 'Gil Moniz';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 7),
            (v_player_id, 'Palmer', 'Gold', 4),
            (v_player_id, 'Palmer', 'Gold/Blue', 3),
            (v_player_id, 'Palmer', 'Senior', 2),
            (v_player_id, 'Nicklaus', 'Tips', 8),
            (v_player_id, 'Nicklaus', 'Gold/Blue', 6),
            (v_player_id, 'Nicklaus', 'Blue', 4),
            (v_player_id, 'Nicklaus', 'Senior', 2),
            (v_player_id, 'Watson', 'Tips', 8),
            (v_player_id, 'Watson', 'Gold', 6),
            (v_player_id, 'Watson', 'Blue', 3),
            (v_player_id, 'SouthernDunes', 'Tips', 8),
            (v_player_id, 'SouthernDunes', 'Blue', 6),
            (v_player_id, 'SouthernDunes', 'White', 3),
            (v_player_id, 'SouthernDunes', 'Senior', 2)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- Jimmy Gillespie
    SELECT id INTO v_player_id FROM players WHERE name = 'Jimmy Gillespie';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 2),
            (v_player_id, 'Palmer', 'Gold', -1),
            (v_player_id, 'Palmer', 'Gold/Blue', -2),
            (v_player_id, 'Palmer', 'Senior', -2),
            (v_player_id, 'Nicklaus', 'Tips', 3),
            (v_player_id, 'Nicklaus', 'Gold/Blue', 1),
            (v_player_id, 'Nicklaus', 'Blue', 0),
            (v_player_id, 'Nicklaus', 'Senior', -2),
            (v_player_id, 'Watson', 'Tips', 3),
            (v_player_id, 'Watson', 'Gold', 1),
            (v_player_id, 'Watson', 'Blue', -1),
            (v_player_id, 'SouthernDunes', 'Tips', 3),
            (v_player_id, 'SouthernDunes', 'Blue', 1),
            (v_player_id, 'SouthernDunes', 'White', -1),
            (v_player_id, 'SouthernDunes', 'Senior', -2)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- Joey Russo
    SELECT id INTO v_player_id FROM players WHERE name = 'Joey Russo';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', -1),
            (v_player_id, 'Palmer', 'Gold', -3),
            (v_player_id, 'Palmer', 'Gold/Blue', -4),
            (v_player_id, 'Palmer', 'Senior', -5),
            (v_player_id, 'Nicklaus', 'Tips', 0),
            (v_player_id, 'Nicklaus', 'Gold/Blue', -1),
            (v_player_id, 'Nicklaus', 'Blue', -3),
            (v_player_id, 'Nicklaus', 'Senior', -4),
            (v_player_id, 'Watson', 'Tips', 1),
            (v_player_id, 'Watson', 'Gold', -1),
            (v_player_id, 'Watson', 'Blue', -3),
            (v_player_id, 'SouthernDunes', 'Tips', 1),
            (v_player_id, 'SouthernDunes', 'Blue', -2),
            (v_player_id, 'SouthernDunes', 'White', -4),
            (v_player_id, 'SouthernDunes', 'Senior', -5)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- Joe Zulli
    SELECT id INTO v_player_id FROM players WHERE name = 'Joe Zulli';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 4),
            (v_player_id, 'Palmer', 'Gold', 1),
            (v_player_id, 'Palmer', 'Gold/Blue', 0),
            (v_player_id, 'Palmer', 'Senior', -1),
            (v_player_id, 'Nicklaus', 'Tips', 5),
            (v_player_id, 'Nicklaus', 'Gold/Blue', 3),
            (v_player_id, 'Nicklaus', 'Blue', 1),
            (v_player_id, 'Nicklaus', 'Senior', 0),
            (v_player_id, 'Watson', 'Tips', 5),
            (v_player_id, 'Watson', 'Gold', 3),
            (v_player_id, 'Watson', 'Blue', 1),
            (v_player_id, 'SouthernDunes', 'Tips', 5),
            (v_player_id, 'SouthernDunes', 'Blue', 3),
            (v_player_id, 'SouthernDunes', 'White', 0),
            (v_player_id, 'SouthernDunes', 'Senior', -1)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- John O'Brien
    SELECT id INTO v_player_id FROM players WHERE name = 'John O''Brien';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 9),
            (v_player_id, 'Palmer', 'Gold', 6),
            (v_player_id, 'Palmer', 'Gold/Blue', 5),
            (v_player_id, 'Palmer', 'Senior', 4),
            (v_player_id, 'Nicklaus', 'Tips', 10),
            (v_player_id, 'Nicklaus', 'Gold/Blue', 8),
            (v_player_id, 'Nicklaus', 'Blue', 7),
            (v_player_id, 'Nicklaus', 'Senior', 5),
            (v_player_id, 'Watson', 'Tips', 10),
            (v_player_id, 'Watson', 'Gold', 8),
            (v_player_id, 'Watson', 'Blue', 6),
            (v_player_id, 'SouthernDunes', 'Tips', 11),
            (v_player_id, 'SouthernDunes', 'Blue', 8),
            (v_player_id, 'SouthernDunes', 'White', 6),
            (v_player_id, 'SouthernDunes', 'Senior', 5)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- Rocky Dare
    SELECT id INTO v_player_id FROM players WHERE name = 'Rocky Dare';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 7),
            (v_player_id, 'Palmer', 'Gold', 4),
            (v_player_id, 'Palmer', 'Gold/Blue', 4),
            (v_player_id, 'Palmer', 'Senior', 3),
            (v_player_id, 'Nicklaus', 'Tips', 9),
            (v_player_id, 'Nicklaus', 'Gold/Blue', 7),
            (v_player_id, 'Nicklaus', 'Blue', 5),
            (v_player_id, 'Nicklaus', 'Senior', 3),
            (v_player_id, 'Watson', 'Tips', 9),
            (v_player_id, 'Watson', 'Gold', 6),
            (v_player_id, 'Watson', 'Blue', 4),
            (v_player_id, 'SouthernDunes', 'Tips', 9),
            (v_player_id, 'SouthernDunes', 'Blue', 7),
            (v_player_id, 'SouthernDunes', 'White', 4),
            (v_player_id, 'SouthernDunes', 'Senior', 3)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- Ryan Cass
    SELECT id INTO v_player_id FROM players WHERE name = 'Ryan Cass';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 1),
            (v_player_id, 'Palmer', 'Gold', -1),
            (v_player_id, 'Palmer', 'Gold/Blue', -2),
            (v_player_id, 'Palmer', 'Senior', -3),
            (v_player_id, 'Nicklaus', 'Tips', 3),
            (v_player_id, 'Nicklaus', 'Gold/Blue', 1),
            (v_player_id, 'Nicklaus', 'Blue', -1),
            (v_player_id, 'Nicklaus', 'Senior', -2),
            (v_player_id, 'Watson', 'Tips', 3),
            (v_player_id, 'Watson', 'Gold', 1),
            (v_player_id, 'Watson', 'Blue', -1),
            (v_player_id, 'SouthernDunes', 'Tips', 3),
            (v_player_id, 'SouthernDunes', 'Blue', 1),
            (v_player_id, 'SouthernDunes', 'White', -2),
            (v_player_id, 'SouthernDunes', 'Senior', -3)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;

    -- Tim Tullio
    SELECT id INTO v_player_id FROM players WHERE name = 'Tim Tullio';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 6),
            (v_player_id, 'Palmer', 'Gold', 3),
            (v_player_id, 'Palmer', 'Gold/Blue', 2),
            (v_player_id, 'Palmer', 'Senior', 2),
            (v_player_id, 'Nicklaus', 'Tips', 7),
            (v_player_id, 'Nicklaus', 'Gold/Blue', 5),
            (v_player_id, 'Nicklaus', 'Blue', 4),
            (v_player_id, 'Nicklaus', 'Senior', 2),
            (v_player_id, 'Watson', 'Tips', 7),
            (v_player_id, 'Watson', 'Gold', 5),
            (v_player_id, 'Watson', 'Blue', 3),
            (v_player_id, 'SouthernDunes', 'Tips', 8),
            (v_player_id, 'SouthernDunes', 'Blue', 5),
            (v_player_id, 'SouthernDunes', 'White', 3),
            (v_player_id, 'SouthernDunes', 'Senior', 2)
        ON CONFLICT (player_id, course_name, tee_name) 
        DO UPDATE SET handicap = EXCLUDED.handicap;
    END IF;
END $$;