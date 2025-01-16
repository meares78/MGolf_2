import React, { useState, useEffect } from 'react';
import { useParams, useSearchParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { Flag, CircleDot, Users } from 'lucide-react';
import { availableRounds } from '../data/rounds';
import { courses } from '../data/courses';
import { supabase } from '../lib/supabase';
import { matchTeeFromId } from '../utils/teeMatching';
import MatchSetup from '../components/MatchSetup';
import MatchList from '../components/MatchList';

interface Match {
  id: string;
  type: '1v1' | '2v2';
  teamA: string[];
  teamB: string[];
  front_nine_bet: number;
  back_nine_bet: number;
  total_bet: number;
  birdie_bet: number;
  scoringType: 'gross' | 'net';
}

interface DBRound {
  id: string;
  external_id: string | null;
  course_name: string;
  date: string;
  created_by: string;
}

interface FinalizedScore {
  total_gross: number;
  total_net: number;
  course_handicap: number;
  finalized_at: string;
}

export default function RoundDetails() {
  const { id } = useParams<{ id: string }>();
  const [searchParams] = useSearchParams();
  const teeId = searchParams.get('tee');
  const navigate = useNavigate();
  const { user } = useAuth();
  
  const [dbRound, setDbRound] = useState<DBRound | null>(null);
  const [matches, setMatches] = useState<Match[]>([]);
  const [finalizedScore, setFinalizedScore] = useState<FinalizedScore | null>(null);
  const [showMatchSetup, setShowMatchSetup] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Get round details - either from availableRounds or parse from custom round ID
  const getRoundDetails = () => {
    if (!id) return null;

    // Check if it's a predefined round
    const predefinedRound = availableRounds.find(r => r.id === id);
    if (predefinedRound) return predefinedRound;

    // If it's a custom round (format: custom-timestamp)
    if (id.startsWith('custom-')) {
      // Extract course name from teeId (format: coursename-teename-color)
      const courseName = teeId?.split('-')[0];
      if (!courseName) return null;

      // Find the course
      const course = courses.find(c => c.name.toLowerCase() === courseName);
      if (!course) return null;

      // Create a round object
      return {
        id,
        date: new Date().toISOString().split('T')[0],
        time: new Date().toLocaleTimeString(),
        courseName: course.name,
        teeOptions: course.tees.map(tee => ({
          id: `${course.name.toLowerCase()}-${tee.name.toLowerCase()}-${tee.color.toLowerCase()}`.replace(/\s+/g, '-'),
          name: tee.name,
          color: tee.color,
          rating: tee.rating,
          slope: tee.slope,
          handicapHoles: tee.holes.map(h => h.handicap)
        }))
      };
    }

    return null;
  };

  const roundDetails = getRoundDetails();
  const course = courses.find(c => c?.name === roundDetails?.courseName);
  const tee = course?.tees && teeId ? matchTeeFromId(teeId, course.name, course.tees) : undefined;

  useEffect(() => {
    async function initializeRound() {
      if (!id || !user?.auth_id || !roundDetails) return;

      try {
        setError(null);
        
        // First, get or create the round
        let roundId: string;
        
        const { data: existingRound, error: fetchError } = await supabase
          .from('rounds')
          .select('*')
          .eq('external_id', id)
          .maybeSingle();

        if (fetchError) throw fetchError;

        if (existingRound) {
          setDbRound(existingRound);
          roundId = existingRound.id;
        } else {
          const { data: newRound, error: insertError } = await supabase
            .from('rounds')
            .insert({
              external_id: id,
              course_name: roundDetails.courseName,
              date: roundDetails.date,
              created_by: user.auth_id
            })
            .select()
            .single();

          if (insertError) throw insertError;
          if (!newRound) throw new Error('Failed to create round');
          
          setDbRound(newRound);
          roundId = newRound.id;
        }

        // Fetch finalized score and matches
        const [finalizedResponse, matchesResponse] = await Promise.all([
          supabase
            .from('finalized_scores')
            .select('*')
            .eq('round_id', roundId)
            .eq('auth_id', user.auth_id)
            .maybeSingle(),
          supabase
            .from('matches')
            .select(`
              *,
              match_players (
                auth_id,
                team
              )
            `)
            .eq('round_id', roundId)
        ]);

        if (finalizedResponse.error) throw finalizedResponse.error;
        if (matchesResponse.error) throw matchesResponse.error;

        if (finalizedResponse.data) {
          setFinalizedScore(finalizedResponse.data);
        }

        if (matchesResponse.data) {
          const formattedMatches = matchesResponse.data
            .filter(match => ['1v1', '2v2'].includes(match.match_type))
            .map(match => {
              // Group participants by team
              const participants = match.match_players || [];
              const teamA = participants
                .filter(p => p.team === 'A')
                .map(p => p.auth_id);
              const teamB = participants
                .filter(p => p.team === 'B')
                .map(p => p.auth_id);

              return {
                id: match.id,
                type: match.match_type as '1v1' | '2v2',
                teamA,
                teamB,
                front_nine_bet: match.front_nine_bet,
                back_nine_bet: match.back_nine_bet,
                total_bet: match.total_bet,
                birdie_bet: match.birdie_bet,
                scoringType: match.scoring_type
              };
            });
          setMatches(formattedMatches);
        }
      } catch (error) {
        console.error('Error initializing round:', error);
        setError('Error loading round data');
      } finally {
        setLoading(false);
      }
    }

    initializeRound();
  }, [id, user, roundDetails]);

  const handleSaveMatch = async (match: Match) => {
    if (!dbRound?.id) return;

    try {
      // First create the match
      const { data: matchData, error: matchError } = await supabase
        .from('matches')
        .insert({
          round_id: dbRound.id,
          match_type: match.type,
          scoring_type: match.scoringType,
          front_nine_bet: match.front_nine_bet,
          back_nine_bet: match.back_nine_bet,
          total_bet: match.total_bet,
          birdie_bet: match.birdie_bet
        })
        .select()
        .single();

      if (matchError) throw matchError;

      // Create match players with teams
      const players = [
        ...match.teamA.map(authId => ({
          match_id: matchData.id,
          auth_id: authId,
          team: 'A'
        })),
        ...match.teamB.map(authId => ({
          match_id: matchData.id,
          auth_id: authId,
          team: 'B'
        }))
      ];

      const { error: playersError } = await supabase
        .from('match_players')
        .insert(players);

      if (playersError) throw playersError;

      setMatches([...matches, {
        ...match,
        id: matchData.id
      }]);
      setShowMatchSetup(false);
    } catch (error) {
      console.error('Error saving match:', error);
      setError('Failed to save match');
    }
  };

  const handleDeleteMatch = async (matchId: string) => {
    try {
      await supabase
        .from('matches')
        .delete()
        .eq('id', matchId);

      setMatches(matches.filter(m => m.id !== matchId));
    } catch (error) {
      console.error('Error deleting match:', error);
      setError('Failed to delete match');
    }
  };

  if (loading) {
    return <div className="text-center py-8">Loading...</div>;
  }

  if (error) {
    return <div className="text-center py-8 text-red-500">{error}</div>;
  }

  if (!roundDetails || !tee) {
    return <div className="text-center py-8">Round not found</div>;
  }

  // Format the date properly
  const formattedDate = new Date(roundDetails.date + 'T12:00:00').toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    year: 'numeric'
  });

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">{roundDetails.courseName}</h1>
        <div className="flex items-center space-x-2 text-gray-600 mt-2">
          <Flag className="w-4 h-4" />
          <span>{tee.name} ({tee.color})</span>
          <span>•</span>
          <span>{formattedDate}</span>
        </div>
      </div>

      {/* Score Entry Section */}
      <div className="bg-white rounded-lg shadow-lg p-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-xl font-semibold">Your Score</h2>
            <p className="text-gray-600 mt-1">
              {finalizedScore ? (
                <>
                  Gross: {finalizedScore.total_gross} • Net: {finalizedScore.total_net}
                </>
              ) : (
                'Enter or update your score for this round'
              )}
            </p>
          </div>
          {finalizedScore ? (
            <div className="flex items-center space-x-2 text-green-600">
              <CircleDot className="h-5 w-5" />
              <span className="font-medium">Score Finalized</span>
            </div>
          ) : (
            <button
              onClick={() => navigate(`/rounds/${id}/score?tee=${teeId}`)}
              className="flex items-center space-x-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-500 transition-colors"
            >
              <CircleDot className="h-4 w-4" />
              <span>Enter Score</span>
            </button>
          )}
        </div>
      </div>

      {/* Matches Section */}
      <div className="bg-white rounded-lg shadow-lg p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold">Matches</h2>
          <button
            onClick={() => setShowMatchSetup(!showMatchSetup)}
            className="flex items-center space-x-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-500 transition-colors"
          >
            <Users className="h-4 w-4" />
            <span>{showMatchSetup ? 'Cancel' : 'New Match'}</span>
          </button>
        </div>

        {showMatchSetup ? (
          <MatchSetup
            roundId={id}
            onSave={handleSaveMatch}
          />
        ) : (
          <MatchList
            matches={matches}
            onDelete={handleDeleteMatch}
          />
        )}
      </div>
    </div>
  );
}