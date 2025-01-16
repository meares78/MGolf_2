export interface Course {
  name: string;
  tees: Tee[];
}

export interface Tee {
  name: string;
  color: string;
  totalPar: number;
  totalDistance: number;
  rating: number;
  slope: number;
  holes: Hole[];
}

export interface Hole {
  number: number;
  par: number;
  handicap: number;
  distance: number;
}

export interface Round {
  id: string;
  date: string;
  time: string;
  courseName: string;
  teeOptions: TeeOption[];
}

export interface TeeOption {
  id: string;
  name: string;
  color: string;
  rating: number;
  slope: number;
  handicapHoles: number[];
}

export interface User {
  id: string;
  name: string;
  phone: string;
  handicapIndex?: number;
}