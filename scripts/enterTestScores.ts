import { createClient } from '@supabase/supabase-js';

// Create Supabase client using environment variables
const supabase = createClient(
  'https://lrrsfvngymdqmamrbtws.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxycnNmdm5neW1kcW1hbXJidHdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY5NTYyNjUsImV4cCI6MjA1MjUzMjI2NX0.e7hSTWUIntsQFVQf0tMS1UimGYYDouSS49w9CW_wEAk'
);

// Define authorized users directly in the script
const AUTHORIZED_USERS = {
  '+18563812930': { id: '1', name: 'Chris Meares' },
  '+18563414490': { id: '2', name: 'Tim Tullio' },
  '+1609579940': { id: '3', name: 'Dan Ayars' },
  '+18563696658': { id: '4', name: 'Dave Ayars' },
  '+16098203771': { id: '5', name: 'Gil Moniz' },
  '+18563050314': { id: '6', name: 'Rocky Dare' },
  '+18568168735': { id: '7', name: 'Joe Zulli' },
  '+18564197121': { id: '8', name: 'Ryan Cass' },
  '+18569046062': { id: '9', name: 'Joey Russo' },
  '+18564667354': { id: '10', name: "John O'Brien" },
  '+16099328795': { id: '11', name: 'Ed Kochanek' },
  '+18562292916': { id: '12', name: 'Jimmy Gillespie' }
};

// Define all rounds
const ROUNDS = [
  { id: 'mon-1', courseName: 'Nicklaus', date: '2025-02-10' },
  { id: 'tue-1', courseName: 'Watson', date: '2025-02-11' },
  { id: 'wed-1', courseName: 'Watson', date: '2025-02-12' },
  { id: 'thu-1', courseName: 'SouthernDunes', date: '2025-02-13' },
  { id: 'fri-1', courseName: 'Palmer', date: '2025-02-14' },
  { id: 'sat-1', courseName: 'Nicklaus', date: '2025-02-15' },
  { id: 'sun-1', courseName: 'Nicklaus', date: '2025-02-16' }
];

// Function to get random par 3 holes for twos
function getRandomPar3s(count: number): number[] {
  // Common par 3 holes across courses (typical holes: 3, 5, 7, 12, 14, 16)
  const par3Holes = [3, 5, 7, 12, 14, 16];
  const shuffled = [...par3Holes].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, count);
}

