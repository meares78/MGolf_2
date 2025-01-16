-- Drop existing tables in correct order
DROP TABLE IF EXISTS match_birdies CASCADE;
DROP TABLE IF EXISTS match_results CASCADE;
DROP TABLE IF EXISTS match_players CASCADE;
DROP TABLE IF EXISTS matches CASCADE;

-- Create matches table
CREATE TABLE IF NOT EXISTS matches (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id uuid REFERENCES rounds(id) ON DELETE CASCADE,
    match_type text NOT NULL CHECK (match_type IN ('1v1', '2v2', '4v4')),
    scoring_type text NOT NULL CHECK (scoring_type IN ('gross', 'net')),
    amount numeric NOT NULL DEFAULT 5,
    birdie_bet numeric NOT NULL DEFAULT 1,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create match_players table
CREATE TABLE IF NOT EXISTS match_players (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id uuid REFERENCES matches(id) ON DELETE CASCADE,
    auth_id uuid REFERENCES auth.users(id),
    team text NOT NULL CHECK (team IN ('A', 'B')),
    created_at timestamptz DEFAULT now()
);

-- Create match_results table
CREATE TABLE IF NOT EXISTS match_results (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id uuid REFERENCES matches(id) ON DELETE CASCADE,
    team text NOT NULL CHECK (team IN ('A', 'B')),
    front_nine_points integer NOT NULL DEFAULT 0,
    back_nine_points integer NOT NULL DEFAULT 0,
    total_points integer NOT NULL DEFAULT 0,
    front_nine_payout numeric NOT NULL DEFAULT 0,
    back_nine_payout numeric NOT NULL DEFAULT 0,
    total_payout numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create match_birdies table
CREATE TABLE IF NOT EXISTS match_birdies (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id uuid REFERENCES matches(id) ON DELETE CASCADE,
    auth_id uuid REFERENCES auth.users(id),
    hole_number integer NOT NULL CHECK (hole_number BETWEEN 1 AND 18),
    payout numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- Drop existing indexes to avoid conflicts
DROP INDEX IF EXISTS matches_round_id_idx;
DROP INDEX IF EXISTS match_results_match_id_idx;
DROP INDEX IF EXISTS match_birdies_match_id_idx;
DROP INDEX IF EXISTS match_birdies_auth_id_idx;
DROP INDEX IF EXISTS match_players_match_id_idx;
DROP INDEX IF EXISTS match_players_auth_id_idx;

-- Create indexes
CREATE INDEX IF NOT EXISTS matches_round_id_idx ON matches(round_id);
CREATE INDEX IF NOT EXISTS match_results_match_id_idx ON match_results(match_id);
CREATE INDEX IF NOT EXISTS match_birdies_match_id_idx ON match_birdies(match_id);
CREATE INDEX IF NOT EXISTS match_birdies_auth_id_idx ON match_birdies(auth_id);
CREATE INDEX IF NOT EXISTS match_players_match_id_idx ON match_players(match_id);
CREATE INDEX IF NOT EXISTS match_players_auth_id_idx ON match_players(auth_id);

-- Drop existing triggers to avoid conflicts
DROP TRIGGER IF EXISTS update_matches_updated_at ON matches;
DROP TRIGGER IF EXISTS update_match_results_updated_at ON match_results;

-- Create or replace the update_updated_at_column function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers
CREATE TRIGGER update_matches_updated_at
    BEFORE UPDATE ON matches
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_match_results_updated_at
    BEFORE UPDATE ON match_results
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Drop existing policies to avoid conflicts
DO $$ 
BEGIN
    -- Drop policies for matches
    DROP POLICY IF EXISTS "Enable read access for all authenticated users" ON matches;
    DROP POLICY IF EXISTS "Enable match management for participants" ON matches;
    
    -- Drop policies for match_results
    DROP POLICY IF EXISTS "Enable read access for all authenticated users" ON match_results;
    DROP POLICY IF EXISTS "Enable match result management for participants" ON match_results;
    
    -- Drop policies for match_birdies
    DROP POLICY IF EXISTS "Enable read access for all authenticated users" ON match_birdies;
    DROP POLICY IF EXISTS "Enable birdie management for participants" ON match_birdies;
    
    -- Drop policies for match_players
    DROP POLICY IF EXISTS "Enable read access for all authenticated users" ON match_players;
    DROP POLICY IF EXISTS "Enable match player management for participants" ON match_players;
EXCEPTION
    WHEN undefined_object THEN null;
END $$;

-- Enable RLS
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_birdies ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_players ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all authenticated users"
ON matches FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable read access for all authenticated users"
ON match_results FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable read access for all authenticated users"
ON match_birdies FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable read access for all authenticated users"
ON match_players FOR SELECT
TO authenticated
USING (true);

-- Allow match creation and updates for participants
CREATE POLICY "Enable match management for participants"
ON matches FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable match player management for participants"
ON match_players FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable match result management for participants"
ON match_results FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable birdie management for participants"
ON match_birdies FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Add comments for documentation
COMMENT ON TABLE matches IS 'Stores match information including type and betting amounts';
COMMENT ON TABLE match_results IS 'Stores match results including points and payouts for each team';
COMMENT ON TABLE match_birdies IS 'Stores birdie payouts for each player';
COMMENT ON TABLE match_players IS 'Stores player assignments to teams for each match';