-- Create finalized_scores table
CREATE TABLE finalized_scores (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id uuid REFERENCES rounds(id) ON DELETE CASCADE,
    auth_id uuid REFERENCES auth.users(id),
    total_gross integer NOT NULL,
    total_net integer NOT NULL,
    course_handicap integer NOT NULL,
    finalized_at timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now(),
    UNIQUE(round_id, auth_id)
);

-- Enable RLS
ALTER TABLE finalized_scores ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX finalized_scores_round_id_idx ON finalized_scores(round_id);
CREATE INDEX finalized_scores_auth_id_idx ON finalized_scores(auth_id);

-- Create policies
CREATE POLICY "Enable read access for all authenticated users"
ON finalized_scores FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert/update for own scores"
ON finalized_scores FOR ALL
TO authenticated
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());