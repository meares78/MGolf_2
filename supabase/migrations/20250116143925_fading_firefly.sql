-- Clean out all match-related data
DELETE FROM match_birdies;
DELETE FROM match_results;
DELETE FROM match_players;
DELETE FROM matches;

-- Clean out old bet-related data
DELETE FROM bet_participants;
DELETE FROM bets;

-- Add comment for documentation
COMMENT ON TABLE matches IS 'Starting fresh with matches after cleanup';