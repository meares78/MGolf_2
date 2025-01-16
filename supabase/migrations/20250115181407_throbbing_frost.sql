/*
  # Add external_id to rounds table

  1. Changes
    - Add external_id column to rounds table for mapping to local IDs
    - Add unique constraint on external_id
*/

ALTER TABLE rounds ADD COLUMN IF NOT EXISTS external_id text UNIQUE;