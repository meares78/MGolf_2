/*
  # Fix Handicap Tee Name Mapping

  1. Changes
    - Correctly maps CSV tee names to database tee names
    - Maintains all handicap values
    - Ensures proper tee name matching across all courses

  2. Security
    - Uses existing RLS policies
    - Only admins can manage handicaps
*/

DO $$
DECLARE
    v_player_id uuid;
BEGIN
    -- First, clear existing handicaps to avoid any confusion
    DELETE FROM player_handicaps;

    -- Chris Meares
    SELECT id INTO v_player_id FROM players WHERE name = 'Chris Meares';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 4),
            (v_player_id, 'Palmer', 'Men', 1),
            (v_player_id, 'Palmer', 'Senior', 0),
            (v_player_id, 'Nicklaus', 'Tips', 5),
            (v_player_id, 'Nicklaus', 'Men', 2),
            (v_player_id, 'Nicklaus', 'Senior', 0),
            (v_player_id, 'Watson', 'Tips', 6),
            (v_player_id, 'Watson', 'Men', 1),
            (v_player_id, 'SouthernDunes', 'Tips', 6),
            (v_player_id, 'SouthernDunes', 'Men', 1),
            (v_player_id, 'SouthernDunes', 'Senior', 0);
    END IF;

    -- Dan Ayars
    SELECT id INTO v_player_id FROM players WHERE name = 'Dan Ayars';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', -1),
            (v_player_id, 'Palmer', 'Men', -4),
            (v_player_id, 'Palmer', 'Senior', -5),
            (v_player_id, 'Nicklaus', 'Tips', 0),
            (v_player_id, 'Nicklaus', 'Men', -3),
            (v_player_id, 'Nicklaus', 'Senior', -4),
            (v_player_id, 'Watson', 'Tips', 1),
            (v_player_id, 'Watson', 'Men', -3),
            (v_player_id, 'SouthernDunes', 'Tips', 1),
            (v_player_id, 'SouthernDunes', 'Men', -4),
            (v_player_id, 'SouthernDunes', 'Senior', -5);
    END IF;

    -- Dave Ayars
    SELECT id INTO v_player_id FROM players WHERE name = 'Dave Ayars';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 7),
            (v_player_id, 'Palmer', 'Men', 3),
            (v_player_id, 'Palmer', 'Senior', 2),
            (v_player_id, 'Nicklaus', 'Tips', 8),
            (v_player_id, 'Nicklaus', 'Men', 4),
            (v_player_id, 'Nicklaus', 'Senior', 2),
            (v_player_id, 'Watson', 'Tips', 8),
            (v_player_id, 'Watson', 'Men', 3),
            (v_player_id, 'SouthernDunes', 'Tips', 8),
            (v_player_id, 'SouthernDunes', 'Men', 3),
            (v_player_id, 'SouthernDunes', 'Senior', 2);
    END IF;

    -- Ed Kochanek
    SELECT id INTO v_player_id FROM players WHERE name = 'Ed Kochanek';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 5),
            (v_player_id, 'Palmer', 'Men', 2),
            (v_player_id, 'Palmer', 'Senior', 1),
            (v_player_id, 'Nicklaus', 'Tips', 7),
            (v_player_id, 'Nicklaus', 'Men', 3),
            (v_player_id, 'Nicklaus', 'Senior', 1),
            (v_player_id, 'Watson', 'Tips', 7),
            (v_player_id, 'Watson', 'Men', 2),
            (v_player_id, 'SouthernDunes', 'Tips', 7),
            (v_player_id, 'SouthernDunes', 'Men', 2),
            (v_player_id, 'SouthernDunes', 'Senior', 1);
    END IF;

    -- Gil Moniz
    SELECT id INTO v_player_id FROM players WHERE name = 'Gil Moniz';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 7),
            (v_player_id, 'Palmer', 'Men', 3),
            (v_player_id, 'Palmer', 'Senior', 2),
            (v_player_id, 'Nicklaus', 'Tips', 8),
            (v_player_id, 'Nicklaus', 'Men', 4),
            (v_player_id, 'Nicklaus', 'Senior', 2),
            (v_player_id, 'Watson', 'Tips', 8),
            (v_player_id, 'Watson', 'Men', 3),
            (v_player_id, 'SouthernDunes', 'Tips', 8),
            (v_player_id, 'SouthernDunes', 'Men', 3),
            (v_player_id, 'SouthernDunes', 'Senior', 2);
    END IF;

    -- Jimmy Gillespie
    SELECT id INTO v_player_id FROM players WHERE name = 'Jimmy Gillespie';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 2),
            (v_player_id, 'Palmer', 'Men', -2),
            (v_player_id, 'Palmer', 'Senior', -2),
            (v_player_id, 'Nicklaus', 'Tips', 3),
            (v_player_id, 'Nicklaus', 'Men', 0),
            (v_player_id, 'Nicklaus', 'Senior', -2),
            (v_player_id, 'Watson', 'Tips', 3),
            (v_player_id, 'Watson', 'Men', -1),
            (v_player_id, 'SouthernDunes', 'Tips', 3),
            (v_player_id, 'SouthernDunes', 'Men', -1),
            (v_player_id, 'SouthernDunes', 'Senior', -2);
    END IF;

    -- Joey Russo
    SELECT id INTO v_player_id FROM players WHERE name = 'Joey Russo';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', -1),
            (v_player_id, 'Palmer', 'Men', -4),
            (v_player_id, 'Palmer', 'Senior', -5),
            (v_player_id, 'Nicklaus', 'Tips', 0),
            (v_player_id, 'Nicklaus', 'Men', -3),
            (v_player_id, 'Nicklaus', 'Senior', -4),
            (v_player_id, 'Watson', 'Tips', 1),
            (v_player_id, 'Watson', 'Men', -3),
            (v_player_id, 'SouthernDunes', 'Tips', 1),
            (v_player_id, 'SouthernDunes', 'Men', -4),
            (v_player_id, 'SouthernDunes', 'Senior', -5);
    END IF;

    -- Joe Zulli
    SELECT id INTO v_player_id FROM players WHERE name = 'Joe Zulli';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 4),
            (v_player_id, 'Palmer', 'Men', 0),
            (v_player_id, 'Palmer', 'Senior', -1),
            (v_player_id, 'Nicklaus', 'Tips', 5),
            (v_player_id, 'Nicklaus', 'Men', 1),
            (v_player_id, 'Nicklaus', 'Senior', 0),
            (v_player_id, 'Watson', 'Tips', 5),
            (v_player_id, 'Watson', 'Men', 1),
            (v_player_id, 'SouthernDunes', 'Tips', 5),
            (v_player_id, 'SouthernDunes', 'Men', 0),
            (v_player_id, 'SouthernDunes', 'Senior', -1);
    END IF;

    -- John O'Brien
    SELECT id INTO v_player_id FROM players WHERE name = 'John O''Brien';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 9),
            (v_player_id, 'Palmer', 'Men', 5),
            (v_player_id, 'Palmer', 'Senior', 4),
            (v_player_id, 'Nicklaus', 'Tips', 10),
            (v_player_id, 'Nicklaus', 'Men', 7),
            (v_player_id, 'Nicklaus', 'Senior', 5),
            (v_player_id, 'Watson', 'Tips', 10),
            (v_player_id, 'Watson', 'Men', 6),
            (v_player_id, 'SouthernDunes', 'Tips', 11),
            (v_player_id, 'SouthernDunes', 'Men', 6),
            (v_player_id, 'SouthernDunes', 'Senior', 5);
    END IF;

    -- Rocky Dare
    SELECT id INTO v_player_id FROM players WHERE name = 'Rocky Dare';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 7),
            (v_player_id, 'Palmer', 'Men', 4),
            (v_player_id, 'Palmer', 'Senior', 3),
            (v_player_id, 'Nicklaus', 'Tips', 9),
            (v_player_id, 'Nicklaus', 'Men', 5),
            (v_player_id, 'Nicklaus', 'Senior', 3),
            (v_player_id, 'Watson', 'Tips', 9),
            (v_player_id, 'Watson', 'Men', 4),
            (v_player_id, 'SouthernDunes', 'Tips', 9),
            (v_player_id, 'SouthernDunes', 'Men', 4),
            (v_player_id, 'SouthernDunes', 'Senior', 3);
    END IF;

    -- Ryan Cass
    SELECT id INTO v_player_id FROM players WHERE name = 'Ryan Cass';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 1),
            (v_player_id, 'Palmer', 'Men', -2),
            (v_player_id, 'Palmer', 'Senior', -3),
            (v_player_id, 'Nicklaus', 'Tips', 3),
            (v_player_id, 'Nicklaus', 'Men', -1),
            (v_player_id, 'Nicklaus', 'Senior', -2),
            (v_player_id, 'Watson', 'Tips', 3),
            (v_player_id, 'Watson', 'Men', -1),
            (v_player_id, 'SouthernDunes', 'Tips', 3),
            (v_player_id, 'SouthernDunes', 'Men', -2),
            (v_player_id, 'SouthernDunes', 'Senior', -3);
    END IF;

    -- Tim Tullio
    SELECT id INTO v_player_id FROM players WHERE name = 'Tim Tullio';
    IF FOUND THEN
        INSERT INTO player_handicaps (player_id, course_name, tee_name, handicap)
        VALUES
            (v_player_id, 'Palmer', 'Tips', 6),
            (v_player_id, 'Palmer', 'Men', 2),
            (v_player_id, 'Palmer', 'Senior', 2),
            (v_player_id, 'Nicklaus', 'Tips', 7),
            (v_player_id, 'Nicklaus', 'Men', 4),
            (v_player_id, 'Nicklaus', 'Senior', 2),
            (v_player_id, 'Watson', 'Tips', 7),
            (v_player_id, 'Watson', 'Men', 3),
            (v_player_id, 'SouthernDunes', 'Tips', 8),
            (v_player_id, 'SouthernDunes', 'Men', 3),
            (v_player_id, 'SouthernDunes', 'Senior', 2);
    END IF;
END $$;