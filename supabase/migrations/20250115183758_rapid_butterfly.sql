/*
  # Update rounds table to handle external IDs

  1. Changes
    - Add external_id column to rounds table for storing string IDs
    - Update RLS policies to handle external IDs
    - Add index for better performance

  2. Security
    - Maintain existing RLS policies
    - Add new policies for external ID handling
*/

-- First ensure RLS is enabled
ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;

-- Add external_id column if it doesn't exist
ALTER TABLE rounds ADD COLUMN IF NOT EXISTS external_id text UNIQUE;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS rounds_external_id_idx ON rounds(external_id);

-- Update or create policies
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON rounds;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON rounds;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON rounds;

CREATE POLICY "Enable read access for authenticated users"
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