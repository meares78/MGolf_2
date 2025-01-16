// Helper function to match tees based on ID
export function matchTeeFromId(teeId: string, courseName: string, tees: Array<{ name: string; color: string }>) {
  // Extract course name and tee info from ID
  // Format: "coursename-teename-color" (e.g., "nicklaus-men-gb")
  const [courseSlug, teeName, teeColor] = teeId.split('-');

  return tees.find(t => {
    // Match by name first
    const nameMatches = t.name.toLowerCase() === teeName?.toLowerCase();
    
    // Then check color match if provided
    let colorMatches = false;
    if (teeColor) {
      if (t.color.includes('/')) {
        // For compound colors (e.g., "gold/blue"), match with "gb"
        colorMatches = teeColor === 'gb';
      } else {
        // For simple colors, match directly
        colorMatches = t.color.toLowerCase() === teeColor.toLowerCase();
      }
    } else {
      // If no color in ID, just match by name
      colorMatches = true;
    }
    
    return nameMatches && colorMatches;
  });
}