-- Drop any conflicting policies
DROP POLICY IF EXISTS "Enable all access for admins" ON player_handicaps;
DROP POLICY IF EXISTS "Enable insert/update for admins" ON player_handicaps;

-- Create new policy that allows admins to manage handicaps
CREATE POLICY "Enable handicap management for admins"
ON player_handicaps FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM players
        WHERE players.auth_id = auth.uid()
        AND players.phone IN ('+18563812930', '+18563414490')
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM players
        WHERE players.auth_id = auth.uid()
        AND players.phone IN ('+18563812930', '+18563414490')
    )
);

-- Create index for better performance if it doesn't exist
CREATE INDEX IF NOT EXISTS player_handicaps_lookup_idx 
ON player_handicaps(player_id, course_name, tee_name);

-- DO NOT DELETE OR RE-INSERT ANY HANDICAPS
-- This migration only fixes policies and indexes