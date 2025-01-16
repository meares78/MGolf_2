/**
 * Calculate the course handicap for a player
 * @param handicapIndex The player's handicap index
 * @param slope The slope rating of the tees being played
 * @param rating The course rating of the tees being played
 * @param par The par for the course
 * @returns The player's course handicap for the selected tees
 */
export function calculateCourseHandicap(
  handicapIndex: number,
  slope: number,
  rating: number,
  par: number
): number {
  return Math.round(handicapIndex * (slope / 113) + (rating - par));
}

/**
 * Get the holes where a player receives strokes based on their course handicap
 * @param courseHandicap The player's course handicap
 * @param handicapHoles Array of hole numbers in handicap order (1-18)
 * @returns Map of hole numbers to strokes received
 */
export function getHandicapStrokes(
  courseHandicap: number,
  handicapHoles: number[]
): Map<number, number> {
  const strokesMap = new Map<number, number>();
  
  // Handle negative handicaps
  if (courseHandicap <= 0) {
    handicapHoles.forEach(hole => strokesMap.set(hole, 0));
    return strokesMap;
  }

  // Assign strokes based on handicap
  let remainingStrokes = courseHandicap;
  let currentRound = 1;

  while (remainingStrokes > 0) {
    for (const hole of handicapHoles) {
      if (remainingStrokes <= 0) break;
      
      strokesMap.set(
        hole,
        (strokesMap.get(hole) || 0) + 1
      );
      remainingStrokes--;
    }
    currentRound++;
  }

  return strokesMap;
}