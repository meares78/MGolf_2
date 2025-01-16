/*
  # Update RLS policies for rounds table

  1. Changes
    - Drop existing restrictive policies
    - Create new policies that allow any authenticated user to manage rounds
    - Policies cover SELECT, INSERT, UPDATE, and DELETE operations
    - Ensure auth.uid() is available for all operations
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

-- Add created_by column if it doesn't exist
ALTER TABLE rounds ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES auth.users(id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS rounds_created_by_idx ON rounds(created_by);