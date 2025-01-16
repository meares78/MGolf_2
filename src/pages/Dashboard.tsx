import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Calendar, Clock, Flag } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { availableRounds } from '../data/rounds';
import type { Round, TeeOption } from '../types';

export default function Dashboard() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [selectedRound, setSelectedRound] = useState<Round | null>(null);
  const [selectedTee, setSelectedTee] = useState<TeeOption | null>(null);

  // Group rounds by date
  const roundsByDate = availableRounds.reduce((acc, round) => {
    // Force the date to be interpreted in the local timezone
    const [year, month, day] = round.date.split('-').map(Number);
    const date = new Date(year, month - 1, day, 12); // Add noon time to avoid timezone issues
    const dateString = date.toLocaleDateString('en-US', {
      weekday: 'long',
      month: 'long',
      day: 'numeric'
    });
    
    if (!acc[dateString]) {
      acc[dateString] = [];
    }
    acc[dateString].push(round);
    return acc;
  }, {} as Record<string, Round[]>);

  const handleRoundSelect = (round: Round) => {
    setSelectedRound(round);
    setSelectedTee(null);
  };

  const handleTeeSelect = (tee: TeeOption) => {
    setSelectedTee(tee);
  };

  const handleStartRound = () => {
    if (selectedRound && selectedTee) {
      navigate(`/rounds/${selectedRound.id}?tee=${selectedTee.id}`);
    }
  };

  // Helper function to get the display color
  const getDisplayColor = (color: string) => {
    // Handle compound colors like 'gold/blue'
    if (color.includes('/')) {
      const [primary, secondary] = color.split('/');
      return `${primary.charAt(0).toUpperCase() + primary.slice(1)}/${secondary.charAt(0).toUpperCase() + secondary.slice(1)}`;
    }
    return color.charAt(0).toUpperCase() + color.slice(1);
  };

  // Helper function to get the background color class
  const getTeeColorClass = (color: string) => {
    const colorMap: Record<string, string> = {
      'black': 'bg-gray-900',
      'gold': 'bg-yellow-600',
      'blue': 'bg-blue-600',
      'white': 'bg-gray-100',
      'gold/blue': 'bg-gradient-to-r from-yellow-600 to-blue-600'
    };
    return colorMap[color] || 'bg-gray-400';
  };

  if (!user) {
    return null;
  }

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      {/* Welcome Section */}
      <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
        <h1 className="text-2xl font-bold text-gray-900">
          Welcome back, {user.name}!
        </h1>
        <p className="text-gray-600 mt-2">
          Select an upcoming round and your preferred tees to get started.
        </p>
      </div>

      {/* Rounds Selection */}
      <div className="grid gap-6 md:grid-cols-2">
        <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Available Rounds</h2>
          <div className="space-y-4">
            {Object.entries(roundsByDate).map(([date, rounds]) => (
              <div key={date} className="space-y-3">
                <h3 className="text-sm font-medium text-gray-500">{date}</h3>
                {rounds.map((round) => (
                  <button
                    key={round.id}
                    onClick={() => handleRoundSelect(round)}
                    className={`w-full text-left p-4 rounded-lg border transition-colors ${
                      selectedRound?.id === round.id
                        ? 'border-green-500 bg-green-50'
                        : 'border-gray-200 hover:border-green-200 hover:bg-green-50/50'
                    }`}
                  >
                    <div className="font-medium text-gray-900">{round.courseName}</div>
                    <div className="mt-1 flex items-center text-sm text-gray-500 space-x-4">
                      <span className="flex items-center">
                        <Clock className="h-4 w-4 mr-1" />
                        {round.time}
                      </span>
                    </div>
                  </button>
                ))}
              </div>
            ))}
          </div>
        </div>

        {/* Tee Selection */}
        {selectedRound && (
          <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Select Tees for {selectedRound.courseName}
            </h2>
            <div className="grid grid-cols-1 gap-3">
              {selectedRound.teeOptions.map((tee) => (
                <button
                  key={tee.id}
                  onClick={() => handleTeeSelect(tee)}
                  className={`w-full p-4 rounded-lg border transition-colors ${
                    selectedTee?.id === tee.id
                      ? 'border-green-500 ring-2 ring-green-500 ring-opacity-50'
                      : 'border-gray-200 hover:border-green-200'
                  }`}
                >
                  <div className="flex items-center space-x-4">
                    <div className={`w-6 h-6 rounded-full ${getTeeColorClass(tee.color)} border border-gray-300`} />
                    <div className="flex-1">
                      <div className="font-medium text-gray-900">
                        {getDisplayColor(tee.color)} Tees
                      </div>
                      <div className="text-sm text-gray-500">
                        Rating: {tee.rating} / Slope: {tee.slope}
                      </div>
                    </div>
                  </div>
                </button>
              ))}
            </div>

            {selectedTee && (
              <button
                onClick={handleStartRound}
                className="mt-6 w-full bg-green-600 text-white py-2 px-4 rounded-lg font-medium hover:bg-green-500 transition-colors"
              >
                Start Round
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  );
}