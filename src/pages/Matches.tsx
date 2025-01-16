import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, Calendar } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface Match {
  id: string;
  round_id: string;
  match_type: string;
  scoring_type: 'gross' | 'net';
  amount: number;
  created_at: string;
  round: {
    date: string;
    course_name: string;
  };
  match_players: Array<{
    auth_id: string;
    team: string;
    player?: {
      name: string;
    };
  }>;
}

export default function Matches() {
  const [matches, setMatches] = useState<Match[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    async function fetchMatches() {
      try {
        const { data: matchesData, error: matchesError } = await supabase
          .from('matches')
          .select(`
            *,
            round:rounds(date, course_name),
            match_players(
              auth_id,
              team,
              player:players(name)
            )
          `)
          .order('created_at', { ascending: false });

        if (matchesError) throw matchesError;
        setMatches(matchesData || []);
      } catch (error) {
        console.error('Error fetching matches:', error);
        setError('Failed to load matches');
      } finally {
        setLoading(false);
      }
    }

    fetchMatches();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-gray-500">Loading matches...</div>
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

  const formatDate = (dateString: string) => {
    const date = new Date(dateString + 'T12:00:00');
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      month: 'long',
      day: 'numeric'
    });
  };

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Match Results</h1>
      
      <div className="space-y-4">
        {matches.map((match) => {
          const teamA = match.match_players.filter(p => p.team === 'A');
          const teamB = match.match_players.filter(p => p.team === 'B');

          return (
            <button
              key={match.id}
              onClick={() => navigate(`/matches/${match.id}`)}
              className="w-full text-left bg-white rounded-xl shadow-lg p-6 border border-gray-200 hover:border-green-500 transition-colors"
            >
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center space-x-3">
                  <Users className="h-5 w-5 text-gray-500" />
                  <div>
                    <div className="font-medium text-gray-900">
                      {match.match_type} Match
                    </div>
                    <div className="text-sm text-gray-500">
                      {match.scoring_type === 'net' ? 'Net' : 'Gross'} Scoring
                    </div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-sm text-gray-500">Bet Amount</div>
                  <div className="font-medium text-gray-900">
                    ${match.amount}
                  </div>
                </div>
              </div>

              <div className="grid md:grid-cols-2 gap-4 mb-4">
                <div>
                  <div className="text-sm font-medium text-gray-500 mb-1">
                    Team A
                  </div>
                  {teamA.map((participant) => (
                    <div key={participant.auth_id} className="text-gray-900">
                      {participant.player?.name || 'Unknown Player'}
                    </div>
                  ))}
                </div>
                <div>
                  <div className="text-sm font-medium text-gray-500 mb-1">
                    Team B
                  </div>
                  {teamB.map((participant) => (
                    <div key={participant.auth_id} className="text-gray-900">
                      {participant.player?.name || 'Unknown Player'}
                    </div>
                  ))}
                </div>
              </div>

              <div className="flex items-center text-sm text-gray-500">
                <Calendar className="h-4 w-4 mr-1" />
                <span>
                  {match.round.course_name} • {formatDate(match.round.date)}
                </span>
              </div>
            </button>
          );
        })}

        {matches.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            No matches found
          </div>
        )}
      </div>
    </div>
  );
}