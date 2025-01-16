import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { DollarSign, Trophy, Target, CircleDot } from 'lucide-react';

interface PlayerResult {
  auth_id: string;
  player_name: string;
  matches_played: number;
  total_front_nine: number;
  total_back_nine: number;
  total_match: number;
  total_birdies: number;
  total_winnings: number;
  matches_won: number;
  matches_lost: number;
  matches_tied: number;
}

interface DailyResult {
  auth_id: string;
  player_name: string;
  match_date: string;
  matches_played: number;
  total_front_nine: number;
  total_back_nine: number;
  total_match: number;
  total_birdies: number;
  total_winnings: number;
}

export default function MatchLeaderboard() {
  const [dates, setDates] = useState<string[]>([]);
  const [selectedDate, setSelectedDate] = useState<string>('all');
  const [results, setResults] = useState<PlayerResult[] | DailyResult[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        setLoading(true);
        setError(null);

        // Fetch available dates
        const { data: datesData, error: datesError } = await supabase
          .from('rounds')
          .select('date')
          .order('date');

        if (datesError) throw datesError;

        const uniqueDates = Array.from(new Set(datesData?.map(d => d.date) || []));
        setDates(uniqueDates);

        // Fetch results based on selected date
        let resultsData;
        if (selectedDate === 'all') {
          const { data, error: resultsError } = await supabase
            .from('match_player_totals')
            .select('*')
            .order('total_winnings', { ascending: false });

          if (resultsError) throw resultsError;
          resultsData = data;
        } else {
          const { data, error: resultsError } = await supabase
            .from('match_player_daily_results')
            .select('*')
            .eq('match_date', selectedDate)
            .order('total_winnings', { ascending: false });

          if (resultsError) throw resultsError;
          resultsData = data;
        }

        setResults(resultsData || []);
      } catch (error) {
        console.error('Error fetching data:', error);
        setError('Failed to load match results');
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, [selectedDate]);

  const formatDate = (dateString: string) => {
    const date = new Date(dateString + 'T12:00:00');
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      month: 'long',
      day: 'numeric'
    });
  };

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

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center space-x-2">
            <DollarSign className="h-6 w-6 text-green-600" />
            <h1 className="text-2xl font-bold text-gray-900">Match Leaderboard</h1>
          </div>
          <select
            value={selectedDate}
            onChange={(e) => setSelectedDate(e.target.value)}
            className="border-gray-300 rounded-lg shadow-sm focus:border-green-500 focus:ring-green-500"
          >
            <option value="all">All Time</option>
            {dates.map((date) => (
              <option key={date} value={date}>
                {formatDate(date)}
              </option>
            ))}
          </select>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Player
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Front Nine
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Back Nine
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Match
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Birdies
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total
                </th>
                {selectedDate === 'all' && (
                  <>
                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      W/L/T
                    </th>
                  </>
                )}
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {results.map((result) => (
                <tr key={`${result.auth_id}-${result.match_date || 'all'}`}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {result.player_name}
                  </td>
                  <td className={`px-6 py-4 whitespace-nowrap text-sm text-right ${
                    result.total_front_nine > 0 ? 'text-green-600' : 
                    result.total_front_nine < 0 ? 'text-red-600' : 'text-gray-500'
                  }`}>
                    {result.total_front_nine > 0 ? '+' : ''}${result.total_front_nine}
                  </td>
                  <td className={`px-6 py-4 whitespace-nowrap text-sm text-right ${
                    result.total_back_nine > 0 ? 'text-green-600' : 
                    result.total_back_nine < 0 ? 'text-red-600' : 'text-gray-500'
                  }`}>
                    {result.total_back_nine > 0 ? '+' : ''}${result.total_back_nine}
                  </td>
                  <td className={`px-6 py-4 whitespace-nowrap text-sm text-right ${
                    result.total_match > 0 ? 'text-green-600' : 
                    result.total_match < 0 ? 'text-red-600' : 'text-gray-500'
                  }`}>
                    {result.total_match > 0 ? '+' : ''}${result.total_match}
                  </td>
                  <td className={`px-6 py-4 whitespace-nowrap text-sm text-right ${
                    result.total_birdies > 0 ? 'text-green-600' : 'text-gray-500'
                  }`}>
                    {result.total_birdies > 0 ? '+' : ''}${result.total_birdies}
                  </td>
                  <td className={`px-6 py-4 whitespace-nowrap text-sm font-bold text-right ${
                    result.total_winnings > 0 ? 'text-green-600' : 
                    result.total_winnings < 0 ? 'text-red-600' : 'text-gray-500'
                  }`}>
                    {result.total_winnings > 0 ? '+' : ''}${result.total_winnings}
                  </td>
                  {selectedDate === 'all' && (
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-right text-gray-500">
                      {(result as PlayerResult).matches_won}/
                      {(result as PlayerResult).matches_lost}/
                      {(result as PlayerResult).matches_tied}
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}