import { Course } from '../types';

export const courses: Course[] = [
  {
    name: 'Palmer',
    tees: [
      {
        name: 'Tips',
        color: 'black',
        totalPar: 72,
        totalDistance: 6916,
        rating: 73.6,
        slope: 141,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,3,5,4,3,4,4,4,5,5,4,4,4,3,5,3,4,4][i],
          handicap: [5,11,9,15,13,7,17,1,3,6,14,8,2,18,12,16,10,4][i],
          distance: 0
        }))
      },
      {
        name: 'Men',
        color: 'gold',
        totalPar: 72,
        totalDistance: 6419,
        rating: 70.9,
        slope: 133,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,3,5,4,3,4,4,4,5,5,4,4,4,3,5,3,4,4][i],
          handicap: [5,11,9,15,13,7,17,1,3,6,14,8,2,18,12,16,10,4][i],
          distance: 0
        }))
      },
      {
        name: 'Men',
        color: 'gold/blue',
        totalPar: 72,
        totalDistance: 6225,
        rating: 70.1,
        slope: 130,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,3,5,4,3,4,4,4,5,5,4,4,4,3,5,3,4,4][i],
          handicap: [5,11,9,15,13,7,17,1,3,6,14,8,2,18,12,16,10,4][i],
          distance: 0
        }))
      },
      {
        name: 'Senior',
        color: 'blue',
        totalPar: 72,
        totalDistance: 6058,
        rating: 69.5,
        slope: 127,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,3,5,4,3,4,4,4,5,5,4,4,4,3,5,3,4,4][i],
          handicap: [5,11,9,15,13,7,17,1,3,6,14,8,2,18,12,16,10,4][i],
          distance: 0
        }))
      }
    ]
  },
  {
    name: 'Nicklaus',
    tees: [
      {
        name: 'Tips',
        color: 'gold',
        totalPar: 72,
        totalDistance: 7219,
        rating: 74.8,
        slope: 140,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,4,5,4,3,5,4,3,4,4,3,4,4,4,5,3,4,5][i],
          handicap: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16][i],
          distance: 0
        }))
      },
      {
        name: 'Men',
        color: 'gold/blue',
        totalPar: 72,
        totalDistance: 6816,
        rating: 73.0,
        slope: 135,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,4,5,4,3,5,4,3,4,4,3,4,4,4,5,3,4,5][i],
          handicap: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16][i],
          distance: 0
        }))
      },
      {
        name: 'Men',
        color: 'blue',
        totalPar: 72,
        totalDistance: 6471,
        rating: 71.4,
        slope: 133,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,4,5,4,3,5,4,3,4,4,3,4,4,4,5,3,4,5][i],
          handicap: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16][i],
          distance: 0
        }))
      },
      {
        name: 'Senior',
        color: 'white',
        totalPar: 72,
        totalDistance: 6205,
        rating: 69.8,
        slope: 129,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,4,5,4,3,5,4,3,4,4,3,4,4,4,5,3,4,5][i],
          handicap: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16][i],
          distance: 0
        }))
      }
    ]
  },
  {
    name: 'Watson',
    tees: [
      {
        name: 'Tips',
        color: 'black',
        totalPar: 72,
        totalDistance: 7154,
        rating: 75.0,
        slope: 136,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [5,4,3,4,4,4,3,5,4,4,4,3,4,5,3,4,5,4][i],
          handicap: [5,9,17,1,3,15,11,7,13,2,10,16,14,18,12,4,8,6][i],
          distance: 0
        }))
      },
      {
        name: 'Men',
        color: 'gold',
        totalPar: 72,
        totalDistance: 6697,
        rating: 72.9,
        slope: 132,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [5,4,3,4,4,4,3,5,4,4,4,3,4,5,3,4,5,4][i],
          handicap: [5,9,17,1,3,15,11,7,13,2,10,16,14,18,12,4,8,6][i],
          distance: 0
        }))
      },
      {
        name: 'Men',
        color: 'blue',
        totalPar: 72,
        totalDistance: 6319,
        rating: 70.8,
        slope: 126,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [5,4,3,4,4,4,3,5,4,4,4,3,4,5,3,4,5,4][i],
          handicap: [5,9,17,1,3,15,11,7,13,2,10,16,14,18,12,4,8,6][i],
          distance: 0
        }))
      }
    ]
  },
  {
    name: 'SouthernDunes',
    tees: [
      {
        name: 'Tips',
        color: 'black',
        totalPar: 72,
        totalDistance: 7192,
        rating: 75.0,
        slope: 140,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,4,3,5,4,3,4,4,5,4,3,5,4,3,4,5,4,4][i],
          handicap: [9,15,11,5,7,17,1,13,3,2,16,6,8,18,14,4,12,10][i],
          distance: 0
        }))
      },
      {
        name: 'Men',
        color: 'blue',
        totalPar: 72,
        totalDistance: 6737,
        rating: 72.9,
        slope: 136,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,4,3,5,4,3,4,4,5,4,3,5,4,3,4,5,4,4][i],
          handicap: [9,15,11,5,7,17,1,13,3,2,16,6,8,18,14,4,12,10][i],
          distance: 0
        }))
      },
      {
        name: 'Men',
        color: 'white',
        totalPar: 72,
        totalDistance: 6220,
        rating: 70.4,
        slope: 133,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,4,3,5,4,3,4,4,5,4,3,5,4,3,4,5,4,4][i],
          handicap: [9,15,11,5,7,17,1,13,3,2,16,6,8,18,14,4,12,10][i],
          distance: 0
        }))
      },
      {
        name: 'Senior',
        color: 'gold',
        totalPar: 72,
        totalDistance: 5498,
        rating: 67.2,
        slope: 121,
        holes: Array.from({ length: 18 }, (_, i) => ({
          number: i + 1,
          par: [4,4,3,5,4,3,4,4,5,4,3,5,4,3,4,5,4,4][i],
          handicap: [9,15,11,5,7,17,1,13,3,2,16,6,8,18,14,4,12,10][i],
          distance: 0
        }))
      }
    ]
  }
];