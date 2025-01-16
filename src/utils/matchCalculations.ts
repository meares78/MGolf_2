import { supabase } from '../lib/supabase';

interface MatchScore {
  hole_number: number;
  strokes: number;
  net_score?: number;
}

interface TeamScore {
  front_nine: number;
  back_nine: number;
  total: number;
}

interface MatchResult {
  match_id: string;
  front_nine_winner: 'A' | 'B' | 'tie';
  back_nine_winner: 'A' | 'B' | 'tie';
  total_winner: 'A' | 'B' | 'tie';
  front_nine_amount: number;
  back_nine_amount: number;
  total_amount: number;
  birdies: Array<{
    auth_id: string;
    hole_number: number;
    amount: number;
  }>;
}

/**
 * Calculate team score for a set of holes
 */
function calculateTeamScore(
  scores: MatchScore[][],
  startHole: number,
  endHole: number,
  useNet: boolean
): number {
  let totalScore = 0;
  
  for (let hole = startHole; hole <= endHole; hole++) {
    // Get all players' scores for this hole
    const holeScores = scores.map(playerScores => 
      playerScores.find(s => s.hole_number === hole)
    ).filter(s => s) as MatchScore[];

    // Use the best score from the team for this hole
    if (holeScores.length > 0) {
      const bestScore = Math.min(
        ...holeScores.map(s => useNet ? (s.net_score || s.strokes) : s.strokes)
      );
      totalScore += bestScore;
    }
  }
  
  return totalScore;
}

/**
 * Calculate match results including Nassau scoring and birdie payouts
 */
export async function calculateMatchResults(
  matchId: string,
  useNet: boolean = false
): Promise<MatchResult> {
  try {
    // Fetch match details
    const { data: match, error: matchError } = await supabase
      .from('matches')
      .select(`
        *,
        match_players (
          auth_id,
          team
        )
      `)
      .eq('id', matchId)
      .single();

    if (matchError) throw matchError;
    if (!match) throw new Error('Match not found');

    // Get all players' scores
    const { data: scores, error: scoresError } = await supabase
      .from(useNet ? 'net_scores' : 'scores')
      .select('*')
      .eq('round_id', match.round_id)
      .in('auth_id', match.match_players.map(p => p.auth_id));

    if (scoresError) throw scoresError;
    if (!scores) throw new Error('No scores found');

    // Group scores by team
    const teamAScores = match.match_players
      .filter(p => p.team === 'A')
      .map(p => scores.filter(s => s.auth_id === p.auth_id));

    const teamBScores = match.match_players
      .filter(p => p.team === 'B')
      .map(p => scores.filter(s => s.auth_id === p.auth_id));

    // Calculate segment scores
    const teamA: TeamScore = {
      front_nine: calculateTeamScore(teamAScores, 1, 9, useNet),
      back_nine: calculateTeamScore(teamAScores, 10, 18, useNet),
      total: 0
    };
    teamA.total = teamA.front_nine + teamA.back_nine;

    const teamB: TeamScore = {
      front_nine: calculateTeamScore(teamBScores, 1, 9, useNet),
      back_nine: calculateTeamScore(teamBScores, 10, 18, useNet),
      total: 0
    };
    teamB.total = teamB.front_nine + teamB.back_nine;

    // Determine winners (lower score wins in golf)
    const result: MatchResult = {
      match_id: matchId,
      front_nine_winner: teamA.front_nine < teamB.front_nine ? 'A' : 
                        teamA.front_nine > teamB.front_nine ? 'B' : 'tie',
      back_nine_winner: teamA.back_nine < teamB.back_nine ? 'A' : 
                       teamA.back_nine > teamB.back_nine ? 'B' : 'tie',
      total_winner: teamA.total < teamB.total ? 'A' : 
                   teamA.total > teamB.total ? 'B' : 'tie',
      front_nine_amount: match.front_nine_bet,
      back_nine_amount: match.back_nine_bet,
      total_amount: match.total_bet,
      birdies: []
    };

    // Calculate birdie payouts
    if (!useNet) { // Only calculate birdies for gross scoring
      const { data: parInfo } = await supabase
        .from('rounds')
        .select('course_name')
        .eq('id', match.round_id)
        .single();

      if (parInfo) {
        // Get course pars
        const coursePars = {
          'Palmer': [4,3,5,4,3,4,4,4,5,5,4,4,4,3,5,3,4,4],
          'Nicklaus': [4,4,5,4,3,5,4,3,4,4,3,4,4,4,5,3,4,5],
          'Watson': [5,4,3,4,4,4,3,5,4,4,4,3,4,5,3,4,5,4],
          'SouthernDunes': [4,4,3,5,4,3,4,4,5,4,3,5,4,3,4,5,4,4]
        }[parInfo.course_name] || Array(18).fill(4);

        // Create a map to store the best score for each player on each hole
        const bestScores = new Map<string, Map<number, number>>();

        // First pass: find the best score for each player on each hole
        scores.forEach(score => {
          if (!bestScores.has(score.auth_id)) {
            bestScores.set(score.auth_id, new Map());
          }
          const playerScores = bestScores.get(score.auth_id)!;
          const currentBest = playerScores.get(score.hole_number);
          if (currentBest === undefined || score.strokes < currentBest) {
            playerScores.set(score.hole_number, score.strokes);
          }
        });

        // Second pass: identify birdies using best scores only
        bestScores.forEach((playerScores, authId) => {
          playerScores.forEach((strokes, holeNumber) => {
            const par = coursePars[holeNumber - 1];
            if (strokes < par) {
              result.birdies.push({
                auth_id: authId,
                hole_number: holeNumber,
                amount: match.birdie_bet
              });
            }
          });
        });
      }
    }

    return result;
  } catch (error) {
    console.error('Error calculating match results:', error);
    throw error;
  }
}

