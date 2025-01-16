import { supabase } from '../lib/supabase';

interface HoleScore {
  hole_number: number;
  strokes: number;
  hole_handicap: number;
}

interface PlayerScore {
  auth_id: string;
  round_id: string;
  course_handicap: number;
  scores: HoleScore[];
}

/**
 * Calculate net scores for a player based on their handicap and hole difficulty
 * @param playerScore Player's score information including handicap and hole scores
 * @returns Array of net scores for each hole
 */
export async function calculateNetScores(playerScore: PlayerScore): Promise<HoleScore[]> {
  const { course_handicap, scores } = playerScore;
  
  // Sort holes by handicap (difficulty)
  const sortedHoles = [...scores].sort((a, b) => a.hole_handicap - b.hole_handicap);
  
  // Calculate how many strokes to give/take
  const netScores = scores.map(score => ({
    ...score,
    net_strokes: score.strokes
  }));

  if (course_handicap > 0) {
    // Player gets strokes (positive handicap)
    let strokesRemaining = course_handicap;
    let currentHandicapIndex = 0;

    // Distribute strokes starting with most difficult holes
    while (strokesRemaining > 0 && currentHandicapIndex < 18) {
      const targetHoleHandicap = sortedHoles[currentHandicapIndex].hole_handicap;
      const holeScore = netScores.find(s => s.hole_handicap === targetHoleHandicap);
      if (holeScore) {
        holeScore.net_strokes--;
      }
      strokesRemaining--;
      currentHandicapIndex++;
      
      // If we've used all 18 holes and still have strokes, start over
      if (currentHandicapIndex === 18 && strokesRemaining > 0) {
        currentHandicapIndex = 0;
      }
    }
  } else if (course_handicap < 0) {
    // Player gives strokes (negative handicap)
    let strokesToAdd = Math.abs(course_handicap);
    let currentHandicapIndex = 17; // Start with easiest holes

    // Add strokes starting with easiest holes
    while (strokesToAdd > 0 && currentHandicapIndex >= 0) {
      const targetHoleHandicap = sortedHoles[currentHandicapIndex].hole_handicap;
      const holeScore = netScores.find(s => s.hole_handicap === targetHoleHandicap);
      if (holeScore) {
        holeScore.net_strokes++;
      }
      strokesToAdd--;
      currentHandicapIndex--;
      
      // If we've used all 18 holes and still have strokes, start over
      if (currentHandicapIndex === -1 && strokesToAdd > 0) {
        currentHandicapIndex = 17;
      }
    }
  }

  return netScores;
}

/**
 * Save net scores to the database
 * @param playerScore Player's score information
 * @param netScores Calculated net scores for each hole
 */
export async function saveNetScores(
  playerScore: PlayerScore,
  netScores: HoleScore[]
): Promise<void> {
  const { data: existingScores, error: fetchError } = await supabase
    .from('net_scores')
    .select('*')
    .eq('round_id', playerScore.round_id)
    .eq('auth_id', playerScore.auth_id);

  if (fetchError) throw fetchError;

  // If scores exist, update them
  if (existingScores && existingScores.length > 0) {
    const { error: updateError } = await supabase
      .from('net_scores')
      .upsert(
        netScores.map(score => ({
          round_id: playerScore.round_id,
          auth_id: playerScore.auth_id,
          hole_number: score.hole_number,
          gross_score: score.strokes,
          net_score: score.net_strokes,
          hole_handicap: score.hole_handicap
        }))
      );

    if (updateError) throw updateError;
  } else {
    // Insert new scores
    const { error: insertError } = await supabase
      .from('net_scores')
      .insert(
        netScores.map(score => ({
          round_id: playerScore.round_id,
          auth_id: playerScore.auth_id,
          hole_number: score.hole_number,
          gross_score: score.strokes,
          net_score: score.net_strokes,
          hole_handicap: score.hole_handicap
        }))
      );

    if (insertError) throw insertError;
  }
}

/**
 * Compare net scores between two players for match play
 * @param roundId Round identifier
 * @param player1Id First player's auth ID
 * @param player2Id Second player's auth ID
 * @returns Hole-by-hole comparison of net scores
 */
export async function compareNetScores(
  roundId: string,
  player1Id: string,
  player2Id: string
): Promise<{
  hole_number: number;
  player1_net: number;
  player2_net: number;
  difference: number;
}[]> {
  const { data: scores, error } = await supabase
    .from('net_scores')
    .select('*')
    .eq('round_id', roundId)
    .in('auth_id', [player1Id, player2Id]);

  if (error) throw error;

  const comparison = [];
  for (let hole = 1; hole <= 18; hole++) {
    const player1Score = scores.find(
      s => s.auth_id === player1Id && s.hole_number === hole
    );
    const player2Score = scores.find(
      s => s.auth_id === player2Id && s.hole_number === hole
    );

    if (player1Score && player2Score) {
      comparison.push({
        hole_number: hole,
        player1_net: player1Score.net_score,
        player2_net: player2Score.net_score,
        difference: player1Score.net_score - player2Score.net_score
      });
    }
  }

  return comparison;
}