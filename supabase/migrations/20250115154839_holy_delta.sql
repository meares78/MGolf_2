/*
  # Golf Scoring App Schema

  1. New Tables
    - `players`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `name` (text)
      - `handicap` (numeric)
      - `created_at` (timestamp)
    
    - `rounds`
      - `id` (uuid, primary key)
      - `date` (date)
      - `course_name` (text)
      - `created_at` (timestamp)
    
    - `scores`
      - `id` (uuid, primary key)
      - `round_id` (uuid, references rounds)
      - `player_id` (uuid, references players)
      - `hole_number` (integer)
      - `strokes` (integer)
      - `created_at` (timestamp)
    
    - `bets`
      - `id` (uuid, primary key)
      - `round_id` (uuid, references rounds)
      - `bet_type` (text) -- 'skins', 'nassau', 'match'
      - `amount` (numeric)
      - `created_at` (timestamp)
    
    - `bet_participants`
      - `id` (uuid, primary key)
      - `bet_id` (uuid, references bets)
      - `player_id` (uuid, references players)
      - `net_amount` (numeric)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Players table
CREATE TABLE players (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users NOT NULL,
    name text NOT NULL,
    handicap numeric DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE players ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read all players"
    ON players FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can insert their own player data"
    ON players FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own player data"
    ON players FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

-- Rounds table
CREATE TABLE rounds (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    date date NOT NULL DEFAULT CURRENT_DATE,
    course_name text NOT NULL,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read all rounds"
    ON rounds FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can create rounds"
    ON rounds FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Scores table
CREATE TABLE scores (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id uuid REFERENCES rounds NOT NULL,
    player_id uuid REFERENCES players NOT NULL,
    hole_number integer NOT NULL CHECK (hole_number BETWEEN 1 AND 18),
    strokes integer NOT NULL CHECK (strokes > 0),
    created_at timestamptz DEFAULT now(),
    UNIQUE(round_id, player_id, hole_number)
);

ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read all scores"
    ON scores FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can insert their own scores"
    ON scores FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM players
            WHERE players.id = scores.player_id
            AND players.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their own scores"
    ON scores FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM players
            WHERE players.id = scores.player_id
            AND players.user_id = auth.uid()
        )
    );

-- Bets table
CREATE TABLE bets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id uuid REFERENCES rounds NOT NULL,
    bet_type text NOT NULL CHECK (bet_type IN ('skins', 'nassau', 'match')),
    amount numeric NOT NULL CHECK (amount > 0),
    created_at timestamptz DEFAULT now()
);

ALTER TABLE bets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read all bets"
    ON bets FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can create bets"
    ON bets FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Bet participants table
CREATE TABLE bet_participants (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    bet_id uuid REFERENCES bets NOT NULL,
    player_id uuid REFERENCES players NOT NULL,
    net_amount numeric DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE bet_participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read all bet participants"
    ON bet_participants FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can update their own bet results"
    ON bet_participants FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM players
            WHERE players.id = bet_participants.player_id
            AND players.user_id = auth.uid()
        )
    );