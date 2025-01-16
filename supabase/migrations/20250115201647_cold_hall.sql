-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON rounds;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON rounds;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON rounds;
DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON rounds;

-- Create new policies that allow any authenticated user to manage rounds
CREATE POLICY "Enable read access for all users"
ON rounds FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert for all users"
ON rounds FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Enable update for all users"
ON rounds FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable delete for all users"
ON rounds FOR DELETE
TO authenticated
USING (true);