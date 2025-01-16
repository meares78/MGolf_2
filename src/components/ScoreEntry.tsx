import React, { useState, useEffect } from 'react';
import { ChevronLeft, ChevronRight, Plus, Minus, Flag, Save, Check } from 'lucide-react';
import { courses } from '../data/courses';
import { calculateCourseHandicap, getHandicapStrokes } from '../utils/handicap';
import { matchTeeFromId } from '../utils/teeMatching';

interface ScoreEntryProps {
  roundId: string;
  courseName: string;
  teeId: string | null;
  onSave: (scores: number[]) => void;
  onFinalize?: (scores: number[]) => void;
  isFinalized?: boolean;
  initialScores?: number[];
  playerHandicap?: number;
  saving?: boolean;
}

export default function ScoreEntry({
  roundId,
  courseName,
  teeId,
  onSave,
  onFinalize,
  isFinalized = false,
  initialScores,
  playerHandicap = 0,
  saving = false
}: ScoreEntryProps) {
  const [currentHole, setCurrentHole] = useState(1);
  const [scores, setScores] = useState<number[]>(Array(18).fill(0));
  const [showSummary, setShowSummary] = useState(false);

  // Find course and tee data
  const course = courses.find(c => c.name === courseName);
  const tee = course?.tees && teeId ? matchTeeFromId(teeId, courseName, course.tees) : undefined;

  useEffect(() => {
    if (tee && !initialScores) {
      // Initialize scores with pars
      setScores(tee.holes.map(hole => hole.par));
    } else if (initialScores) {
      setScores(initialScores);
    }
  }, [tee, initialScores]);

  if (!course || !tee) {
    return <div>Course or tee data not found</div>;
  }

  const currentHoleData = tee.holes[currentHole - 1];
  const courseHandicap = calculateCourseHandicap(playerHandicap, tee.slope, tee.rating, tee.totalPar);
  const handicapStrokes = getHandicapStrokes(courseHandicap, tee.holes.map(h => h.handicap));

  const totalScore = scores.reduce((sum, score) => sum + score, 0);
  const totalPar = tee.holes.reduce((sum, hole) => sum + hole.par, 0);
  const netScore = totalScore - courseHandicap;

  const handleScoreChange = (increment: number) => {
    if (isFinalized) return;

    const newScores = [...scores];
    const newScore = Math.max(1, newScores[currentHole - 1] + increment);
    newScores[currentHole - 1] = newScore;
    setScores(newScores);
    onSave(newScores);
  };

  const navigateHole = (direction: 'prev' | 'next') => {
    if (direction === 'prev' && currentHole > 1) {
      setCurrentHole(currentHole - 1);
    } else if (direction === 'next' && currentHole < 18) {
      setCurrentHole(currentHole + 1);
    }
  };

  const handleFinalize = () => {
    if (onFinalize) {
      onFinalize(scores);
    }
  };

  if (showSummary) {
    return (
      <div className="space-y-6">
        <div className="bg-white rounded-lg p-6">
          <h2 className="text-2xl font-bold mb-4">Round Summary</h2>
          <div className="grid grid-cols-2 gap-4 mb-6">
            <div>
              <p className="text-gray-600">Gross Score</p>
              <p className="text-2xl font-bold">{totalScore}</p>
            </div>
            <div>
              <p className="text-gray-600">To Par</p>
              <p className="text-2xl font-bold">{totalScore - totalPar > 0 ? `+${totalScore - totalPar}` : totalScore - totalPar}</p>
            </div>
            <div>
              <p className="text-gray-600">Course Handicap</p>
              <p className="text-2xl font-bold">{courseHandicap}</p>
            </div>
            <div>
              <p className="text-gray-600">Net Score</p>
              <p className="text-2xl font-bold">{netScore}</p>
            </div>
          </div>

          <div className="space-y-2">
            {tee.holes.map((hole, index) => (
              <div key={hole.number} className="flex items-center justify-between py-2 border-b">
                <div className="flex items-center space-x-4">
                  <span className="w-8 text-center font-medium">#{hole.number}</span>
                  <span className="w-8 text-center text-gray-600">Par {hole.par}</span>
                </div>
                <div className="flex items-center space-x-4">
                  <span className={`w-8 text-center ${scores[index] > hole.par ? 'text-red-500' : scores[index] < hole.par ? 'text-green-500' : ''}`}>
                    {scores[index]}
                  </span>
                  <span className="w-8 text-center text-gray-500">
                    {handicapStrokes.get(hole.handicap) ? `(${handicapStrokes.get(hole.handicap)})` : ''}
                  </span>
                </div>
              </div>
            ))}
          </div>

          <div className="mt-6 space-y-4">
            {!isFinalized && (
              <>
                <button
                  onClick={handleFinalize}
                  disabled={saving}
                  className="w-full flex items-center justify-center space-x-2 bg-green-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-green-500 transition-colors disabled:opacity-50"
                >
                  <Save className="h-4 w-4" />
                  <span>{saving ? 'Finalizing...' : 'Finalize Score'}</span>
                </button>
                <button
                  onClick={() => setShowSummary(false)}
                  disabled={saving}
                  className="w-full py-2 px-4 text-gray-600 hover:text-gray-900"
                >
                  Continue Editing
                </button>
              </>
            )}
            {isFinalized && (
              <div className="flex items-center justify-center space-x-2 text-green-600">
                <Check className="h-5 w-5" />
                <span className="font-medium">Score Finalized</span>
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-lg p-6">
        <div className="flex items-center justify-between mb-6">
          <button
            onClick={() => navigateHole('prev')}
            disabled={currentHole === 1}
            className="p-2 rounded-full hover:bg-gray-100 disabled:opacity-50"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          
          <div className="text-center">
            <div className="text-3xl font-bold">Hole {currentHole}</div>
            <div className="flex items-center justify-center space-x-2 text-gray-600">
              <Flag className="w-4 h-4" />
              <span>Par {currentHoleData.par}</span>
            </div>
          </div>

          <button
            onClick={() => navigateHole('next')}
            disabled={currentHole === 18}
            className="p-2 rounded-full hover:bg-gray-100 disabled:opacity-50"
          >
            <ChevronRight className="w-6 h-6" />
          </button>
        </div>

        <div className="flex items-center justify-center space-x-6">
          <button
            onClick={() => handleScoreChange(-1)}
            disabled={scores[currentHole - 1] <= 1 || isFinalized}
            className="p-4 rounded-full bg-gray-100 hover:bg-gray-200 disabled:opacity-50"
          >
            <Minus className="w-6 h-6" />
          </button>

          <div className="text-center">
            <div className="text-5xl font-bold mb-1">{scores[currentHole - 1]}</div>
            <div className="text-sm text-gray-600">
              {scores[currentHole - 1] - currentHoleData.par > 0
                ? `+${scores[currentHole - 1] - currentHoleData.par}`
                : scores[currentHole - 1] - currentHoleData.par}
            </div>
          </div>

          <button
            onClick={() => handleScoreChange(1)}
            disabled={isFinalized}
            className="p-4 rounded-full bg-gray-100 hover:bg-gray-200 disabled:opacity-50"
          >
            <Plus className="w-6 h-6" />
          </button>
        </div>

        {currentHole === 18 && !isFinalized && (
          <button
            onClick={() => setShowSummary(true)}
            className="mt-8 w-full bg-green-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-green-500 transition-colors"
          >
            View Summary
          </button>
        )}
      </div>

      <div className="overflow-x-auto">
        <div className="flex space-x-2 min-w-max">
          {tee.holes.map((hole, index) => (
            <button
              key={hole.number}
              onClick={() => setCurrentHole(hole.number)}
              className={`w-12 p-2 text-center rounded ${
                currentHole === hole.number
                  ? 'bg-green-600 text-white'
                  : 'bg-white hover:bg-gray-50'
              }`}
            >
              <div className="text-xs font-medium">#{hole.number}</div>
              <div className={`text-lg font-bold ${
                currentHole === hole.number ? 'text-white' : scores[index] > hole.par ? 'text-red-500' : scores[index] < hole.par ? 'text-green-500' : ''
              }`}>
                {scores[index]}
              </div>
              <div className="text-xs opacity-75">Par {hole.par}</div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}