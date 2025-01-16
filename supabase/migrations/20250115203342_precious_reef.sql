/*
  # Update finalized_scores table RLS policies

  1. Changes
    - Add new RLS policy to allow admin users to manage all finalized scores
    - Keep existing policy for regular users to manage their own scores

  2. Security
    - Admins (phone numbers +18563812930 and +18563414490) can manage all finalized scores
    - Regular users can only manage their own finalized scores
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all authenticated users" ON finalized_scores;
DROP POLICY IF EXISTS "Enable insert/update for own scores" ON finalized_scores;

-- Create new policies
CREATE POLICY "Enable read access for all authenticated users"
ON finalized_scores FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable all access for admins"
ON finalized_scores FOR ALL
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

CREATE POLICY "Enable insert/update for own scores"
ON finalized_scores FOR ALL
TO authenticated
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());