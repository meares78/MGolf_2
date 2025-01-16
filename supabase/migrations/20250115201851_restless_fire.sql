/*
  # Update RLS policies for rounds table

  1. Changes
    - Drop existing restrictive policies
    - Create new policies that allow any authenticated user to manage rounds
    - Policies cover SELECT, INSERT, UPDATE, and DELETE operations
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON rounds;
DROP POLICY IF EXISTS "Enable insert for all users" ON rounds;
DROP POLICY IF EXISTS "Enable update for all users" ON rounds;
DROP POLICY IF EXISTS "Enable delete for all users" ON rounds;

-- Create new policies that allow any authenticated user to manage rounds
CREATE POLICY "Enable read access for all users"
ON rounds FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert for all users"
ON rounds FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable update for all users"
ON rounds FOR UPDATE
TO authenticated
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable delete for all users"
ON rounds FOR DELETE
TO authenticated
USING (auth.uid() IS NOT NULL);