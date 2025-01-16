import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { Save, Loader2, Trophy, Target, CircleDot } from 'lucide-react';
import { availableRounds } from '../data/rounds';
import { calculatePositionPayout, calculateSkinPayout, calculateTwoPayout, sortScoresForPositions } from '../utils/results';

interface Player {
  id: string;
  name: string;
  auth_id: string;
}

interface Score {
  auth_id: string;
  net_score: number;
  gross_score: number;
}

interface HoleScore {
  auth_id: string;
  hole_number: number;
  strokes: number;
}

interface RoundData {
  id: string;
  dbId: string;
  date: string;
  courseName: string;
  allScores: Score[];
  holeScores: HoleScore[];
  twos: Array<{ auth_id: string; hole_number: number }>;
}

export default function ResultsAdmin() {
  const [selectedRound, setSelectedRound] = useState<string | null>(null);
  const [players, setPlayers] = useState<Player[]>([]);
  const [roundData, setRoundData] = useState<RoundData | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  // Get morning rounds only (8:00 AM tee times) and sort by date
  const morningRounds = availableRounds
    .filter(round => round.time === '8:00 AM')
    .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());

  useEffect(() => {
    async function fetchPlayers() {
      try {
        const { data, error } = await supabase
          .from('players')
          .select('*')
          .order('name');

        if (error) throw error;
        setPlayers(data || []);
      } catch (error) {
        console.error('Error fetching players:', error);
        setError('Failed to load players');
      } finally {
        setLoading(false);
      }
    }

    fetchPlayers();
  }, []);

  useEffect(() => {
    async function fetchRoundData() {
      if (!selectedRound) return;

      setLoading(true);
      try {
        // First get the database ID for the round
        const { data: dbRound, error: roundError } = await supabase
          .from('rounds')
          .select('id')
          .eq('external_id', selectedRound)
          .single();

        if (roundError) throw roundError;
        if (!dbRound) throw new Error('Round not found');

        const [scoresResponse, holeScoresResponse, twosResponse] = await Promise.all([
          supabase
            .from('finalized_scores')
            .select('auth_id, total_gross, total_net')
            .eq('round_id', dbRound.id),
          
          supabase
            .from('scores')
            .select('auth_id, hole_number, strokes')
            .eq('round_id', dbRound.id),
          
          supabase
            .from('scores')
            .select('auth_id, hole_number')
            .eq('round_id', dbRound.id)
            .eq('strokes', 2)
        ]);

        if (scoresResponse.error) throw scoresResponse.error;
        if (holeScoresResponse.error) throw holeScoresResponse.error;
        if (twosResponse.error) throw twosResponse.error;

        const round = morningRounds.find(r => r.id === selectedRound);
        if (!round) throw new Error('Round not found');

        setRoundData({
          id: round.id,
          dbId: dbRound.id,
          date: round.date,
          courseName: round.courseName,
          allScores: (scoresResponse.data || []).map(score => ({
            auth_id: score.auth_id,
            net_score: score.total_net,
            gross_score: score.total_gross
          })),
          holeScores: holeScoresResponse.data || [],
          twos: twosResponse.data || []
        });
      } catch (error) {
        console.error('Error fetching round data:', error);
        setError('Failed to load round data');
      } finally {
        setLoading(false);
      }
    }

    fetchRoundData();
  }, [selectedRound]);

  const calculateSkins = () => {
    if (!roundData?.holeScores) return [];

    const skins: Array<{ hole_number: number; auth_id: string | null; gross_score: number }> = [];
    
    // Process each hole
    for (let hole = 1; hole <= 18; hole++) {
      const holeScores = roundData.holeScores.filter(s => s.hole_number === hole);
      if (holeScores.length === 0) continue;

      // Find the lowest score for this hole
      const lowestScore = Math.min(...holeScores.map(s => s.strokes));
      const playersWithLowestScore = holeScores.filter(s => s.strokes === lowestScore);

      // If only one player has the lowest score, it's a skin
      skins.push({
        hole_number: hole,
        auth_id: playersWithLowestScore.length === 1 ? playersWithLowestScore[0].auth_id : null,
        gross_score: lowestScore
      });
    }

    return skins;
  };

  const handleSaveResults = async () => {
    if (!roundData) return;

    setSaving(true);
    setError(null);
    setSuccess(null);

    try {
      // First, delete any existing results for this round
      await Promise.all([
        supabase
          .from('round_results')
          .delete()
          .eq('round_id', roundData.dbId),
        supabase
          .from('skins')
          .delete()
          .eq('round_id', roundData.dbId),
        supabase
          .from('twos')
          .delete()
          .eq('round_id', roundData.dbId)
      ]);

      // Calculate positions and payouts with ties
      const tiedGroups = sortScoresForPositions(roundData.allScores);
      const results = [];

      // Process each group up to 3rd place
      for (const group of tiedGroups) {
        if (group.position > 3) break;

        const payout = calculatePositionPayout(group.position, group.players.length);
        
        results.push(...group.players.map(score => ({
          round_id: roundData.dbId,
          auth_id: score.auth_id,
          position: group.position,
          net_score: score.net_score,
          gross_score: score.gross_score,
          payout
        })));
      }

      // Calculate skins
      const skins = calculateSkins();
      const validSkins = skins.filter(skin => skin.auth_id !== null);
      const skinPayoutAmount = calculateSkinPayout(validSkins.length);
      
      const skinRecords = validSkins.map(skin => ({
        round_id: roundData.dbId,
        auth_id: skin.auth_id,
        hole_number: skin.hole_number,
        gross_score: skin.gross_score,
        payout: skinPayoutAmount
      }));

      // Calculate two payouts
      const twoPayoutAmount = calculateTwoPayout(roundData.twos.length);
      const twos = roundData.twos.map(two => ({
        round_id: roundData.dbId,
        auth_id: two.auth_id,
        hole_number: two.hole_number,
        payout: twoPayoutAmount
      }));

      // Save all results
      const [resultsResponse, skinsResponse, twosResponse] = await Promise.all([
        supabase
          .from('round_results')
          .insert(results),
        
        supabase
          .from('skins')
          .insert(skinRecords),
        
        supabase
          .from('twos')
          .insert(twos)
      ]);

      if (resultsResponse.error) throw resultsResponse.error;
      if (skinsResponse.error) throw skinsResponse.error;
      if (twosResponse.error) throw twosResponse.error;

      setSuccess('Results saved successfully');
    } catch (error) {
      console.error('Error saving results:', error);
      setError('Failed to save results');
    } finally {
      setSaving(false);
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString + 'T12:00:00'); // Add noon time to avoid timezone issues
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      month: 'long',
      day: 'numeric'
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 className="w-8 h-8 animate-spin text-green-600" />
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold text-gray-900">Manage Results</h1>
          {roundData && (
            <button
              onClick={handleSaveResults}
              disabled={saving}
              className="flex items-center space-x-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-500 transition-colors disabled:opacity-50"
            >
              {saving ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <Save className="w-4 h-4" />
              )}
              <span>{saving ? 'Saving...' : 'Save Results'}</span>
            </button>
          )}
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-600 rounded-lg">
            {error}
          </div>
        )}
        {success && (
          <div className="mb-4 p-3 bg-green-50 border border-green-200 text-green-600 rounded-lg">
            {success}
          </div>
        )}

        {/* Round Selection */}
        <div className="mb-8">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Select Round
          </label>
          <select
            value={selectedRound || ''}
            onChange={(e) => setSelectedRound(e.target.value || null)}
            className="w-full border-gray-300 rounded-lg shadow-sm"
          >
            <option value="">Select a round...</option>
            {morningRounds.map((round) => (
              <option key={round.id} value={round.id}>
                {round.courseName} - {formatDate(round.date)}
              </option>
            ))}
          </select>
        </div>

        {roundData && (
          <div className="space-y-8">
            {/* Net Scores */}
            <div>
              <div className="flex items-center space-x-2 text-gray-700 mb-4">
                <Trophy className="w-5 h-5" />
                <h2 className="text-lg font-medium">Net Scores</h2>
              </div>
              <div className="bg-gray-50 rounded-lg p-4">
                {roundData.allScores
                  .sort((a, b) => a.net_score - b.net_score)
                  .map((score, index) => {
                    const player = players.find(p => p.auth_id === score.auth_id);
                    const tiedGroups = sortScoresForPositions(roundData.allScores);
                    const group = tiedGroups.find(g => 
                      g.players.some(p => p.auth_id === score.auth_id)
                    );
                    const payout = group && group.position <= 3 
                      ? calculatePositionPayout(group.position, group.players.length)
                      : 0;

                    return (
                      <div key={score.auth_id} className="flex items-center justify-between py-2">
                        <div className="flex items-center space-x-4">
                          <span className="font-medium">{index + 1}.</span>
                          <span>{player?.name || 'Unknown Player'}</span>
                        </div>
                        <div className="space-x-4">
                          <span className="text-gray-600">
                            Gross: {score.gross_score} / Net: {score.net_score}
                          </span>
                          {payout > 0 && (
                            <span className="text-green-600">${payout}</span>
                          )}
                        </div>
                      </div>
                    );
                  })}
              </div>
            </div>

            {/* Skins */}
            <div>
              <div className="flex items-center space-x-2 text-gray-700 mb-4">
                <Target className="w-5 h-5" />
                <h2 className="text-lg font-medium">Skins</h2>
              </div>
              <div className="bg-gray-50 rounded-lg p-4">
                {calculateSkins().map((skin) => {
                  const player = players.find(p => p.auth_id === skin.auth_id);
                  const validSkins = calculateSkins().filter(s => s.auth_id !== null);
                  const skinPayout = calculateSkinPayout(validSkins.length);

                  return (
                    <div key={skin.hole_number} className="flex items-center justify-between py-2">
                      <div className="flex items-center space-x-4">
                        <span className="font-medium">Hole {skin.hole_number}</span>
                        <span>
                          {skin.auth_id ? (
                            <>
                              {player?.name || 'Unknown Player'} ({skin.gross_score})
                            </>
                          ) : (
                            <span className="text-gray-500">No skin</span>
                          )}
                        </span>
                      </div>
                      {skin.auth_id && (
                        <span className="text-green-600">${skinPayout}</span>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Twos */}
            <div>
              <div className="flex items-center space-x-2 text-gray-700 mb-4">
                <CircleDot className="w-5 h-5" />
                <h2 className="text-lg font-medium">Twos</h2>
              </div>
              <div className="bg-gray-50 rounded-lg p-4">
                {roundData.twos.map((two) => {
                  const player = players.find(p => p.auth_id === two.auth_id);
                  return (
                    <div key={`${two.auth_id}-${two.hole_number}`} className="flex items-center justify-between py-2">
                      <div className="flex items-center space-x-4">
                        <span className="font-medium">Hole {two.hole_number}</span>
                        <span>{player?.name || 'Unknown Player'}</span>
                      </div>
                      <span className="text-green-600">${calculateTwoPayout(roundData.twos.length)}</span>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}