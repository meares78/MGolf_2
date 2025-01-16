-- Drop the unique constraint that's causing issues
ALTER TABLE round_results
DROP CONSTRAINT IF EXISTS round_results_round_id_position_key;

-- Add a new index for better query performance
CREATE INDEX IF NOT EXISTS round_results_position_idx ON round_results(round_id, position);

-- Update the round_results table to handle ties correctly
COMMENT ON TABLE round_results IS 'Stores round results with support for ties. Multiple players can share the same position.';
COMMENT ON COLUMN round_results.position IS 'Position (1-3). Multiple players can have the same position in case of ties.';