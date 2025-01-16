/*
  # Fix RLS policies for rounds table

  1. Changes
    - Drop and recreate all RLS policies for rounds table
    - Ensure proper authentication checks
    - Add policies for all CRUD operations
*/

-- First, enable RLS on the rounds table if not already enabled
ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Users can read all rounds" ON rounds;
DROP POLICY IF EXISTS "Users can create rounds" ON rounds;
DROP POLICY IF EXISTS "Users can update their own rounds" ON rounds;

-- Create comprehensive policies
CREATE POLICY "Enable read access for authenticated users"
ON rounds FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert access for authenticated users"
ON rounds FOR INSERT
TO authenticated
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update access for authenticated users"
ON rounds FOR UPDATE
TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable delete access for authenticated users"
ON rounds FOR DELETE
TO authenticated
USING (auth.role() = 'authenticated');