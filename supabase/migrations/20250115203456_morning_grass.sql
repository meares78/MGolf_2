/*
  # Create view for score verification
  
  1. New Views
    - `round_score_summary` - Shows scores for each player in each round
      - Round details (date, course)
      - Player details (name, phone)
      - Score details (hole-by-hole and totals)
*/

-- Create a view to easily verify scores
CREATE OR REPLACE VIEW round_score_summary AS
SELECT 
    r.date,
    r.course_name,
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
GROUP BY r.date, r.course_name, p.name, p.phone, fs.total_net, fs.course_handicap
ORDER BY r.date, p.name;

-- Grant access to the view
GRANT SELECT ON round_score_summary TO authenticated;