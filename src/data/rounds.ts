import { Round } from '../types';

export const availableRounds: Round[] = [
  // Monday, February 10 - Nicklaus
  {
    id: 'mon-1',
    date: '2025-02-10',
    time: '8:00 AM',
    courseName: 'Nicklaus',
    teeOptions: [
      {
        id: 'nicklaus-tips',
        name: 'Tips',
        color: 'gold',
        rating: 74.8,
        slope: 140,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      },
      {
        id: 'nicklaus-men-gb',
        name: 'Men',
        color: 'gold/blue',
        rating: 73.0,
        slope: 135,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      },
      {
        id: 'nicklaus-men',
        name: 'Men',
        color: 'blue',
        rating: 71.4,
        slope: 133,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      },
      {
        id: 'nicklaus-senior',
        name: 'Senior',
        color: 'white',
        rating: 69.8,
        slope: 129,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      }
    ]
  },

  // Tuesday, February 11 - Watson
  {
    id: 'tue-1',
    date: '2025-02-11',
    time: '8:00 AM',
    courseName: 'Watson',
    teeOptions: [
      {
        id: 'watson-tips',
        name: 'Tips',
        color: 'black',
        rating: 75.0,
        slope: 136,
        handicapHoles: [5,9,17,1,3,15,11,7,13,2,10,16,14,18,12,4,8,6]
      },
      {
        id: 'watson-men-gold',
        name: 'Men',
        color: 'gold',
        rating: 72.9,
        slope: 132,
        handicapHoles: [5,9,17,1,3,15,11,7,13,2,10,16,14,18,12,4,8,6]
      },
      {
        id: 'watson-men-blue',
        name: 'Men',
        color: 'blue',
        rating: 70.8,
        slope: 126,
        handicapHoles: [5,9,17,1,3,15,11,7,13,2,10,16,14,18,12,4,8,6]
      }
    ]
  },

  // Wednesday, February 12 - Watson
  {
    id: 'wed-1',
    date: '2025-02-12',
    time: '8:00 AM',
    courseName: 'Watson',
    teeOptions: [
      {
        id: 'watson-tips-2',
        name: 'Tips',
        color: 'black',
        rating: 75.0,
        slope: 136,
        handicapHoles: [5,9,17,1,3,15,11,7,13,2,10,16,14,18,12,4,8,6]
      },
      {
        id: 'watson-men-gold-2',
        name: 'Men',
        color: 'gold',
        rating: 72.9,
        slope: 132,
        handicapHoles: [5,9,17,1,3,15,11,7,13,2,10,16,14,18,12,4,8,6]
      },
      {
        id: 'watson-men-blue-2',
        name: 'Men',
        color: 'blue',
        rating: 70.8,
        slope: 126,
        handicapHoles: [5,9,17,1,3,15,11,7,13,2,10,16,14,18,12,4,8,6]
      }
    ]
  },

  // Thursday, February 13 - Southern Dunes
  {
    id: 'thu-1',
    date: '2025-02-13',
    time: '8:00 AM',
    courseName: 'SouthernDunes',
    teeOptions: [
      {
        id: 'southerndunes-tips',
        name: 'Tips',
        color: 'black',
        rating: 75.0,
        slope: 140,
        handicapHoles: [9,15,11,5,7,17,1,13,3,2,16,6,8,18,14,4,12,10]
      },
      {
        id: 'southerndunes-men-blue',
        name: 'Men',
        color: 'blue',
        rating: 72.9,
        slope: 136,
        handicapHoles: [9,15,11,5,7,17,1,13,3,2,16,6,8,18,14,4,12,10]
      },
      {
        id: 'southerndunes-men-white',
        name: 'Men',
        color: 'white',
        rating: 70.4,
        slope: 133,
        handicapHoles: [9,15,11,5,7,17,1,13,3,2,16,6,8,18,14,4,12,10]
      },
      {
        id: 'southerndunes-senior',
        name: 'Senior',
        color: 'gold',
        rating: 67.2,
        slope: 121,
        handicapHoles: [9,15,11,5,7,17,1,13,3,2,16,6,8,18,14,4,12,10]
      }
    ]
  },

  // Friday, February 14 - Palmer
  {
    id: 'fri-1',
    date: '2025-02-14',
    time: '8:00 AM',
    courseName: 'Palmer',
    teeOptions: [
      {
        id: 'palmer-tips',
        name: 'Tips',
        color: 'black',
        rating: 73.6,
        slope: 141,
        handicapHoles: [5,11,9,15,13,7,17,1,3,6,14,8,2,18,12,16,10,4]
      },
      {
        id: 'palmer-men-gold',
        name: 'Men',
        color: 'gold',
        rating: 70.9,
        slope: 133,
        handicapHoles: [5,11,9,15,13,7,17,1,3,6,14,8,2,18,12,16,10,4]
      },
      {
        id: 'palmer-men-gb',
        name: 'Men',
        color: 'gold/blue',
        rating: 70.1,
        slope: 130,
        handicapHoles: [5,11,9,15,13,7,17,1,3,6,14,8,2,18,12,16,10,4]
      },
      {
        id: 'palmer-senior',
        name: 'Senior',
        color: 'blue',
        rating: 69.5,
        slope: 127,
        handicapHoles: [5,11,9,15,13,7,17,1,3,6,14,8,2,18,12,16,10,4]
      }
    ]
  },

  // Saturday, February 15 - Nicklaus
  {
    id: 'sat-1',
    date: '2025-02-15',
    time: '8:00 AM',
    courseName: 'Nicklaus',
    teeOptions: [
      {
        id: 'nicklaus-tips-3',
        name: 'Tips',
        color: 'gold',
        rating: 74.8,
        slope: 140,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      },
      {
        id: 'nicklaus-men-gb-3',
        name: 'Men',
        color: 'gold/blue',
        rating: 73.0,
        slope: 135,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      },
      {
        id: 'nicklaus-men-3',
        name: 'Men',
        color: 'blue',
        rating: 71.4,
        slope: 133,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      },
      {
        id: 'nicklaus-senior-3',
        name: 'Senior',
        color: 'white',
        rating: 69.8,
        slope: 129,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      }
    ]
  },

  // Sunday, February 16 - Nicklaus
  {
    id: 'sun-1',
    date: '2025-02-16',
    time: '8:00 AM',
    courseName: 'Nicklaus',
    teeOptions: [
      {
        id: 'nicklaus-tips-4',
        name: 'Tips',
        color: 'gold',
        rating: 74.8,
        slope: 140,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      },
      {
        id: 'nicklaus-men-gb-4',
        name: 'Men',
        color: 'gold/blue',
        rating: 73.0,
        slope: 135,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      },
      {
        id: 'nicklaus-men-4',
        name: 'Men',
        color: 'blue',
        rating: 71.4,
        slope: 133,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      },
      {
        id: 'nicklaus-senior-4',
        name: 'Senior',
        color: 'white',
        rating: 69.8,
        slope: 129,
        handicapHoles: [17,1,5,3,7,13,9,15,11,4,18,6,10,2,12,8,14,16]
      }
    ]
  }
];