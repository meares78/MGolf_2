import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { Trophy, Loader2 } from 'lucide-react';

interface Player {
  id: string;
  name: string;
  auth_id: string;
}

interface PlayerWinnings {
  name: string;
  netWinnings: number;
  skinWinnings: number;
  twoWinnings: number;
  totalWinnings: number;
}

export default function MoneyLeaderboard() {
  const [players, setPlayers] = useState<Player[]>([]);
  const [winnings, setWinnings] = useState<PlayerWinnings[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        // Fetch all players
        const { data: playersData, error: playersError } = await supabase
          .from('players')
          .select('*')
          .order('name');

        if (playersError) throw playersError;
        setPlayers(playersData || []);

        // Fetch all winnings data
        const [netResults, skins, twos] = await Promise.all([
          supabase.from('round_results').select('*'),
          supabase.from('skins').select('*'),
          supabase.from('twos').select('*')
        ]);

        if (netResults.error) throw netResults.error;
        if (skins.error) throw skins.error;
        if (twos.error) throw twos.error;

        // Calculate winnings for each player
        const playerWinnings = playersData?.map(player => {
          // Calculate net winnings
          const netWinnings = netResults.data
            .filter(result => result.auth_id === player.auth_id)
            .reduce((sum, result) => sum + (result.payout || 0), 0);

          // Calculate skin winnings
          const skinWinnings = skins.data
            .filter(skin => skin.auth_id === player.auth_id)
            .reduce((sum, skin) => sum + (skin.payout || 0), 0);

          // Calculate two winnings
          const twoWinnings = twos.data
            .filter(two => two.auth_id === player.auth_id)
            .reduce((sum, two) => sum + (two.payout || 0), 0);

          return {
            name: player.name,
            netWinnings,
            skinWinnings,
            twoWinnings,
            totalWinnings: netWinnings + skinWinnings + twoWinnings
          };
        }) || [];

        // Sort by total winnings
        playerWinnings.sort((a, b) => b.totalWinnings - a.totalWinnings);
        setWinnings(playerWinnings);
      } catch (error) {
        console.error('Error fetching data:', error);
        setError('Failed to load leaderboard data');
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, []);

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

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
        <div className="flex items-center space-x-2 mb-6">
          <Trophy className="h-6 w-6 text-green-600" />
          <h1 className="text-2xl font-bold text-gray-900">Money Leaderboard</h1>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Position
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Player
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Net Winnings
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Skin Winnings
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Two Winnings
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {winnings.map((player, index) => (
                <tr key={player.name} className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {player.name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-right text-gray-900">
                    ${player.netWinnings}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-right text-gray-900">
                    ${player.skinWinnings}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-right text-gray-900">
                    ${player.twoWinnings}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-right font-bold text-green-600">
                    ${player.totalWinnings}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}