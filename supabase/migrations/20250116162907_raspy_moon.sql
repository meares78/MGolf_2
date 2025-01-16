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
    JOIN match_players mp ON m.id = mp.match_id
    JOIN scores s ON mp.auth_id = s.auth_id
    JOIN rounds r ON s.round_id = r.id
    WHERE m.id = p_match_id
    LIMIT 1;

    -- Calculate team scores for Team A
    WITH team_a_hole_scores AS (
        SELECT 
            s.hole_number,
            MIN(s.strokes) as best_score -- Take best score for team matches
        FROM match_players mp
        JOIN scores s ON s.auth_id = mp.auth_id
        WHERE mp.match_id = p_match_id 
        AND mp.team = 'A'
        AND s.round_id = v_round_id
        GROUP BY s.hole_number
    )
    SELECT 
        'A' as team,
        SUM(CASE WHEN hole_number <= 9 THEN best_score ELSE 0 END) as front_nine,
        SUM(CASE WHEN hole_number > 9 THEN best_score ELSE 0 END) as back_nine,
        SUM(best_score) as total
    INTO v_team_a_scores
    FROM team_a_hole_scores;

    -- Calculate team scores for Team B
    WITH team_b_hole_scores AS (
        SELECT 
            s.hole_number,
            MIN(s.strokes) as best_score -- Take best score for team matches
        FROM match_players mp
        JOIN scores s ON s.auth_id = mp.auth_id
        WHERE mp.match_id = p_match_id 
        AND mp.team = 'B'
        AND s.round_id = v_round_id
        GROUP BY s.hole_number
    )
    SELECT 
        'B' as team,
        SUM(CASE WHEN hole_number <= 9 THEN best_score ELSE 0 END) as front_nine,
        SUM(CASE WHEN hole_number > 9 THEN best_score ELSE 0 END) as back_nine,
        SUM(best_score) as total
    INTO v_team_b_scores
    FROM team_b_hole_scores;

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
    WITH hole_pars AS (
        SELECT hole_number, par
        FROM (VALUES
            (1,4), (2,4), (3,5), (4,4), (5,3), (6,5), (7,4), (8,3), (9,4),
            (10,4), (11,3), (12,4), (13,4), (14,4), (15,5), (16,3), (17,4), (18,5)
        ) AS t(hole_number, par)
    )
    INSERT INTO match_birdies (match_id, auth_id, hole_number, payout)
    SELECT DISTINCT
        p_match_id,
        s.auth_id,
        s.hole_number,
        v_match.birdie_bet
    FROM match_players mp
    JOIN scores s ON s.auth_id = mp.auth_id
    JOIN hole_pars hp ON hp.hole_number = s.hole_number
    WHERE mp.match_id = p_match_id
    AND s.round_id = v_round_id
    AND s.strokes < hp.par;
END;
$$ LANGUAGE plpgsql;

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