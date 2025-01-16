/**
 * Calculate the payout for a given position or tied positions
 * @param position Position (1-3)
 * @param tiedPlayers Number of players tied for this position
 * @returns Payout amount per player
 */
export function calculatePositionPayout(position: number, tiedPlayers: number = 1): number {
  // Base payouts
  const PAYOUTS = {
    1: 120,
    2: 80,
    3: 40
  };

  if (tiedPlayers === 1) {
    return PAYOUTS[position as keyof typeof PAYOUTS] || 0;
  }

  // Handle ties by combining prize money for affected positions
  let totalPrizePool = 0;

  // For first place ties, combine money for all positions that would be taken by tied players
  if (position === 1) {
    for (let i = 1; i <= Math.min(tiedPlayers, 3); i++) {
      totalPrizePool += PAYOUTS[i as keyof typeof PAYOUTS];
    }
  }
  // For second place ties
  else if (position === 2) {
    totalPrizePool = PAYOUTS[2] + PAYOUTS[3]; // Combine 2nd and 3rd place money
  }
  // For third place ties
  else if (position === 3) {
    totalPrizePool = PAYOUTS[3];
  }

  // Split the total prize pool evenly among tied players
  return Math.floor(totalPrizePool / tiedPlayers);
}

/**
 * Calculate skin payouts
 * @param numSkins Number of skins won
 * @returns Payout per skin
 */
export function calculateSkinPayout(numSkins: number): number {
  if (numSkins === 0) return 0;
  return Math.floor(120 / numSkins); // $120 pot divided by number of skins
}

/**
 * Calculate two payouts
 * @param numTwos Number of twos scored
 * @returns Payout per two
 */
export function calculateTwoPayout(numTwos: number): number {
  if (numTwos === 0) return 0;
  return Math.floor(120 / numTwos); // $120 pot divided by number of twos
}

/**
 * Sort and group scores for position calculation
 * @param scores Array of scores with net and gross values
 * @returns Array of groups of tied players, sorted by position
 */
export function sortScoresForPositions(scores: Array<{ net_score: number; gross_score: number; auth_id: string }>) {
  // First sort all scores
  const sortedScores = [...scores].sort((a, b) => {
    // Sort by net score first
    if (a.net_score !== b.net_score) {
      return a.net_score - b.net_score;
    }
    // If net scores are tied, sort by gross score
    return a.gross_score - b.gross_score;
  });

  // Group tied players
  const tiedGroups: Array<{
    position: number;
    players: typeof sortedScores;
  }> = [];

  let currentPosition = 1;
  let currentGroup: typeof sortedScores = [];
  let lastScore = { net_score: -1, gross_score: -1 };

  sortedScores.forEach((score) => {
    // If this score is different from the last one, start a new group
    if (score.net_score !== lastScore.net_score) {
      if (currentGroup.length > 0) {
        tiedGroups.push({
          position: currentPosition,
          players: currentGroup
        });
        currentPosition += currentGroup.length;
      }
      currentGroup = [score];
    } else {
      currentGroup.push(score);
    }
    lastScore = score;
  });

  // Add the last group
  if (currentGroup.length > 0) {
    tiedGroups.push({
      position: currentPosition,
      players: currentGroup
    });
  }

  return tiedGroups;
}