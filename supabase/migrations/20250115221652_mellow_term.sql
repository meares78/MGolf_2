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
BEGIN
    -- Get the round ID for Monday
    SELECT id INTO v_round_id 
    FROM rounds 
    WHERE external_id = 'mon-1';

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
                -- Par 4s
                WHEN hole_number IN (1,2,4,7,10,12,13,14,17) THEN
                    4 + (random() * 2)::integer - 1  -- 3 to 5
                -- Par 3s
                WHEN hole_number IN (3,5,8,11,16) THEN
                    3 + (random() * 2)::integer - 1  -- 2 to 4
                -- Par 5s
                ELSE
                    5 + (random() * 2)::integer - 1  -- 4 to 6
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