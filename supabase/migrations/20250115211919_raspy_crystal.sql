/*
  # Fix Handicap Persistence

  1. Changes
    - Drop existing player_handicaps table
    - Recreate player_handicaps table with proper constraints
    - Add comprehensive indexes
    - Update RLS policies
    - Add triggers for automatic timestamp updates

  2. Security
    - Only admins can manage handicaps
    - All authenticated users can read handicaps
*/

-- Drop existing table and related objects
DROP TABLE IF EXISTS player_handicaps CASCADE;

-- Create new player_handicaps table
CREATE TABLE player_handicaps (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id uuid REFERENCES players(id) ON DELETE CASCADE,
    course_name text NOT NULL,
    tee_name text NOT NULL,
    handicap numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(player_id, course_name, tee_name)
);

-- Enable RLS
ALTER TABLE player_handicaps ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX player_handicaps_player_id_idx ON player_handicaps(player_id);
CREATE INDEX player_handicaps_course_name_idx ON player_handicaps(course_name);
CREATE INDEX player_handicaps_tee_name_idx ON player_handicaps(tee_name);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_player_handicaps_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_player_handicaps_timestamp
    BEFORE UPDATE ON player_handicaps
    FOR EACH ROW
    EXECUTE FUNCTION update_player_handicaps_timestamp();

-- Create policies
CREATE POLICY "Enable read access for all authenticated users"
ON player_handicaps FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable all access for admins"
ON player_handicaps FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM players
        WHERE players.auth_id = auth.uid()
        AND players.phone IN ('+18563812930', '+18563414490')
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM players
        WHERE players.auth_id = auth.uid()
        AND players.phone IN ('+18563812930', '+18563414490')
    )
);