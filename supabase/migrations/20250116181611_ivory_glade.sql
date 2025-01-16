-- Drop existing views if they exist
DROP VIEW IF EXISTS match_player_summary;
DROP VIEW IF EXISTS match_player_totals;

-- Create match summary view
CREATE VIEW match_player_summary AS
SELECT 
    mp.auth_id,
    p.name as player_name,
    r.date as match_date,
    r.course_name,
    m.match_type,
    m.scoring_type,
    mr.front_nine_payout,
    mr.back_nine_payout,
    mr.total_payout as match_total,
    COALESCE((
        SELECT SUM(mb.payout)
        FROM match_birdies mb 
        WHERE mb.match_id = m.id 
        AND mb.auth_id = mp.auth_id
    ), 0) as birdie_total,
    (mr.front_nine_payout + mr.back_nine_payout + mr.total_payout + 
        COALESCE((
            SELECT SUM(mb.payout)
            FROM match_birdies mb 
            WHERE mb.match_id = m.id 
            AND mb.auth_id = mp.auth_id
        ), 0)) as total_winnings
FROM matches m
JOIN rounds r ON m.round_id = r.id
JOIN match_players mp ON m.id = mp.match_id
JOIN players p ON mp.auth_id = p.auth_id
JOIN match_results mr ON m.id = mr.match_id AND mp.team = mr.team
ORDER BY r.date DESC, p.name;

-- Create player totals view
CREATE VIEW match_player_totals AS
SELECT 
    auth_id,
    player_name,
    COUNT(*) as matches_played,
    SUM(front_nine_payout) as total_front_nine,
    SUM(back_nine_payout) as total_back_nine,
    SUM(match_total) as total_match,
    SUM(birdie_total) as total_birdies,
    SUM(total_winnings) as total_winnings,
    COUNT(CASE WHEN total_winnings > 0 THEN 1 END) as matches_won,
    COUNT(CASE WHEN total_winnings < 0 THEN 1 END) as matches_lost,
    COUNT(CASE WHEN total_winnings = 0 THEN 1 END) as matches_tied
FROM match_player_summary
GROUP BY auth_id, player_name
ORDER BY total_winnings DESC;

-- Create daily player results view
CREATE VIEW match_player_daily_results AS
SELECT 
    auth_id,
    player_name,
    match_date,
    COUNT(*) as matches_played,
    SUM(front_nine_payout) as total_front_nine,
    SUM(back_nine_payout) as total_back_nine,
    SUM(match_total) as total_match,
    SUM(birdie_total) as total_birdies,
    SUM(total_winnings) as total_winnings
FROM match_player_summary
GROUP BY auth_id, player_name, match_date
ORDER BY match_date DESC, total_winnings DESC;

-- Grant access to the views
GRANT SELECT ON match_player_summary TO authenticated;
GRANT SELECT ON match_player_totals TO authenticated;
GRANT SELECT ON match_player_daily_results TO authenticated;

-- Add comments for documentation
COMMENT ON VIEW match_player_summary IS 'Individual match results for each player';
COMMENT ON VIEW match_player_totals IS 'Total results across all matches for each player';
COMMENT ON VIEW match_player_daily_results IS 'Daily summary of results for each player';