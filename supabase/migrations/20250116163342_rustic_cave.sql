-- Drop all match-related tables in the correct order
DROP TABLE IF EXISTS match_birdies CASCADE;
DROP TABLE IF EXISTS match_results CASCADE;
DROP TABLE IF EXISTS match_players CASCADE;
DROP TABLE IF EXISTS matches CASCADE;

-- Drop any related functions
DROP FUNCTION IF EXISTS calculate_match_results(uuid);

-- Drop any related indexes
DROP INDEX IF EXISTS matches_round_id_idx;
DROP INDEX IF EXISTS match_results_match_id_idx;
DROP INDEX IF EXISTS match_birdies_match_id_idx;
DROP INDEX IF EXISTS match_birdies_auth_id_idx;
DROP INDEX IF EXISTS match_players_match_id_idx;
DROP INDEX IF EXISTS match_players_auth_id_idx;
DROP INDEX IF EXISTS matches_bet_amounts_idx;