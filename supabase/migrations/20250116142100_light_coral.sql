-- Add scoring_type column to bets table
ALTER TABLE bets
ADD COLUMN scoring_type text NOT NULL DEFAULT 'gross'
CHECK (scoring_type IN ('gross', 'net'));

-- Add comment explaining scoring types
COMMENT ON COLUMN bets.scoring_type IS 'Type of scoring to use: gross or net';