/**
 * Save match results to the database
 */
export async function saveMatchResults(result: MatchResult): Promise<void> {
  try {
    // Delete existing results
    await Promise.all([
      supabase
        .from('match_results')
        .delete()
        .eq('match_id', result.match_id),
      supabase
        .from('match_birdies')
        .delete()
        .eq('match_id', result.match_id)
    ]);

    // Insert team results
    const { error: resultsError } = await supabase
      .from('match_results')
      .insert([
        {
          match_id: result.match_id,
          team: 'A',
          front_nine_points: result.front_nine_winner === 'A' ? 1 : 0,
          back_nine_points: result.back_nine_winner === 'A' ? 1 : 0,
          total_points: result.total_winner === 'A' ? 1 : 0,
          front_nine_payout: result.front_nine_winner === 'A' ? result.front_nine_amount :
                           result.front_nine_winner === 'B' ? -result.front_nine_amount : 0,
          back_nine_payout: result.back_nine_winner === 'A' ? result.back_nine_amount :
                          result.back_nine_winner === 'B' ? -result.back_nine_amount : 0,
          total_payout: result.total_winner === 'A' ? result.total_amount :
                      result.total_winner === 'B' ? -result.total_amount : 0
        },
        {
          match_id: result.match_id,
          team: 'B',
          front_nine_points: result.front_nine_winner === 'B' ? 1 : 0,
          back_nine_points: result.back_nine_winner === 'B' ? 1 : 0,
          total_points: result.total_winner === 'B' ? 1 : 0,
          front_nine_payout: result.front_nine_winner === 'B' ? result.front_nine_amount :
                           result.front_nine_winner === 'A' ? -result.front_nine_amount : 0,
          back_nine_payout: result.back_nine_winner === 'B' ? result.back_nine_amount :
                          result.back_nine_winner === 'A' ? -result.back_nine_amount : 0,
          total_payout: result.total_winner === 'B' ? result.total_amount :
                      result.total_winner === 'A' ? -result.total_amount : 0
        }
      ]);

    if (resultsError) throw resultsError;

    // Save birdie results
    if (result.birdies.length > 0) {
      const { error: birdieError } = await supabase
        .from('match_birdies')
        .insert(result.birdies.map(birdie => ({
          match_id: result.match_id,
          auth_id: birdie.auth_id,
          hole_number: birdie.hole_number,
          payout: birdie.amount
        })));

      if (birdieError) throw birdieError;
    }
  } catch (error) {
    console.error('Error saving match results:', error);
    throw error;
  }
}