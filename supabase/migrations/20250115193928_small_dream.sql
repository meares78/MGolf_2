/*
  # Fix results table relationships

  1. Changes
    - Add auth_id to results tables
    - Update queries to use auth_id instead of player joins
    - Add proper foreign key constraints
    - Update RLS policies
*/

-- Drop existing tables
DROP TABLE IF EXISTS round_results CASCADE;
DROP TABLE IF EXISTS skins CASCADE;
DROP TABLE IF EXISTS twos CASCADE;

-- Create round_results table
CREATE TABLE round_results (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id uuid REFERENCES rounds(id) ON DELETE CASCADE,
    auth_id uuid REFERENCES auth.users(id),
    position integer NOT NULL CHECK (position BETWEEN 1 AND 3),
    net_score integer NOT NULL,
    gross_score integer NOT NULL,
    payout numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(round_id, position)
);

-- Create skins table
CREATE TABLE skins (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id uuid REFERENCES rounds(id) ON DELETE CASCADE,
    auth_id uuid REFERENCES auth.users(id),
    hole_number integer NOT NULL CHECK (hole_number BETWEEN 1 AND 18),
    gross_score integer NOT NULL,
    payout numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create twos table
CREATE TABLE twos (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id uuid REFERENCES rounds(id) ON DELETE CASCADE,
    auth_id uuid REFERENCES auth.users(id),
    hole_number integer NOT NULL CHECK (hole_number BETWEEN 1 AND 18),
    payout numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE round_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE skins ENABLE ROW LEVEL SECURITY;
ALTER TABLE twos ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX round_results_round_id_idx ON round_results(round_id);
CREATE INDEX round_results_auth_id_idx ON round_results(auth_id);
CREATE INDEX skins_round_id_idx ON skins(round_id);
CREATE INDEX skins_auth_id_idx ON skins(auth_id);
CREATE INDEX twos_round_id_idx ON twos(round_id);
CREATE INDEX twos_auth_id_idx ON twos(auth_id);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_round_results_updated_at
    BEFORE UPDATE ON round_results
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skins_updated_at
    BEFORE UPDATE ON skins
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_twos_updated_at
    BEFORE UPDATE ON twos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create policies
CREATE POLICY "Enable read access for all authenticated users"
ON round_results FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable read access for all authenticated users"
ON skins FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable read access for all authenticated users"
ON twos FOR SELECT
TO authenticated
USING (true);

-- Only admins can insert/update results
CREATE POLICY "Enable insert/update for admins"
ON round_results FOR ALL
TO authenticated
USING (auth.uid() IN (
    SELECT auth_id 
    FROM players 
    WHERE phone IN ('+18563812930', '+18563414490')
))
WITH CHECK (auth.uid() IN (
    SELECT auth_id 
    FROM players 
    WHERE phone IN ('+18563812930', '+18563414490')
));

CREATE POLICY "Enable insert/update for admins"
ON skins FOR ALL
TO authenticated
USING (auth.uid() IN (
    SELECT auth_id 
    FROM players 
    WHERE phone IN ('+18563812930', '+18563414490')
))
WITH CHECK (auth.uid() IN (
    SELECT auth_id 
    FROM players 
    WHERE phone IN ('+18563812930', '+18563414490')
));

CREATE POLICY "Enable insert/update for admins"
ON twos FOR ALL
TO authenticated
USING (auth.uid() IN (
    SELECT auth_id 
    FROM players 
    WHERE phone IN ('+18563812930', '+18563414490')
))
WITH CHECK (auth.uid() IN (
    SELECT auth_id 
    FROM players 
    WHERE phone IN ('+18563812930', '+18563414490')
));