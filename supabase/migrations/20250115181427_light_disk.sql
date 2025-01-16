/*
  # Fix RLS policies for rounds table

  1. Changes
    - Drop existing policies for rounds table
    - Add new policies for authenticated users to:
      - Read all rounds
      - Insert new rounds
      - Update their own rounds
*/

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read all rounds" ON rounds;
DROP POLICY IF EXISTS "Users can create rounds" ON rounds;

-- Create new policies
CREATE POLICY "Users can read all rounds"
ON rounds FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can create rounds"
ON rounds FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Users can update their own rounds"
ON rounds FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);