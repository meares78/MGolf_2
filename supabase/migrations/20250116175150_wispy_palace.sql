-- First check if the unique constraint already exists
DO $$ 
BEGIN
    -- Drop the constraint if it exists
    IF EXISTS (
        SELECT 1 
        FROM pg_constraint 
        WHERE conname = 'players_auth_id_key'
    ) THEN
        ALTER TABLE players DROP CONSTRAINT players_auth_id_key;
    END IF;
END $$;

-- Add the unique constraint
ALTER TABLE players ADD CONSTRAINT players_auth_id_key UNIQUE (auth_id);

-- Drop any existing foreign key constraint on auth_id
ALTER TABLE match_players
DROP CONSTRAINT IF EXISTS match_players_auth_id_fkey;

-- Add new foreign key constraint to players table
ALTER TABLE match_players
ADD CONSTRAINT match_players_auth_id_fkey
FOREIGN KEY (auth_id)
REFERENCES players(auth_id)
ON DELETE CASCADE;

-- Create index for better join performance
CREATE INDEX IF NOT EXISTS match_players_auth_id_players_idx 
ON match_players(auth_id);

-- Add comment explaining the relationship
COMMENT ON CONSTRAINT match_players_auth_id_fkey ON match_players IS 
'Links match players to their player record via auth_id';