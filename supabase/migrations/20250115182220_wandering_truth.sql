/*
  # Update player and score tables for auth integration

  1. Changes
    - Add auth_id and phone columns to players table
    - Update scores table to use auth_id instead of player_id
    - Add necessary indexes for performance
  
  2. Security
    - Update RLS policies to use auth.uid()
    - Ensure proper access control for all operations
*/

-- First drop the policies that depend on player_id
DROP POLICY IF EXISTS "Users can insert their own scores" ON scores;
DROP POLICY IF EXISTS "Users can update their own scores" ON scores;

-- Now we can safely modify the tables
ALTER TABLE players 
DROP CONSTRAINT IF EXISTS players_user_id_fkey,
ADD COLUMN IF NOT EXISTS auth_id uuid REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS phone text;

ALTER TABLE scores
DROP CONSTRAINT IF EXISTS scores_player_id_fkey,
ADD COLUMN IF NOT EXISTS auth_id uuid REFERENCES auth.users(id);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS players_auth_id_idx ON players(auth_id);
CREATE INDEX IF NOT EXISTS scores_auth_id_idx ON scores(auth_id);
CREATE INDEX IF NOT EXISTS scores_round_id_idx ON scores(round_id);

-- Update RLS policies for players
DROP POLICY IF EXISTS "Users can read all players" ON players;
DROP POLICY IF EXISTS "Users can insert their own player data" ON players;
DROP POLICY IF EXISTS "Users can update their own player data" ON players;

CREATE POLICY "Users can read all players"
ON players FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can manage their own player data"
ON players FOR ALL
TO authenticated
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());

-- Update RLS policies for scores
DROP POLICY IF EXISTS "Users can read all scores" ON scores;

CREATE POLICY "Users can read all scores"
ON scores FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can manage their own scores"
ON scores FOR ALL
TO authenticated
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());

-- Now we can safely drop the player_id column since nothing depends on it
ALTER TABLE scores DROP COLUMN IF EXISTS player_id;