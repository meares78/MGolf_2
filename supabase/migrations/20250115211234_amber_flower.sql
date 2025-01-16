/*
  # Add Handicap Index Support

  1. Changes
    - Add handicap_index column to players table
    - Add indexes for better performance
    - Update policies to allow admin management
    - Add trigger for updating timestamps

  2. Security
    - Only admins can update handicap_index
    - All authenticated users can read handicap_index
*/

-- Add handicap_index column to players table
ALTER TABLE players 
ADD COLUMN IF NOT EXISTS handicap_index numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- Create index for better performance
CREATE INDEX IF NOT EXISTS players_handicap_index_idx ON players(handicap_index);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_player_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_players_updated_at
    BEFORE UPDATE ON players
    FOR EACH ROW
    EXECUTE FUNCTION update_player_updated_at();

-- Update policies for handicap management
CREATE POLICY "Enable handicap updates for admins"
ON players
FOR UPDATE
TO authenticated
USING (
    auth.uid() IN (
        SELECT auth_id 
        FROM players 
        WHERE phone IN ('+18563812930', '+18563414490')
    )
)
WITH CHECK (
    auth.uid() IN (
        SELECT auth_id 
        FROM players 
        WHERE phone IN ('+18563812930', '+18563414490')
    )
);