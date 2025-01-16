-- First, clear all existing scores and results
DELETE FROM round_results;
DELETE FROM skins;
DELETE FROM twos;
DELETE FROM finalized_scores;
DELETE FROM scores;

-- Get the round ID for Monday, February 10
DO $$
DECLARE
    v_round_id uuid;
    v_auth_id uuid;
    v_player_handicap numeric;
    v_total_gross numeric;
    v_rocky_auth_id uuid;
BEGIN
    -- Get the round ID for Monday
    SELECT id INTO v_round_id 
    FROM rounds 
    WHERE external_id = 'mon-1';

    -- Get Rocky's auth_id
    SELECT auth_id INTO v_rocky_auth_id
    FROM players
    WHERE name = 'Rocky Dare';

    -- Update the round to use gold tees
    UPDATE rounds 
    SET tee_name = 'Tips',
        tee_color = 'Gold'
    WHERE id = v_round_id;

    -- For each player, insert their scores
    FOR v_auth_id IN 
        SELECT auth_id FROM players
    LOOP
        -- Get player's handicap for Nicklaus gold tees
        SELECT ph.handicap INTO v_player_handicap
        FROM player_handicaps ph
        JOIN players p ON p.id = ph.player_id
        WHERE p.auth_id = v_auth_id
        AND ph.course_name = 'Nicklaus'
        AND ph.tee_name = 'Tips-Gold';

        -- Insert scores for each hole
        INSERT INTO scores (round_id, auth_id, hole_number, strokes)
        SELECT 
            v_round_id,
            v_auth_id,
            hole_number,
            CASE 
                -- Special case: Rocky gets a 2 on hole 16 (par 3)
                WHEN v_auth_id = v_rocky_auth_id AND hole_number = 16 THEN 2
                -- Par 4s (holes 1,2,4,7,10,12,13,14,17)
                WHEN hole_number IN (1,2,4,7,10,12,13,14,17) THEN
                    CASE 
                        WHEN v_auth_id = v_rocky_auth_id THEN 4  -- Rocky plays par golf on par 4s
                        ELSE 4 + floor(random() * 2 + 1)  -- Others: 5 to 6
                    END
                -- Par 3s (holes 3,5,8,11,16)
                WHEN hole_number IN (3,5,8,11,16) THEN
                    CASE 
                        WHEN v_auth_id = v_rocky_auth_id THEN 
                            CASE 
                                WHEN hole_number = 16 THEN 2  -- Rocky's birdie on 16
                                ELSE 3  -- Par on other par 3s
                            END
                        ELSE 3 + floor(random() * 2 + 1)  -- Others: 4 to 5 (no 2s)
                    END
                -- Par 5s (holes 6,9,15,18)
                ELSE
                    CASE 
                        WHEN v_auth_id = v_rocky_auth_id THEN 5  -- Rocky plays par golf on par 5s
                        ELSE 5 + floor(random() * 2 + 1)  -- Others: 6 to 7
                    END
            END
        FROM generate_series(1, 18) hole_number;

        -- Calculate total gross score
        SELECT sum(strokes) INTO v_total_gross
        FROM scores
        WHERE round_id = v_round_id AND auth_id = v_auth_id;

        -- Insert finalized score
        INSERT INTO finalized_scores (
            round_id,
            auth_id,
            total_gross,
            total_net,
            course_handicap,
            finalized_at
        ) VALUES (
            v_round_id,
            v_auth_id,
            v_total_gross,
            v_total_gross - COALESCE(v_player_handicap, 0),
            COALESCE(v_player_handicap, 0),
            now()
        );
    END LOOP;
END $$;