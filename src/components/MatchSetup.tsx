import React, { useState, useEffect } from 'react';
import { Users, DollarSign } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';

interface MatchSetupProps {
  roundId: string;
  onSave: (match: Match) => void;
}

interface Match {
  id: string;
  type: '1v1' | '2v2' | '4v4';
  teamA: string[];
  teamB: string[];
  front_nine_bet: number;
  back_nine_bet: number;
  total_bet: number;
  birdie_bet: number;
  scoringType: 'gross' | 'net';
}

interface Player {
  id: string;
  auth_id: string;
  name: string;
  phone: string;
}

export default function MatchSetup({ roundId, onSave }: MatchSetupProps) {
  const [matchType, setMatchType] = useState<'1v1' | '2v2' | '4v4'>('1v1');
  const [teamA, setTeamA] = useState<string[]>([]);
  const [teamB, setTeamB] = useState<string[]>([]);
  const [frontNineBet, setFrontNineBet] = useState(5);
  const [backNineBet, setBackNineBet] = useState(5);
  const [totalBet, setTotalBet] = useState(5);
  const [birdieBet, setBirdieBet] = useState(1);
  const [scoringType, setScoringType] = useState<'gross' | 'net'>('gross');
  const [players, setPlayers] = useState<Player[]>([]);

  const { user } = useAuth();

  useEffect(() => {
    async function fetchPlayers() {
      const { data, error } = await supabase
        .from('players')
        .select('*')
        .order('name');
      
      if (!error && data) {
        setPlayers(data);
      }
    }

    fetchPlayers();
  }, []);

  const availablePlayers = players.filter(
    player => !teamA.includes(player.auth_id) && !teamB.includes(player.auth_id)
  );

  const getTeamSize = () => {
    switch (matchType) {
      case '1v1': return 1;
      case '2v2': return 2;
      case '4v4': return 4;
      default: return 1;
    }
  };

  const handlePlayerSelect = (authId: string, team: 'A' | 'B') => {
    const teamSize = getTeamSize();
    if (team === 'A') {
      if (teamA.length < teamSize) {
        setTeamA([...teamA, authId]);
      }
    } else {
      if (teamB.length < teamSize) {
        setTeamB([...teamB, authId]);
      }
    }
  };

  const handleRemovePlayer = (authId: string, team: 'A' | 'B') => {
    if (team === 'A') {
      setTeamA(teamA.filter(id => id !== authId));
    } else {
      setTeamB(teamB.filter(id => id !== authId));
    }
  };

  const handleSave = () => {
    const match: Match = {
      id: `${roundId}-${Date.now()}`,
      type: matchType,
      teamA,
      teamB,
      front_nine_bet: frontNineBet,
      back_nine_bet: backNineBet,
      total_bet: totalBet,
      birdie_bet: birdieBet,
      scoringType
    };
    onSave(match);
    
    // Reset form
    setTeamA([]);
    setTeamB([]);
  };

  const isValid = teamA.length === getTeamSize() && teamB.length === getTeamSize();

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold mb-3">Match Type</h3>
        <div className="flex space-x-4">
          {(['1v1', '2v2', '4v4'] as const).map((type) => (
            <button
              key={type}
              onClick={() => {
                setMatchType(type);
                setTeamA([]);
                setTeamB([]);
              }}
              className={`flex-1 py-2 px-4 rounded-lg border ${
                matchType === type
                  ? 'bg-green-600 text-white border-transparent'
                  : 'border-gray-300 hover:border-green-500'
              }`}
            >
              {type}
            </button>
          ))}
        </div>
      </div>

      <div>
        <h3 className="text-lg font-semibold mb-3">Scoring Type</h3>
        <div className="flex space-x-4">
          {(['gross', 'net'] as const).map((type) => (
            <button
              key={type}
              onClick={() => setScoringType(type)}
              className={`flex-1 py-2 px-4 rounded-lg border ${
                scoringType === type
                  ? 'bg-green-600 text-white border-transparent'
                  : 'border-gray-300 hover:border-green-500'
              }`}
            >
              {type.charAt(0).toUpperCase() + type.slice(1)} Scores
            </button>
          ))}
        </div>
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        {/* Team A Selection */}
        <div>
          <h3 className="text-lg font-semibold mb-3">Team A</h3>
          <div className="space-y-2">
            {teamA.map((authId) => {
              const player = players.find(p => p.auth_id === authId);
              return (
                <div
                  key={authId}
                  className="flex items-center justify-between p-2 bg-gray-50 rounded-lg"
                >
                  <span>{player?.name || 'Unknown Player'}</span>
                  <button
                    onClick={() => handleRemovePlayer(authId, 'A')}
                    className="text-red-500 hover:text-red-600"
                  >
                    Remove
                  </button>
                </div>
              );
            })}
            {teamA.length < getTeamSize() && (
              <select
                className="w-full p-2 border rounded-lg"
                onChange={(e) => handlePlayerSelect(e.target.value, 'A')}
                value=""
              >
                <option value="">Add player...</option>
                {availablePlayers.map((player) => (
                  <option key={player.auth_id} value={player.auth_id}>
                    {player.name}
                  </option>
                ))}
              </select>
            )}
          </div>
        </div>

        {/* Team B Selection */}
        <div>
          <h3 className="text-lg font-semibold mb-3">Team B</h3>
          <div className="space-y-2">
            {teamB.map((authId) => {
              const player = players.find(p => p.auth_id === authId);
              return (
                <div
                  key={authId}
                  className="flex items-center justify-between p-2 bg-gray-50 rounded-lg"
                >
                  <span>{player?.name || 'Unknown Player'}</span>
                  <button
                    onClick={() => handleRemovePlayer(authId, 'B')}
                    className="text-red-500 hover:text-red-600"
                  >
                    Remove
                  </button>
                </div>
              );
            })}
            {teamB.length < getTeamSize() && (
              <select
                className="w-full p-2 border rounded-lg"
                onChange={(e) => handlePlayerSelect(e.target.value, 'B')}
                value=""
              >
                <option value="">Add player...</option>
                {availablePlayers.map((player) => (
                  <option key={player.auth_id} value={player.auth_id}>
                    {player.name}
                  </option>
                ))}
              </select>
            )}
          </div>
        </div>
      </div>

      <div className="border-t pt-6">
        <h3 className="text-lg font-semibold mb-3">Bet Settings</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm text-gray-600 mb-1">Front Nine</label>
            <div className="relative">
              <DollarSign className="absolute left-2 top-2.5 h-4 w-4 text-gray-400" />
              <input
                type="number"
                value={frontNineBet}
                onChange={(e) => setFrontNineBet(Number(e.target.value))}
                min="0"
                step="5"
                className="pl-8 w-full p-2 border rounded-lg"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1">Back Nine</label>
            <div className="relative">
              <DollarSign className="absolute left-2 top-2.5 h-4 w-4 text-gray-400" />
              <input
                type="number"
                value={backNineBet}
                onChange={(e) => setBackNineBet(Number(e.target.value))}
                min="0"
                step="5"
                className="pl-8 w-full p-2 border rounded-lg"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1">Total Match</label>
            <div className="relative">
              <DollarSign className="absolute left-2 top-2.5 h-4 w-4 text-gray-400" />
              <input
                type="number"
                value={totalBet}
                onChange={(e) => setTotalBet(Number(e.target.value))}
                min="0"
                step="5"
                className="pl-8 w-full p-2 border rounded-lg"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1">Birdie Bet</label>
            <div className="relative">
              <DollarSign className="absolute left-2 top-2.5 h-4 w-4 text-gray-400" />
              <input
                type="number"
                value={birdieBet}
                onChange={(e) => setBirdieBet(Number(e.target.value))}
                min="0"
                className="pl-8 w-full p-2 border rounded-lg"
              />
            </div>
          </div>
        </div>
      </div>

      <button
        onClick={handleSave}
        disabled={!isValid}
        className="w-full bg-green-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-green-500 transition-colors disabled:opacity-50 disabled:hover:bg-green-600"
      >
        Create Match
      </button>
    </div>
  );
}