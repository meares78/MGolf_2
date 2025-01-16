import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { courses } from '../data/courses';
import { Save, Loader2 } from 'lucide-react';

interface PlayerHandicap {
  id: string;
  player_id: string;
  course_name: string;
  tee_name: string;
  handicap: number;
}

interface Player {
  id: string;
  name: string;
  phone: string;
}

export default function HandicapAdmin() {
  const { user } = useAuth();
  const [players, setPlayers] = useState<Player[]>([]);
  const [handicaps, setHandicaps] = useState<Record<string, Record<string, Record<string, number>>>>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  // Fetch players and their handicaps
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

        // Fetch all handicaps
        const { data: handicapsData, error: handicapsError } = await supabase
          .from('player_handicaps')
          .select('*');

        if (handicapsError) throw handicapsError;

        // Organize handicaps by player_id -> course_name -> tee_key
        const organizedHandicaps: Record<string, Record<string, Record<string, number>>> = {};
        
        // Initialize handicaps for all players and tees
        playersData?.forEach(player => {
          organizedHandicaps[player.id] = {};
          courses.forEach(course => {
            organizedHandicaps[player.id][course.name] = {};
            course.tees.forEach(tee => {
              // Create a unique key for each tee combination
              const teeKey = `${tee.name}-${tee.color}`;
              organizedHandicaps[player.id][course.name][teeKey] = 0;
            });
          });
        });

        // Fill in existing handicaps
        handicapsData?.forEach((handicap: PlayerHandicap) => {
          if (organizedHandicaps[handicap.player_id]?.[handicap.course_name]) {
            // Find the matching tee to get the color
            const course = courses.find(c => c.name === handicap.course_name);
            const tee = course?.tees.find(t => t.name === handicap.tee_name);
            if (tee) {
              const teeKey = `${handicap.tee_name}-${tee.color}`;
              organizedHandicaps[handicap.player_id][handicap.course_name][teeKey] = handicap.handicap;
            }
          }
        });

        setHandicaps(organizedHandicaps);
      } catch (error) {
        console.error('Error fetching data:', error);
        setError('Failed to load data');
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, []);

  const handleHandicapChange = (playerId: string, courseName: string, teeKey: string, value: string) => {
    const numericValue = parseFloat(value) || 0;
    setHandicaps(prev => ({
      ...prev,
      [playerId]: {
        ...prev[playerId],
        [courseName]: {
          ...(prev[playerId]?.[courseName] || {}),
          [teeKey]: numericValue
        }
      }
    }));
  };

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    setSuccess(null);

    try {
      // Create a Set to track unique combinations and prevent duplicates
      const uniqueCombinations = new Set<string>();
      const updates = [];

      for (const playerId in handicaps) {
        for (const courseName in handicaps[playerId]) {
          for (const teeKey in handicaps[playerId][courseName]) {
            const [teeName] = teeKey.split('-');
            const handicapValue = handicaps[playerId][courseName][teeKey];

            // Create a unique key for this combination
            const combinationKey = `${playerId}-${courseName}-${teeName}`;

            // Only add if we haven't seen this combination before
            if (!uniqueCombinations.has(combinationKey)) {
              uniqueCombinations.add(combinationKey);
              updates.push({
                player_id: playerId,
                course_name: courseName,
                tee_name: teeName,
                handicap: handicapValue
              });
            }
          }
        }
      }

      // Process updates in smaller batches to avoid potential issues
      const batchSize = 50;
      for (let i = 0; i < updates.length; i += batchSize) {
        const batch = updates.slice(i, i + batchSize);
        
        const { error: upsertError } = await supabase
          .from('player_handicaps')
          .upsert(batch, {
            onConflict: 'player_id,course_name,tee_name',
            ignoreDuplicates: true // Add this to handle any remaining duplicates gracefully
          });

        if (upsertError) throw upsertError;
      }

      setSuccess('All handicaps saved successfully');
    } catch (error) {
      console.error('Error saving handicaps:', error);
      setError('Failed to save handicaps');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 className="w-8 h-8 animate-spin text-green-600" />
      </div>
    );
  }

  // Generate column headers with unique tee combinations
  const columnHeaders = courses.flatMap(course =>
    course.tees.map(tee => ({
      id: `${course.name}-${tee.name}-${tee.color}`,
      courseName: course.name,
      teeName: tee.name,
      teeColor: tee.color,
      teeKey: `${tee.name}-${tee.color}`
    }))
  );

  return (
    <div className="max-w-[95%] mx-auto px-4 py-8">
      <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold text-gray-900">Handicap Management</h1>
          <button
            onClick={handleSave}
            disabled={saving}
            className="flex items-center space-x-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-500 transition-colors disabled:opacity-50"
          >
            {saving ? (
              <Loader2 className="w-4 h-4 animate-spin" />
            ) : (
              <Save className="w-4 h-4" />
            )}
            <span>{saving ? 'Saving...' : 'Save All Handicaps'}</span>
          </button>
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

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider sticky left-0 bg-gray-50">
                  Player
                </th>
                {columnHeaders.map(header => (
                  <th
                    key={header.id}
                    className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                  >
                    {header.courseName}<br/>{header.teeName} ({header.teeColor})
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {players.map((player) => (
                <tr key={player.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 sticky left-0 bg-white">
                    {player.name}
                  </td>
                  {columnHeaders.map(header => (
                    <td key={`${player.id}-${header.id}`} className="px-6 py-4 whitespace-nowrap">
                      <input
                        type="number"
                        step="0.1"
                        value={handicaps[player.id]?.[header.courseName]?.[header.teeKey] || ''}
                        onChange={(e) => handleHandicapChange(player.id, header.courseName, header.teeKey, e.target.value)}
                        className="w-24 border-gray-300 rounded-md shadow-sm focus:border-green-500 focus:ring-green-500"
                      />
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}