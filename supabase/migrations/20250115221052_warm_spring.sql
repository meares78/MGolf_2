-- Add tee columns to rounds table
ALTER TABLE rounds
ADD COLUMN IF NOT EXISTS tee_name text,
ADD COLUMN IF NOT EXISTS tee_color text;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS rounds_tee_idx ON rounds(tee_name, tee_color);

-- Create a function to get a random tee for a course
CREATE OR REPLACE FUNCTION get_random_tee(course text)
RETURNS TABLE (tee_name text, tee_color text) AS $$
BEGIN
  RETURN QUERY
  SELECT t.name, t.color
  FROM (
    VALUES
      ('Palmer', 'Tips', 'Black'),
      ('Palmer', 'Men', 'Gold'),
      ('Palmer', 'Men', 'Gold-Blue'),
      ('Palmer', 'Senior', 'Blue'),
      ('Nicklaus', 'Tips', 'Gold'),
      ('Nicklaus', 'Men', 'Gold-Blue'),
      ('Nicklaus', 'Men', 'Blue'),
      ('Nicklaus', 'Senior', 'White'),
      ('Watson', 'Tips', 'Black'),
      ('Watson', 'Men', 'Gold'),
      ('Watson', 'Men', 'Blue'),
      ('SouthernDunes', 'Tips', 'Black'),
      ('SouthernDunes', 'Men', 'Blue'),
      ('SouthernDunes', 'Men', 'White')
  ) AS t(course_name, name, color)
  WHERE t.course_name = course
  ORDER BY random()
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Update existing rounds with random tees
DO $$
DECLARE
  r RECORD;
  tee RECORD;
BEGIN
  FOR r IN SELECT id, course_name FROM rounds WHERE tee_name IS NULL OR tee_color IS NULL
  LOOP
    SELECT * INTO tee FROM get_random_tee(r.course_name);
    UPDATE rounds 
    SET tee_name = tee.tee_name,
        tee_color = tee.tee_color
    WHERE id = r.id;
  END LOOP;
END $$;