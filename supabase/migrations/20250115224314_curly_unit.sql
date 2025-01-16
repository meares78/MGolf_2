-- Drop existing tables to recreate with correct schema
DROP TABLE IF EXISTS bet_participants CASCADE;
DROP TABLE IF EXISTS bets CASCADE;

-- Create bets table
CREATE TABLE bets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id uuid REFERENCES rounds(id) ON DELETE CASCADE,
    bet_type text NOT NULL CHECK (bet_type IN ('1v1', '2v2', '4v4')),
    amount numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create bet_participants table
CREATE TABLE bet_participants (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    bet_id uuid REFERENCES bets(id) ON DELETE CASCADE,
    auth_id uuid REFERENCES auth.users(id),
    team text NOT NULL CHECK (team IN ('A', 'B')),
    net_amount numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE bets ENABLE ROW LEVEL SECURITY;
ALTER TABLE bet_participants ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX bets_round_id_idx ON bets(round_id);
CREATE INDEX bet_participants_bet_id_idx ON bet_participants(bet_id);
CREATE INDEX bet_participants_auth_id_idx ON bet_participants(auth_id);

-- Create updated_at triggers
CREATE TRIGGER update_bets_updated_at
    BEFORE UPDATE ON bets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bet_participants_updated_at
    BEFORE UPDATE ON bet_participants
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create policies
CREATE POLICY "Enable read access for all authenticated users"
ON bets FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable read access for all authenticated users"
ON bet_participants FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable all access for authenticated users"
ON bets FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable all access for authenticated users"
ON bet_participants FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);