-- Drop existing check constraint
ALTER TABLE bets DROP CONSTRAINT IF EXISTS bets_bet_type_check;

-- Add new check constraint with match types
ALTER TABLE bets ADD CONSTRAINT bets_bet_type_check 
  CHECK (bet_type IN ('1v1', '2v2', '4v4', 'skins', 'nassau', 'match'));

-- Add comment explaining valid bet types
COMMENT ON COLUMN bets.bet_type IS 'Valid types: 1v1, 2v2, 4v4, skins, nassau, match';