-- First, clear out existing match results to recalculate
DELETE FROM match_results;
DELETE FROM match_birdies;

-- Create a function to calculate match results
CREATE OR REPLACE FUNCTION calculate_match_results(p_match_id uuid)
RETURNS void AS $$
DECLARE
    v_match record;
    v_round_id uuid;
    v_team_a_scores record;
    v_team_b_scores record;
    v_front_nine_winner text;
    v_back_nine_winner text;
    v_total_winner text;
BEGIN
    -- Get match details and round_id
    SELECT m.*, r.id as round_id 
    INTO v_match 
    FROM matches m
    JOIN rounds r ON r.id = m.round_id
    WHERE m.id = p_match_id;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- Calculate team scores for Team A
    WITH team_a_hole_scores AS (
        SELECT 
            s.hole_number,
            MIN(CASE WHEN v_match.scoring_type = 'net' THEN ns.net_score ELSE s.strokes END) as best_score
        FROM match_players mp
        JOIN scores s ON s.auth_id = mp.auth_id
        LEFT JOIN net_scores ns ON ns.round_id = v_match.round_id 
            AND ns.auth_id = s.auth_id 
            AND ns.hole_number = s.hole_number
        WHERE mp.match_id = p_match_id 
        AND mp.team = 'A'
        AND s.round_id = v_match.round_id
        GROUP BY s.hole_number
    )
    SELECT 
        'A' as team,
        COALESCE(SUM(CASE WHEN hole_number <= 9 THEN best_score ELSE 0 END), 0) as front_nine,
        COALESCE(SUM(CASE WHEN hole_number > 9 THEN best_score ELSE 0 END), 0) as back_nine,
        COALESCE(SUM(best_score), 0) as total
    INTO v_team_a_scores
    FROM team_a_hole_scores;

    -- Calculate team scores for Team B
    WITH team_b_hole_scores AS (
        SELECT 
            s.hole_number,
            MIN(CASE WHEN v_match.scoring_type = 'net' THEN ns.net_score ELSE s.strokes END) as best_score
        FROM match_players mp
        JOIN scores s ON s.auth_id = mp.auth_id
        LEFT JOIN net_scores ns ON ns.round_id = v_match.round_id 
            AND ns.auth_id = s.auth_id 
            AND ns.hole_number = s.hole_number
        WHERE mp.match_id = p_match_id 
        AND mp.team = 'B'
        AND s.round_id = v_match.round_id
        GROUP BY s.hole_number
    )
    SELECT 
        'B' as team,
        COALESCE(SUM(CASE WHEN hole_number <= 9 THEN best_score ELSE 0 END), 0) as front_nine,
        COALESCE(SUM(CASE WHEN hole_number > 9 THEN best_score ELSE 0 END), 0) as back_nine,
        COALESCE(SUM(best_score), 0) as total
    INTO v_team_b_scores
    FROM team_b_hole_scores;

    -- Delete existing results
    DELETE FROM match_results WHERE match_id = p_match_id;
    DELETE FROM match_birdies WHERE match_id = p_match_id;

    -- Determine winners (lower score wins in golf)
    v_front_nine_winner := CASE 
        WHEN v_team_a_scores.front_nine < v_team_b_scores.front_nine THEN 'A'
        WHEN v_team_a_scores.front_nine > v_team_b_scores.front_nine THEN 'B'
        ELSE 'tie'
    END;

    v_back_nine_winner := CASE 
        WHEN v_team_a_scores.back_nine < v_team_b_scores.back_nine THEN 'A'
        WHEN v_team_a_scores.back_nine > v_team_b_scores.back_nine THEN 'B'
        ELSE 'tie'
    END;

    v_total_winner := CASE 
        WHEN v_team_a_scores.total < v_team_b_scores.total THEN 'A'
        WHEN v_team_a_scores.total > v_team_b_scores.total THEN 'B'
        ELSE 'tie'
    END;

    -- Insert results for Team A
    INSERT INTO match_results (
        match_id,
        team,
        front_nine_points,
        back_nine_points,
        total_points,
        front_nine_payout,
        back_nine_payout,
        total_payout
    ) VALUES (
        p_match_id,
        'A',
        CASE WHEN v_front_nine_winner = 'A' THEN 1 ELSE 0 END,
        CASE WHEN v_back_nine_winner = 'A' THEN 1 ELSE 0 END,
        CASE WHEN v_total_winner = 'A' THEN 1 ELSE 0 END,
        CASE 
            WHEN v_front_nine_winner = 'A' THEN v_match.front_nine_bet
            WHEN v_front_nine_winner = 'B' THEN -v_match.front_nine_bet
            ELSE 0
        END,
        CASE 
            WHEN v_back_nine_winner = 'A' THEN v_match.back_nine_bet
            WHEN v_back_nine_winner = 'B' THEN -v_match.back_nine_bet
            ELSE 0
        END,
        CASE 
            WHEN v_total_winner = 'A' THEN v_match.total_bet
            WHEN v_total_winner = 'B' THEN -v_match.total_bet
            ELSE 0
        END
    );

    -- Insert results for Team B
    INSERT INTO match_results (
        match_id,
        team,
        front_nine_points,
        back_nine_points,
        total_points,
        front_nine_payout,
        back_nine_payout,
        total_payout
    ) VALUES (
        p_match_id,
        'B',
        CASE WHEN v_front_nine_winner = 'B' THEN 1 ELSE 0 END,
        CASE WHEN v_back_nine_winner = 'B' THEN 1 ELSE 0 END,
        CASE WHEN v_total_winner = 'B' THEN 1 ELSE 0 END,
        CASE 
            WHEN v_front_nine_winner = 'B' THEN v_match.front_nine_bet
            WHEN v_front_nine_winner = 'A' THEN -v_match.front_nine_bet
            ELSE 0
        END,
        CASE 
            WHEN v_back_nine_winner = 'B' THEN v_match.back_nine_bet
            WHEN v_back_nine_winner = 'A' THEN -v_match.back_nine_bet
            ELSE 0
        END,
        CASE 
            WHEN v_total_winner = 'B' THEN v_match.total_bet
            WHEN v_total_winner = 'A' THEN -v_match.total_bet
            ELSE 0
        END
    );

    -- Calculate and insert birdies
    INSERT INTO match_birdies (match_id, auth_id, hole_number, payout)
    SELECT DISTINCT
        p_match_id,
        s.auth_id,
        s.hole_number,
        v_match.birdie_bet
    FROM match_players mp
    JOIN scores s ON s.auth_id = mp.auth_id
    JOIN rounds r ON r.id = s.round_id
    WHERE mp.match_id = p_match_id
    AND s.round_id = v_match.round_id
    AND s.strokes < CASE 
        WHEN r.course_name = 'Palmer' THEN 
            CASE s.hole_number
                WHEN 1 THEN 4 WHEN 2 THEN 3 WHEN 3 THEN 5 WHEN 4 THEN 4 WHEN 5 THEN 3
                WHEN 6 THEN 4 WHEN 7 THEN 4 WHEN 8 THEN 4 WHEN 9 THEN 5 WHEN 10 THEN 5
                WHEN 11 THEN 4 WHEN 12 THEN 4 WHEN 13 THEN 4 WHEN 14 THEN 3 WHEN 15 THEN 5
                WHEN 16 THEN 3 WHEN 17 THEN 4 WHEN 18 THEN 4
            END
        WHEN r.course_name = 'Nicklaus' THEN
            CASE s.hole_number
                WHEN 1 THEN 4 WHEN 2 THEN 4 WHEN 3 THEN 5 WHEN 4 THEN 4 WHEN 5 THEN 3
                WHEN 6 THEN 5 WHEN 7 THEN 4 WHEN 8 THEN 3 WHEN 9 THEN 4 WHEN 10 THEN 4
                WHEN 11 THEN 3 WHEN 12 THEN 4 WHEN 13 THEN 4 WHEN 14 THEN 4 WHEN 15 THEN 5
                WHEN 16 THEN 3 WHEN 17 THEN 4 WHEN 18 THEN 5
            END
        WHEN r.course_name = 'Watson' THEN
            CASE s.hole_number
                WHEN 1 THEN 5 WHEN 2 THEN 4 WHEN 3 THEN 3 WHEN 4 THEN 4 WHEN 5 THEN 4
                WHEN 6 THEN 4 WHEN 7 THEN 3 WHEN 8 THEN 5 WHEN 9 THEN 4 WHEN 10 THEN 4
                WHEN 11 THEN 4 WHEN 12 THEN 3 WHEN 13 THEN 4 WHEN 14 THEN 5 WHEN 15 THEN 3
                WHEN 16 THEN 4 WHEN 17 THEN 5 WHEN 18 THEN 4
            END
        WHEN r.course_name = 'SouthernDunes' THEN
            CASE s.hole_number
                WHEN 1 THEN 4 WHEN 2 THEN 4 WHEN 3 THEN 3 WHEN 4 THEN 5 WHEN 5 THEN 4
                WHEN 6 THEN 3 WHEN 7 THEN 4 WHEN 8 THEN 4 WHEN 9 THEN 5 WHEN 10 THEN 4
                WHEN 11 THEN 3 WHEN 12 THEN 5 WHEN 13 THEN 4 WHEN 14 THEN 3 WHEN 15 THEN 4
                WHEN 16 THEN 5 WHEN 17 THEN 4 WHEN 18 THEN 4
            END
        ELSE 4
    END;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger function to recalculate match results when scores are finalized
CREATE OR REPLACE FUNCTION trigger_calculate_match_results()
RETURNS TRIGGER AS $$
DECLARE
    match_record record;
BEGIN
    -- Find all matches for this round and player
    FOR match_record IN 
        SELECT DISTINCT m.id
        FROM matches m
        JOIN match_players mp ON m.id = mp.match_id
        WHERE mp.auth_id = NEW.auth_id
        AND m.round_id = NEW.round_id
    LOOP
        -- Calculate results for each match
        PERFORM calculate_match_results(match_record.id);
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on finalized_scores
DROP TRIGGER IF EXISTS trigger_match_results_on_finalize ON finalized_scores;
CREATE TRIGGER trigger_match_results_on_finalize
    AFTER INSERT OR UPDATE
    ON finalized_scores
    FOR EACH ROW
    EXECUTE FUNCTION trigger_calculate_match_results();

-- Recalculate results for all existing matches
DO $$
DECLARE
    match_record record;
BEGIN
    FOR match_record IN SELECT id FROM matches
    LOOP
        PERFORM calculate_match_results(match_record.id);
    END LOOP;
END $$;