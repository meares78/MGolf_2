-- Calculate and store net scores for the first round
DO $$
DECLARE
    v_round_id uuid;
    v_player record;
    v_course_name text;
    v_tee_name text;
    v_tee_color text;
    v_handicap numeric;
    v_hole_handicaps integer[];
BEGIN
    -- Get the round ID and course info for Monday's round
    SELECT id, course_name, tee_name, tee_color INTO v_round_id, v_course_name, v_tee_name, v_tee_color
    FROM rounds 
    WHERE external_id = 'mon-1';

    -- Get the hole handicaps for Nicklaus course
    v_hole_handicaps := ARRAY[17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16];

    -- Process each player's scores
    FOR v_player IN 
        SELECT DISTINCT s.auth_id, fs.course_handicap
        FROM scores s
        JOIN finalized_scores fs ON s.round_id = fs.round_id AND s.auth_id = fs.auth_id
        WHERE s.round_id = v_round_id
    LOOP
        -- First delete any existing net scores for this player and round
        DELETE FROM net_scores 
        WHERE round_id = v_round_id AND auth_id = v_player.auth_id;

        -- Insert net scores for each hole
        INSERT INTO net_scores (
            round_id,
            auth_id,
            hole_number,
            gross_score,
            net_score,
            hole_handicap
        )
        SELECT 
            s.round_id,
            s.auth_id,
            s.hole_number,
            s.strokes,
            CASE
                -- Calculate net score based on handicap and hole difficulty
                WHEN v_player.course_handicap > 0 AND 
                     v_hole_handicaps[s.hole_number] <= v_player.course_handicap THEN
                    s.strokes - 1
                WHEN v_player.course_handicap < 0 AND 
                     v_hole_handicaps[s.hole_number] > (18 + v_player.course_handicap) THEN
                    s.strokes + 1
                ELSE s.strokes
            END as net_score,
            v_hole_handicaps[s.hole_number]
        FROM scores s
        WHERE s.round_id = v_round_id
        AND s.auth_id = v_player.auth_id;
    END LOOP;
END $$;