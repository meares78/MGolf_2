/*
  # Fix RLS policies for rounds table - Final Version

  1. Changes
    - Drop and recreate all RLS policies for rounds table
    - Ensure proper authentication checks using auth.uid()
    - Add policies for all CRUD operations
    - Add proper user checks
*/

-- First, enable RLS on the rounds table if not already enabled
ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON rounds;
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON rounds;
DROP POLICY IF EXISTS "Enable update access for authenticated users" ON rounds;
DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON rounds;

-- Create comprehensive policies with proper auth checks
CREATE POLICY "Enable read access for authenticated users"
ON rounds FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert access for authenticated users"
ON rounds FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable update access for authenticated users"
ON rounds FOR UPDATE
TO authenticated
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable delete access for authenticated users"
ON rounds FOR DELETE
TO authenticated
USING (auth.uid() IS NOT NULL);

-- Add an index on external_id for better performance
CREATE INDEX IF NOT EXISTS rounds_external_id_idx ON rounds(external_id);

-- Add an index on created_by for better performance
CREATE INDEX IF NOT EXISTS rounds_created_by_idx ON rounds(created_by);