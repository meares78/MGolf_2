-- Create net_scores table
CREATE TABLE net_scores (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id uuid REFERENCES rounds(id) ON DELETE CASCADE,
    auth_id uuid REFERENCES auth.users(id),
    hole_number integer NOT NULL CHECK (hole_number BETWEEN 1 AND 18),
    gross_score integer NOT NULL CHECK (gross_score > 0),
    net_score integer NOT NULL,
    hole_handicap integer NOT NULL CHECK (hole_handicap BETWEEN 1 AND 18),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(round_id, auth_id, hole_number)
);

-- Enable RLS
ALTER TABLE net_scores ENABLE ROW LEVEL SECURITY;

-- Create indexes for better performance
CREATE INDEX net_scores_round_id_idx ON net_scores(round_id);
CREATE INDEX net_scores_auth_id_idx ON net_scores(auth_id);
CREATE INDEX net_scores_hole_number_idx ON net_scores(hole_number);

-- Create updated_at trigger
CREATE TRIGGER update_net_scores_updated_at
    BEFORE UPDATE ON net_scores
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create policies
CREATE POLICY "Enable read access for all authenticated users"
ON net_scores FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable all access for admins"
ON net_scores FOR ALL
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

CREATE POLICY "Enable insert/update/delete for own scores"
ON net_scores FOR ALL
TO authenticated
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());

-- Add comments for documentation
COMMENT ON TABLE net_scores IS 'Stores hole-by-hole net scores for each player';
COMMENT ON COLUMN net_scores.gross_score IS 'Original score before handicap adjustment';
COMMENT ON COLUMN net_scores.net_score IS 'Score after handicap adjustment';
COMMENT ON COLUMN net_scores.hole_handicap IS 'Difficulty rating of the hole (1-18)';