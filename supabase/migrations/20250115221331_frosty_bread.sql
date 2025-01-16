-- Update the round_score_summary view to include tee information
DROP VIEW IF EXISTS round_score_summary;
CREATE VIEW round_score_summary AS
SELECT 
    r.date,
    r.course_name,
    r.tee_name,
    r.tee_color,
    p.name as player_name,
    p.phone,
    array_agg(s.strokes ORDER BY s.hole_number) as hole_scores,
    sum(s.strokes) as total_gross,
    fs.total_net,
    fs.course_handicap
FROM rounds r
JOIN scores s ON r.id = s.round_id
JOIN players p ON s.auth_id = p.auth_id
LEFT JOIN finalized_scores fs ON r.id = fs.round_id AND s.auth_id = fs.auth_id
GROUP BY r.date, r.course_name, r.tee_name, r.tee_color, p.name, p.phone, fs.total_net, fs.course_handicap
ORDER BY r.date, p.name;

-- Update finalized scores with correct handicaps
DO $$
DECLARE
    score_record RECORD;
    player_handicap numeric;
    gross_score numeric;
BEGIN
    -- Loop through all finalized scores that need updating
    FOR score_record IN 
        SELECT 
            fs.id as finalized_score_id,
            r.course_name,
            r.tee_name || '-' || r.tee_color as full_tee_name,
            p.id as player_id,
            (SELECT sum(strokes) FROM scores WHERE round_id = r.id AND auth_id = fs.auth_id) as total_gross
        FROM finalized_scores fs
        JOIN rounds r ON fs.round_id = r.id
        JOIN players p ON fs.auth_id = p.auth_id
        WHERE fs.course_handicap = 0
    LOOP
        -- Get the player's handicap for this course and tee
        SELECT handicap INTO player_handicap
        FROM player_handicaps
        WHERE player_id = score_record.player_id
        AND course_name = score_record.course_name
        AND tee_name = score_record.full_tee_name;

        IF FOUND THEN
            -- Update the finalized score with the correct handicap and net score
            UPDATE finalized_scores
            SET course_handicap = COALESCE(player_handicap, 0),
                total_net = score_record.total_gross - COALESCE(player_handicap, 0)
            WHERE id = score_record.finalized_score_id;
        END IF;
    END LOOP;
END $$;