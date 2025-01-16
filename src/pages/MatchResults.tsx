import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Trophy, Target, CircleDot, ArrowLeft } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface MatchResult {
  match_id: string;
  team: string;
  front_nine_points: number;
  back_nine_points: number;
  total_points: number;
  front_nine_payout: number;
  back_nine_payout: number;
  total_payout: number;
}

interface BirdieResult {
  id: string;
  auth_id: string;
  hole_number: number;
  payout: number;
}

interface MatchPlayer {
  auth_id: string;
  team: string;
  name: string;
}

interface MatchDetails {
  type: string;
  scoringType: 'gross' | 'net';
  front_nine_bet: number;
  back_nine_bet: number;
  total_bet: number;
  birdie_bet: number;
}

export default function MatchResults() {
  const { matchId } = useParams<{ matchId: string }>();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [results, setResults] = useState<MatchResult[]>([]);
  const [birdies, setBirdies] = useState<BirdieResult[]>([]);
  const [matchPlayers, setMatchPlayers] = useState<MatchPlayer[]>([]);
  const [matchDetails, setMatchDetails] = useState<MatchDetails | null>(null);

  useEffect(() => {
    async function fetchResults() {
      if (!matchId) return;

      try {
        setLoading(true);
        setError(null);

        // Fetch match details and players
        const { data: match, error: matchError } = await supabase
          .from('matches')
          .select(`
            *,
            match_players (
              auth_id,
              team,
              player:players(name)
            )
          `)
          .eq('id', matchId)
          .single();

        if (matchError) throw matchError;

        setMatchDetails({
          type: match.match_type,
          scoringType: match.scoring_type,
          front_nine_bet: match.front_nine_bet,
          back_nine_bet: match.back_nine_bet,
          total_bet: match.total_bet,
          birdie_bet: match.birdie_bet
        });

        // Format match players
        const formattedPlayers = match.match_players.map((mp: any) => ({
          auth_id: mp.auth_id,
          team: mp.team,
          name: mp.player?.name || 'Unknown Player'
        }));
        setMatchPlayers(formattedPlayers);

        // Fetch results
        const [resultsResponse, birdiesResponse] = await Promise.all([
          supabase
            .from('match_results')
            .select('*')
            .eq('match_id', matchId),
          supabase
            .from('match_birdies')
            .select('*')
            .eq('match_id', matchId)
        ]);

        if (resultsResponse.error) throw resultsResponse.error;
        if (birdiesResponse.error) throw birdiesResponse.error;

        setResults(resultsResponse.data || []);
        setBirdies(birdiesResponse.data || []);

      } catch (error) {
        console.error('Error fetching match results:', error);
        setError('Failed to load match results');
      } finally {
        setLoading(false);
      }
    }

    fetchResults();
  }, [matchId]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-gray-500">Loading match results...</div>
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

  const teamAResults = results.find(r => r.team === 'A');
  const teamBResults = results.find(r => r.team === 'B');

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <button
        onClick={() => navigate('/matches')}
        className="flex items-center text-gray-600 hover:text-gray-900 mb-6"
      >
        <ArrowLeft className="w-4 h-4 mr-1" />
        Back to Matches
      </button>

      <div className="space-y-8">
        {/* Match Details */}
        <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Match Results</h1>
              <div className="text-gray-500 mt-1">
                {matchDetails?.type} Match • {matchDetails?.scoringType === 'net' ? 'Net' : 'Gross'} Scoring
              </div>
            </div>
          </div>

          {/* Nassau Results */}
          <div className="space-y-6">
            {/* Front Nine */}
            <div>
              <h3 className="text-lg font-medium mb-3">Front Nine (${matchDetails?.front_nine_bet})</h3>
              <div className="grid grid-cols-2 gap-4">
                <div className={`p-4 rounded-lg ${teamAResults?.front_nine_payout > 0 ? 'bg-green-50' : 'bg-gray-50'}`}>
                  <div className="text-sm text-gray-500">Team A</div>
                  <div className={`text-lg font-semibold ${
                    teamAResults?.front_nine_payout > 0 ? 'text-green-600' : 
                    teamAResults?.front_nine_payout < 0 ? 'text-red-600' : ''
                  }`}>
                    {teamAResults?.front_nine_payout > 0 ? '+' : ''}
                    ${Math.abs(teamAResults?.front_nine_payout || 0)}
                  </div>
                </div>
                <div className={`p-4 rounded-lg ${teamBResults?.front_nine_payout > 0 ? 'bg-green-50' : 'bg-gray-50'}`}>
                  <div className="text-sm text-gray-500">Team B</div>
                  <div className={`text-lg font-semibold ${
                    teamBResults?.front_nine_payout > 0 ? 'text-green-600' : 
                    teamBResults?.front_nine_payout < 0 ? 'text-red-600' : ''
                  }`}>
                    {teamBResults?.front_nine_payout > 0 ? '+' : ''}
                    ${Math.abs(teamBResults?.front_nine_payout || 0)}
                  </div>
                </div>
              </div>
            </div>

            {/* Back Nine */}
            <div>
              <h3 className="text-lg font-medium mb-3">Back Nine (${matchDetails?.back_nine_bet})</h3>
              <div className="grid grid-cols-2 gap-4">
                <div className={`p-4 rounded-lg ${teamAResults?.back_nine_payout > 0 ? 'bg-green-50' : 'bg-gray-50'}`}>
                  <div className="text-sm text-gray-500">Team A</div>
                  <div className={`text-lg font-semibold ${
                    teamAResults?.back_nine_payout > 0 ? 'text-green-600' : 
                    teamAResults?.back_nine_payout < 0 ? 'text-red-600' : ''
                  }`}>
                    {teamAResults?.back_nine_payout > 0 ? '+' : ''}
                    ${Math.abs(teamAResults?.back_nine_payout || 0)}
                  </div>
                </div>
                <div className={`p-4 rounded-lg ${teamBResults?.back_nine_payout > 0 ? 'bg-green-50' : 'bg-gray-50'}`}>
                  <div className="text-sm text-gray-500">Team B</div>
                  <div className={`text-lg font-semibold ${
                    teamBResults?.back_nine_payout > 0 ? 'text-green-600' : 
                    teamBResults?.back_nine_payout < 0 ? 'text-red-600' : ''
                  }`}>
                    {teamBResults?.back_nine_payout > 0 ? '+' : ''}
                    ${Math.abs(teamBResults?.back_nine_payout || 0)}
                  </div>
                </div>
              </div>
            </div>

            {/* Total Match */}
            <div>
              <h3 className="text-lg font-medium mb-3">Total Match (${matchDetails?.total_bet})</h3>
              <div className="grid grid-cols-2 gap-4">
                <div className={`p-4 rounded-lg ${teamAResults?.total_payout > 0 ? 'bg-green-50' : 'bg-gray-50'}`}>
                  <div className="text-sm text-gray-500">Team A</div>
                  <div className={`text-lg font-semibold ${
                    teamAResults?.total_payout > 0 ? 'text-green-600' : 
                    teamAResults?.total_payout < 0 ? 'text-red-600' : ''
                  }`}>
                    {teamAResults?.total_payout > 0 ? '+' : ''}
                    ${Math.abs(teamAResults?.total_payout || 0)}
                  </div>
                </div>
                <div className={`p-4 rounded-lg ${teamBResults?.total_payout > 0 ? 'bg-green-50' : 'bg-gray-50'}`}>
                  <div className="text-sm text-gray-500">Team B</div>
                  <div className={`text-lg font-semibold ${
                    teamBResults?.total_payout > 0 ? 'text-green-600' : 
                    teamBResults?.total_payout < 0 ? 'text-red-600' : ''
                  }`}>
                    {teamBResults?.total_payout > 0 ? '+' : ''}
                    ${Math.abs(teamBResults?.total_payout || 0)}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Birdies */}
        {birdies.length > 0 && (
          <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
            <h2 className="text-xl font-semibold mb-4">Birdies (${matchDetails?.birdie_bet} each)</h2>
            <div className="space-y-3">
              {birdies.map((birdie) => {
                const player = matchPlayers.find(p => p.auth_id === birdie.auth_id);
                return (
                  <div
                    key={birdie.id}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                  >
                    <div className="flex items-center space-x-3">
                      <CircleDot className="h-5 w-5 text-green-500" />
                      <div>
                        <div className="font-medium">
                          {player?.name || 'Unknown Player'}
                        </div>
                        <div className="text-sm text-gray-500">
                          Hole {birdie.hole_number}
                        </div>
                      </div>
                    </div>
                    <div className="text-green-600 font-medium">
                      +${birdie.payout}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}