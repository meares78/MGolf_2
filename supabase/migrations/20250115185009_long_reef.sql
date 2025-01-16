/*
  # Add player handicaps table

  1. New Tables
    - `player_handicaps`
      - `id` (uuid, primary key)
      - `player_id` (uuid, references players)
      - `course_name` (text)
      - `tee_name` (text)
      - `handicap` (numeric)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS
    - Add policies for authenticated users
*/

-- Create player_handicaps table
CREATE TABLE player_handicaps (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id uuid REFERENCES players(id) ON DELETE CASCADE,
    course_name text NOT NULL,
    tee_name text NOT NULL,
    handicap numeric NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(player_id, course_name, tee_name)
);

-- Enable RLS
ALTER TABLE player_handicaps ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX player_handicaps_player_id_idx ON player_handicaps(player_id);
CREATE INDEX player_handicaps_course_tee_idx ON player_handicaps(course_name, tee_name);

-- Create policies
CREATE POLICY "Enable read access for all authenticated users"
ON player_handicaps FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert/update for admins"
ON player_handicaps FOR ALL
TO authenticated
USING (auth.uid() IN (
    SELECT auth_id 
    FROM players 
    WHERE phone IN ('+18563812930', '+18563414490')  -- Admin phone numbers
))
WITH CHECK (auth.uid() IN (
    SELECT auth_id 
    FROM players 
    WHERE phone IN ('+18563812930', '+18563414490')  -- Admin phone numbers
));

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_player_handicaps_updated_at
    BEFORE UPDATE ON player_handicaps
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();