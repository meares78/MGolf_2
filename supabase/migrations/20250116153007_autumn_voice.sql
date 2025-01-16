-- Add new columns for separate bet amounts
ALTER TABLE matches
ADD COLUMN front_nine_bet numeric NOT NULL DEFAULT 5,
ADD COLUMN back_nine_bet numeric NOT NULL DEFAULT 5,
ADD COLUMN total_bet numeric NOT NULL DEFAULT 5;

-- Migrate existing data
UPDATE matches
SET front_nine_bet = amount,
    back_nine_bet = amount,
    total_bet = amount;

-- Drop the old amount column
ALTER TABLE matches
DROP COLUMN amount;

-- Add comments for documentation
COMMENT ON COLUMN matches.front_nine_bet IS 'Bet amount for front nine holes';
COMMENT ON COLUMN matches.back_nine_bet IS 'Bet amount for back nine holes';
COMMENT ON COLUMN matches.total_bet IS 'Bet amount for total match';

-- Create indexes for better performance
CREATE INDEX matches_bet_amounts_idx ON matches(front_nine_bet, back_nine_bet, total_bet);