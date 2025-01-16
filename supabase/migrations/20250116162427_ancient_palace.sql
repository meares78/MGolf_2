-- First, clear out existing match results to recalculate
DELETE FROM match_results;
DELETE FROM match_birdies;

-- Create a function to calculate match results
CREATE OR REPLACE FUNCTION calculate_match_results(p_match_id uuid)
RETURNS void AS $$
DECLARE
    v_match record;
    v_team_a_scores record;
    v_team_b_scores record;
    v_front_nine_winner text;
    v_back_nine_winner text;
    v_total_winner text;
    v_team_scores record;
BEGIN
    -- Get match details
    SELECT * INTO v_match FROM matches WHERE id = p_match_id;
    
    -- Calculate team scores for Team A
    SELECT 
        'A' as team,
        SUM(CASE WHEN s.hole_number <= 9 THEN s.strokes ELSE 0 END) as front_nine,
        SUM(CASE WHEN s.hole_number > 9 THEN s.strokes ELSE 0 END) as back_nine,
        SUM(s.strokes) as total
    INTO v_team_a_scores
    FROM match_players mp
    JOIN scores s ON s.auth_id = mp.auth_id
    WHERE mp.match_id = p_match_id AND mp.team = 'A'
    GROUP BY mp.team;

    -- Calculate team scores for Team B
    SELECT 
        'B' as team,
        SUM(CASE WHEN s.hole_number <= 9 THEN s.strokes ELSE 0 END) as front_nine,
        SUM(CASE WHEN s.hole_number > 9 THEN s.strokes ELSE 0 END) as back_nine,
        SUM(s.strokes) as total
    INTO v_team_b_scores
    FROM match_players mp
    JOIN scores s ON s.auth_id = mp.auth_id
    WHERE mp.match_id = p_match_id AND mp.team = 'B'
    GROUP BY mp.team;

    -- Determine winners
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