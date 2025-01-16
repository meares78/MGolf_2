import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { Trophy, Target, CircleDot, Loader2 } from 'lucide-react';

interface RoundResult {
  id: string;
  position: number;
  net_score: number;
  gross_score: number;
  payout: number;
  auth_id: string;
}

interface Skin {
  id: string;
  hole_number: number;
  gross_score: number;
  payout: number;
  auth_id: string;
}

interface Two {
  id: string;
  hole_number: number;
  payout: number;
  auth_id: string;
}

interface Player {
  id: string;
  name: string;
  auth_id: string;
}

interface FinalizedScore {
  auth_id: string;
  total_gross: number;
  total_net: number;
  course_handicap: number;
}

interface RoundData {
  id: string;
  date: string;
  courseName: string;
  results: RoundResult[];
  skins: Skin[];
  twos: Two[];
  allScores: FinalizedScore[];
}

export default function Results() {
  const [roundsData, setRoundsData] = useState<RoundData[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        // First fetch all players
        const { data: playersData, error: playersError } = await supabase
          .from('players')
          .select('id, name, auth_id');

        if (playersError) throw playersError;
        setPlayers(playersData || []);

        // Get all rounds that have results
        const { data: rounds, error: roundsError } = await supabase
          .from('rounds')
          .select(`
            id,
            date,
            course_name,
            round_results (
              id,
              position,
              net_score,
              gross_score,
              payout,
              auth_id
            ),
            skins (
              id,
              hole_number,
              gross_score,
              payout,
              auth_id
            ),
            twos (
              id,
              hole_number,
              payout,
              auth_id
            ),
            finalized_scores (
              auth_id,
              total_gross,
              total_net,
              course_handicap
            )
          `)
          .order('date');

        if (roundsError) throw roundsError;

        if (!rounds || rounds.length === 0) {
          setRoundsData([]);
          setLoading(false);
          return;
        }

        // Transform the data into our expected format
        const formattedRounds: RoundData[] = rounds
          .filter(round => round.finalized_scores.length > 0) // Only include rounds with scores
          .map(round => ({
            id: round.id,
            date: round.date,
            courseName: round.course_name,
            results: round.round_results || [],
            skins: round.skins || [],
            twos: round.twos || [],
            allScores: round.finalized_scores || []
          }));

        setRoundsData(formattedRounds);
      } catch (error) {
        console.error('Error fetching results:', error);
        setError('Failed to load results');
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, []);

  const getPlayerName = (auth_id: string) => {
    const player = players.find(p => p.auth_id === auth_id);
    return player?.name || 'Unknown Player';
  };

  // Helper function to format date consistently
  const formatDate = (dateString: string) => {
    // Force UTC interpretation of the date to avoid timezone shifts
    const [year, month, day] = dateString.split('-').map(Number);
    const date = new Date(Date.UTC(year, month - 1, day));
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      month: 'long',
      day: 'numeric',
      timeZone: 'UTC' // Force UTC to avoid timezone shifts
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 className="w-8 h-8 animate-spin text-green-600" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-red-500">{error}</div>
      </div>
    );
  }

  if (roundsData.length === 0) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-8">
        <h1 className="text-2xl font-bold text-gray-900 mb-8">Tournament Results</h1>
        <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200 text-center text-gray-500">
          No results available yet
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <div className="space-y-8">
        {roundsData.map((round) => (
          <div key={round.id} className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
            <h2 className="text-xl font-semibold text-gray-900 mb-2">
              {round.courseName} - {formatDate(round.date)}
            </h2>

            {/* Net Scores */}
            <div className="mb-6">
              <div className="flex items-center space-x-2 text-gray-700 mb-3">
                <Trophy className="w-5 h-5" />
                <h3 className="font-medium">Net Scores</h3>
              </div>
              <div className="bg-gray-50 rounded-lg p-4">
                {round.allScores
                  .sort((a, b) => a.total_net - b.total_net)
                  .map((score, index) => {
                    const result = round.results.find(r => r.auth_id === score.auth_id);
                    return (
                      <div key={score.auth_id} className="flex items-center justify-between py-2">
                        <div className="flex items-center space-x-4">
                          <span className="font-medium">{index + 1}.</span>
                          <span>{getPlayerName(score.auth_id)}</span>
                        </div>
                        <div className="space-x-4">
                          <span className="text-gray-600">
                            Gross: {score.total_gross} / Net: {score.total_net}
                          </span>
                          {result && (
                            <span className="text-green-600">${result.payout}</span>
                          )}
                        </div>
                      </div>
                    );
                  })}
              </div>
            </div>

            {/* Skins */}
            {round.skins.length > 0 && (
              <div className="mb-6">
                <div className="flex items-center space-x-2 text-gray-700 mb-3">
                  <Target className="w-5 h-5" />
                  <h3 className="font-medium">Skins</h3>
                </div>
                <div className="bg-gray-50 rounded-lg p-4">
                  {round.skins.map((skin) => (
                    <div key={`${skin.id}-${skin.hole_number}`} className="flex items-center justify-between py-2">
                      <div className="flex items-center space-x-4">
                        <span className="font-medium">Hole {skin.hole_number}</span>
                        <span>{getPlayerName(skin.auth_id)} ({skin.gross_score})</span>
                      </div>
                      <span className="text-green-600">${skin.payout}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Twos */}
            {round.twos.length > 0 && (
              <div>
                <div className="flex items-center space-x-2 text-gray-700 mb-3">
                  <CircleDot className="w-5 h-5" />
                  <h3 className="font-medium">Twos</h3>
                </div>
                <div className="bg-gray-50 rounded-lg p-4">
                  {round.twos.map((two) => (
                    <div key={`${two.id}-${two.hole_number}`} className="flex items-center justify-between py-2">
                      <div className="flex items-center space-x-4">
                        <span className="font-medium">Hole {two.hole_number}</span>
                        <span>{getPlayerName(two.auth_id)}</span>
                      </div>
                      <span className="text-green-600">${two.payout}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}