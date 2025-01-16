import React from 'react';
import { Users, DollarSign } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface Match {
  id: string;
  type: '1v1' | '2v2' | '4v4';
  teamA: string[];
  teamB: string[];
  front_nine_bet: number;
  back_nine_bet: number;
  total_bet: number;
  birdie_bet: number;
  scoringType?: 'gross' | 'net';
}

interface MatchListProps {
  matches: Match[];
  onDelete?: (matchId: string) => void;
}

export default function MatchList({ matches, onDelete }: MatchListProps) {
  const [players, setPlayers] = React.useState<Record<string, string>>({});

  React.useEffect(() => {
    async function fetchPlayers() {
      const { data, error } = await supabase
        .from('players')
        .select('auth_id, name');
      
      if (!error && data) {
        const playerMap = data.reduce((acc, player) => {
          acc[player.auth_id] = player.name;
          return acc;
        }, {} as Record<string, string>);
        setPlayers(playerMap);
      }
    }

    fetchPlayers();
  }, []);

  const getPlayerName = (authId: string) => {
    return players[authId] || 'Unknown Player';
  };

  if (matches.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500">
        No matches set up yet
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {matches.map((match) => (
        <div key={match.id} className="bg-white rounded-lg shadow-lg p-6">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center space-x-2">
              <Users className="h-5 w-5 text-gray-600" />
              <h3 className="text-lg font-semibold">{match.type} Match</h3>
              {match.scoringType && (
                <span className="text-sm text-gray-500">
                  ({match.scoringType.charAt(0).toUpperCase() + match.scoringType.slice(1)} Scores)
                </span>
              )}
            </div>
            {onDelete && (
              <button
                onClick={() => onDelete(match.id)}
                className="text-red-500 hover:text-red-600 text-sm"
              >
                Delete Match
              </button>
            )}
          </div>

          <div className="grid md:grid-cols-2 gap-4 mb-6">
            <div>
              <h4 className="text-sm font-medium text-gray-600 mb-2">Team A</h4>
              <div className="space-y-1">
                {match.teamA.map((authId) => (
                  <div key={authId} className="text-gray-900">
                    {getPlayerName(authId)}
                  </div>
                ))}
              </div>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-600 mb-2">Team B</h4>
              <div className="space-y-1">
                {match.teamB.map((authId) => (
                  <div key={authId} className="text-gray-900">
                    {getPlayerName(authId)}
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="border-t pt-4">
            <h4 className="text-sm font-medium text-gray-600 mb-2">Bet Details</h4>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
              <div>
                <span className="text-gray-500">Front Nine:</span>
                <div className="font-medium">${match.front_nine_bet}</div>
              </div>
              <div>
                <span className="text-gray-500">Back Nine:</span>
                <div className="font-medium">${match.back_nine_bet}</div>
              </div>
              <div>
                <span className="text-gray-500">Total Match:</span>
                <div className="font-medium">${match.total_bet}</div>
              </div>
              <div>
                <span className="text-gray-500">Birdie Bet:</span>
                <div className="font-medium">${match.birdie_bet}</div>
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}