async function enterTestScores() {
  try {
    // Sign in as an admin user first
    const { error: signInError } = await supabase.auth.signInWithPassword({
      email: 'user1@golfbuddy.app',  // Chris Meares (admin)
      password: 'GolfBuddy1!2025'
    });

    if (signInError) throw signInError;

    // Process each round
    for (const round of ROUNDS) {
      console.log(`\nProcessing round: ${round.courseName} - ${round.date}`);

      // First, ensure the round exists
      const { data: existingRound, error: checkError } = await supabase
        .from('rounds')
        .select('id')
        .eq('external_id', round.id)
        .maybeSingle();

      if (checkError) throw checkError;

      let roundId: string;

      if (!existingRound) {
        // Create the round if it doesn't exist
        const { data: newRound, error: createError } = await supabase
          .from('rounds')
          .insert({
            external_id: round.id,
            course_name: round.courseName,
            date: round.date
          })
          .select()
          .single();

        if (createError) throw createError;
        if (!newRound) throw new Error('Failed to create round');

        roundId = newRound.id;
        console.log('Created new round:', roundId);
      } else {
        roundId = existingRound.id;
        console.log('Using existing round:', roundId);
      }

      // Select 4 random players to get twos on par 3s
      const playerPhones = Object.keys(AUTHORIZED_USERS);
      const playersWithTwos = playerPhones
        .sort(() => Math.random() - 0.5)
        .slice(0, 4);

      // For each player with a two, assign them one random par 3
      const twoAssignments = new Map<string, number[]>();
      const par3Holes = getRandomPar3s(4);
      playersWithTwos.forEach((phone, index) => {
        twoAssignments.set(phone, [par3Holes[index]]);
      });

      // Base scores for each player (par golf with typical variations)
      const baseScores = {
        // Chris Meares - Consistently good rounds
        '+18563812930': [4,4,5,4,3,4,4,4,5,4,3,4,4,4,5,3,4,4],
        // Tim Tullio - Good rounds with occasional brilliance
        '+18563414490': [4,4,5,5,3,5,4,3,4,4,3,4,4,4,5,3,4,5],
        // Dan Ayars - Steady player
        '+1609579940': [4,4,5,4,3,5,4,3,4,5,3,4,4,4,5,3,4,5],
        // Dave Ayars - Good front nine, struggles on back
        '+18563696658': [4,4,5,4,3,4,4,4,5,5,4,5,5,4,6,3,5,5],
        // Gil Moniz - Consistent player
        '+16098203771': [4,5,5,4,3,5,4,3,4,4,3,4,4,4,5,3,4,5],
        // Rocky Dare - Great rounds with multiple birdies
        '+18563050314': [3,4,5,4,3,4,4,3,4,4,3,4,4,3,5,3,4,4],
        // Joe Zulli - Decent rounds
        '+18568168735': [4,4,5,5,3,5,4,4,5,4,3,4,4,4,5,3,4,5],
        // Ryan Cass - Some struggles
        '+18564197121': [5,5,6,4,3,5,4,4,5,5,4,4,5,4,5,4,4,5],
        // Joey Russo - Very good rounds
        '+18569046062': [4,4,4,4,3,4,4,3,5,4,3,4,4,3,5,3,4,4],
        // John O'Brien - Up and down
        '+18564667354': [5,4,5,5,3,4,4,4,5,4,3,5,4,4,6,3,4,5],
        // Ed Kochanek - Solid rounds
        '+16099328795': [4,4,5,4,3,5,4,4,5,4,3,4,4,4,5,3,4,5],
        // Jimmy Gillespie - Good with occasional struggles
        '+18562292916': [4,5,5,4,3,5,4,4,5,5,3,4,4,4,5,4,4,5]
      };

      // Delete any existing scores for this round
      await supabase
        .from('scores')
        .delete()
        .eq('round_id', roundId);

      // Delete any existing finalized scores for this round
      await supabase
        .from('finalized_scores')
        .delete()
        .eq('round_id', roundId);

      // Insert scores for each player
      for (const [phone, scores] of Object.entries(baseScores)) {
        const user = AUTHORIZED_USERS[phone];
        if (!user) continue;

        // Get the player's auth_id
        const { data: player } = await supabase
          .from('players')
          .select('auth_id')
          .eq('phone', phone)
          .single();

        if (!player) {
          console.log(`Skipping ${user.name} - player not found`);
          continue;
        }

        console.log(`Entering scores for ${user.name}...`);

        // Get this player's two assignments
        const twoHoles = twoAssignments.get(phone) || [];

        // Modify scores with random variations and assigned twos
        const roundScores = scores.map((score, index) => {
          const holeNumber = index + 1;
          
          // If this is a hole where the player gets a two
          if (twoHoles.includes(holeNumber)) {
            return 2;
          }
          
          // Add some randomization to other scores (-1, 0, or +1)
          const variation = Math.floor(Math.random() * 3) - 1;
          return Math.max(1, score + variation);
        });

        // Create score records
        const scoreRecords = roundScores.map((strokes, index) => ({
          round_id: roundId,
          auth_id: player.auth_id,
          hole_number: index + 1,
          strokes
        }));

        // Insert scores
        const { error: scoresError } = await supabase
          .from('scores')
          .insert(scoreRecords);

        if (scoresError) throw scoresError;

        // Calculate totals
        const totalGross = roundScores.reduce((sum, score) => sum + score, 0);
        
        // Insert finalized score
        const { error: finalizedError } = await supabase
          .from('finalized_scores')
          .insert({
            round_id: roundId,
            auth_id: player.auth_id,
            total_gross: totalGross,
            total_net: totalGross, // For now, using gross as net since handicaps aren't set
            course_handicap: 0, // Will be updated later when handicaps are set
            finalized_at: new Date().toISOString()
          });

        if (finalizedError) throw finalizedError;
      }

      console.log(`Completed round: ${round.courseName} - ${round.date}`);
    }

    console.log('\nTest scores entered successfully for all rounds!');
  } catch (error) {
    console.error('Error entering test scores:', error);
    process.exit(1);
  } finally {
    // Sign out and exit
    await supabase.auth.signOut();
    process.exit(0);
  }
}

// Run the script and handle any unhandled promise rejections
enterTestScores().catch(error => {
  console.error('Unhandled error:', error);
  process.exit(1);
});