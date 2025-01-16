/*
  # Fix round ID handling

  1. Changes
    - Add external_id column to rounds table
    - Update rounds table to use external_id for lookups
    - Add indexes for better performance
*/

-- First ensure RLS is enabled
ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;

-- Add external_id column if it doesn't exist
ALTER TABLE rounds ADD COLUMN IF NOT EXISTS external_id text UNIQUE;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS rounds_external_id_idx ON rounds(external_id);

-- Insert rounds for the tournament
INSERT INTO rounds (external_id, course_name, date)
VALUES 
  ('mon-1', 'Nicklaus', '2025-02-10'),
  ('tue-1', 'Watson', '2025-02-11'),
  ('tue-2', 'Nicklaus', '2025-02-11'),
  ('wed-1', 'Watson', '2025-02-12'),
  ('wed-2', 'Palmer', '2025-02-12'),
  ('thu-1', 'SouthernDunes', '2025-02-13'),
  ('fri-1', 'Palmer', '2025-02-14'),
  ('fri-2', 'Watson', '2025-02-14'),
  ('sat-1', 'Nicklaus', '2025-02-15'),
  ('sat-2', 'Palmer', '2025-02-15'),
  ('sun-1', 'Nicklaus', '2025-02-16')
ON CONFLICT (external_id) DO UPDATE
SET course_name = EXCLUDED.course_name,
    date = EXCLUDED.date;