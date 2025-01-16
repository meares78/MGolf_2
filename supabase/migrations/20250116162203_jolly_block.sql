-- First check if columns exist and drop them if they do
DO $$ 
BEGIN
    -- Drop existing columns if they exist
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'matches' AND column_name = 'front_nine_bet') THEN
        ALTER TABLE matches DROP COLUMN front_nine_bet;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'matches' AND column_name = 'back_nine_bet') THEN
        ALTER TABLE matches DROP COLUMN back_nine_bet;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'matches' AND column_name = 'total_bet') THEN
        ALTER TABLE matches DROP COLUMN total_bet;
    END IF;
END $$;

-- Drop existing index if it exists
DROP INDEX IF EXISTS matches_bet_amounts_idx;

-- Add new columns for separate bet amounts
ALTER TABLE matches
ADD COLUMN front_nine_bet numeric NOT NULL DEFAULT 5,
ADD COLUMN back_nine_bet numeric NOT NULL DEFAULT 5,
ADD COLUMN total_bet numeric NOT NULL DEFAULT 5;

-- Add comments for documentation
COMMENT ON COLUMN matches.front_nine_bet IS 'Bet amount for front nine holes';
COMMENT ON COLUMN matches.back_nine_bet IS 'Bet amount for back nine holes';
COMMENT ON COLUMN matches.total_bet IS 'Bet amount for total match';

-- Create indexes for better performance
CREATE INDEX matches_bet_amounts_idx ON matches(front_nine_bet, back_nine_bet, total_bet);