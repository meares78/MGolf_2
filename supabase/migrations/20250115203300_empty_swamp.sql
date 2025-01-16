/*
  # Update scores table RLS policies

  1. Changes
    - Add new RLS policy to allow admin users to manage all scores
    - Keep existing policy for regular users to manage their own scores

  2. Security
    - Admins (phone numbers +18563812930 and +18563414490) can manage all scores
    - Regular users can only manage their own scores
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all authenticated users" ON scores;
DROP POLICY IF EXISTS "Enable insert/update/delete for own scores" ON scores;

-- Create new policies
CREATE POLICY "Enable read access for all authenticated users"
ON scores FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable all access for admins"
ON scores FOR ALL
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

CREATE POLICY "Enable insert/update/delete for own scores"
ON scores FOR ALL
TO authenticated
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());