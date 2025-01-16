-- Create match summary view
CREATE OR REPLACE VIEW match_player_summary AS
SELECT 
    mp.auth_id,
    p.name as player_name,
    r.date as match_date,
    r.course_name,
    mr.front_nine_payout,
    mr.back_nine_payout,
    mr.total_payout as match_total,
    COALESCE((
        SELECT SUM(mb.payout)
        FROM match_birdies mb 
        WHERE mb.match_id = m.id 
        AND mb.auth_id = mp.auth_id
    ), 0) as birdie_payout,
    (mr.front_nine_payout + mr.back_nine_payout + mr.total_payout + 
     COALESCE((
        SELECT SUM(mb.payout)
        FROM match_birdies mb 
        WHERE mb.match_id = m.id 
        AND mb.auth_id = mp.auth_id
     ), 0)) as grand_total
FROM matches m
JOIN rounds r ON m.round_id = r.id
JOIN match_players mp ON m.id = mp.match_id
JOIN players p ON mp.auth_id = p.auth_id
JOIN match_results mr ON m.id = mr.match_id AND mp.team = mr.team
ORDER BY r.date DESC, p.name;

-- Create player totals view
CREATE OR REPLACE VIEW match_player_totals AS
SELECT 
    mp.auth_id,
    p.name as player_name,
    COUNT(DISTINCT m.id) as total_matches,
    SUM(mr.front_nine_payout) as total_front_nine,
    SUM(mr.back_nine_payout) as total_back_nine,
    SUM(mr.total_payout) as total_match,
    SUM(COALESCE((
        SELECT SUM(mb.payout)
        FROM match_birdies mb 
        WHERE mb.match_id = m.id 
        AND mb.auth_id = mp.auth_id
    ), 0)) as total_birdies,
    SUM(mr.front_nine_payout + mr.back_nine_payout + mr.total_payout + 
        COALESCE((
            SELECT SUM(mb.payout)
            FROM match_birdies mb 
            WHERE mb.match_id = m.id 
            AND mb.auth_id = mp.auth_id
        ), 0)) as grand_total
FROM matches m
JOIN match_players mp ON m.id = mp.match_id
JOIN players p ON mp.auth_id = p.auth_id
JOIN match_results mr ON m.id = mr.match_id AND mp.team = mr.team
GROUP BY mp.auth_id, p.name
ORDER BY grand_total DESC;

-- Grant access to the views
GRANT SELECT ON match_player_summary TO authenticated;
GRANT SELECT ON match_player_totals TO authenticated;