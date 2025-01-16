/*
  # Fix database schema for authentication and scoring

  1. Changes
    - Drop existing tables to start fresh
    - Recreate tables with correct structure
    - Add proper foreign key constraints
    - Add indexes for performance
  
  2. Security
    - Enable RLS on all tables
    - Set up proper policies using auth.uid()
*/

-- Drop existing tables and start fresh
DROP TABLE IF EXISTS scores CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS rounds CASCADE;

-- Create players table
CREATE TABLE players (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_id uuid REFERENCES auth.users(id) NOT NULL,
    name text NOT NULL,
    phone text UNIQUE NOT NULL,
    handicap numeric DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- Create rounds table
CREATE TABLE rounds (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    external_id text UNIQUE,
    course_name text NOT NULL,
    date date NOT NULL DEFAULT CURRENT_DATE,
    created_by uuid REFERENCES auth.users(id),
    created_at timestamptz DEFAULT now()
);

-- Create scores table
CREATE TABLE scores (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id uuid REFERENCES rounds(id) ON DELETE CASCADE,
    auth_id uuid REFERENCES auth.users(id),
    hole_number integer NOT NULL CHECK (hole_number BETWEEN 1 AND 18),
    strokes integer NOT NULL CHECK (strokes > 0),
    created_at timestamptz DEFAULT now(),
    UNIQUE(round_id, auth_id, hole_number)
);

-- Enable RLS
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX players_auth_id_idx ON players(auth_id);
CREATE INDEX players_phone_idx ON players(phone);
CREATE INDEX rounds_external_id_idx ON rounds(external_id);
CREATE INDEX rounds_created_by_idx ON rounds(created_by);
CREATE INDEX scores_round_id_idx ON scores(round_id);
CREATE INDEX scores_auth_id_idx ON scores(auth_id);

-- Players policies
CREATE POLICY "Enable read access for all authenticated users"
ON players FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert/update for own data"
ON players FOR ALL
TO authenticated
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());

-- Rounds policies
CREATE POLICY "Enable read access for all authenticated users"
ON rounds FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert for authenticated users"
ON rounds FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable update for authenticated users"
ON rounds FOR UPDATE
TO authenticated
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- Scores policies
CREATE POLICY "Enable read access for all authenticated users"
ON scores FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert/update/delete for own scores"
ON scores FOR ALL
TO authenticated
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());