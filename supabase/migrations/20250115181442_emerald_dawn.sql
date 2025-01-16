/*
  # Add created_by to rounds table

  1. Changes
    - Add created_by column to rounds table to track who created each round
*/

ALTER TABLE rounds ADD COLUMN IF NOT EXISTS created_by text;