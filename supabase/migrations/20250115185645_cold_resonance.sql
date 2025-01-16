/*
  # Add authorized players

  1. Changes
    - Insert all authorized players with proper auth user creation
*/

-- Insert players with auth users
DO $$
DECLARE
  auth_id uuid;
BEGIN
  -- Chris Meares
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user1@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user1@golfbuddy.app',
      crypt('GolfBuddy1!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+18563812930') THEN
    INSERT INTO players (auth_id, name, phone) 
    VALUES (auth_id, 'Chris Meares', '+18563812930');
  END IF;

  -- Tim Tullio
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user2@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user2@golfbuddy.app',
      crypt('GolfBuddy2!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+18563414490') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'Tim Tullio', '+18563414490');
  END IF;

  -- Dan Ayars
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user3@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user3@golfbuddy.app',
      crypt('GolfBuddy3!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+1609579940') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'Dan Ayars', '+1609579940');
  END IF;

  -- Dave Ayars
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user4@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user4@golfbuddy.app',
      crypt('GolfBuddy4!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+18563696658') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'Dave Ayars', '+18563696658');
  END IF;

  -- Gil Moniz
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user5@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user5@golfbuddy.app',
      crypt('GolfBuddy5!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+16098203771') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'Gil Moniz', '+16098203771');
  END IF;

  -- Rocky Dare
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user6@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user6@golfbuddy.app',
      crypt('GolfBuddy6!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+18563050314') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'Rocky Dare', '+18563050314');
  END IF;

  -- Joe Zulli
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user7@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user7@golfbuddy.app',
      crypt('GolfBuddy7!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+18568168735') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'Joe Zulli', '+18568168735');
  END IF;

  -- Ryan Cass
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user8@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user8@golfbuddy.app',
      crypt('GolfBuddy8!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+18564197121') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'Ryan Cass', '+18564197121');
  END IF;

  -- Joey Russo
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user9@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user9@golfbuddy.app',
      crypt('GolfBuddy9!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+18569046062') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'Joey Russo', '+18569046062');
  END IF;

  -- John O'Brien
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user10@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user10@golfbuddy.app',
      crypt('GolfBuddy10!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+18564667354') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'John O''Brien', '+18564667354');
  END IF;

  -- Ed Kochanek
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user11@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user11@golfbuddy.app',
      crypt('GolfBuddy11!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+16099328795') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'Ed Kochanek', '+16099328795');
  END IF;

  -- Jimmy Gillespie
  auth_id := gen_random_uuid();
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user12@golfbuddy.app') THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud
    ) VALUES (
      auth_id,
      '00000000-0000-0000-0000-000000000000',
      'user12@golfbuddy.app',
      crypt('GolfBuddy12!2025', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM players WHERE phone = '+18562292916') THEN
    INSERT INTO players (auth_id, name, phone)
    VALUES (auth_id, 'Jimmy Gillespie', '+18562292916');
  END IF;
END $$;