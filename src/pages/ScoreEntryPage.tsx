import React, { useState, useEffect } from 'react';
import { useParams, useSearchParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import ScoreEntry from '../components/ScoreEntry';
import { Flag, ArrowLeft } from 'lucide-react';
import { availableRounds } from '../data/rounds';
import { courses } from '../data/courses';
import { supabase } from '../lib/supabase';
import { matchTeeFromId } from '../utils/teeMatching';
import { calculateCourseHandicap } from '../utils/handicap';

interface Score {
  hole_number: number;
  strokes: number;
}

interface DBRound {
  id: string;
  external_id: string | null;
  course_name: string;
  date: string;
  created_by: string;
}

export default function ScoreEntryPage() {
  const { id } = useParams<{ id: string }>();
  const [searchParams] = useSearchParams();
  const teeId = searchParams.get('tee');
  const { user } = useAuth();
  const navigate = useNavigate();
  
  const [dbRound, setDbRound] = useState<DBRound | null>(null);
  const [scores, setScores] = useState<Score[]>([]);
  const [isFinalized, setIsFinalized] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

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

        // Then fetch scores and finalized status
        const [scoresResponse, finalizedResponse] = await Promise.all([
          supabase
            .from('scores')
            .select('*')
            .eq('round_id', roundId)
            .eq('auth_id', user.auth_id),
          supabase
            .from('finalized_scores')
            .select('*')
            .eq('round_id', roundId)
            .eq('auth_id', user.auth_id)
            .maybeSingle()
        ]);

        if (scoresResponse.error) throw scoresResponse.error;
        if (finalizedResponse.error) throw finalizedResponse.error;

        if (scoresResponse.data) {
          setScores(scoresResponse.data);
        }

        setIsFinalized(!!finalizedResponse.data);

      } catch (error) {
        console.error('Error initializing round:', error);
        setError('Error loading round data');
      } finally {
        setLoading(false);
      }
    }

    initializeRound();
  }, [id, user, roundDetails]);

  const handleSaveScores = async (newScores: number[]) => {
    if (!dbRound?.id || !user?.auth_id || isFinalized) return;

    setSaving(true);
    try {
      const scoreRecords = newScores.map((strokes, index) => ({
        round_id: dbRound.id,
        auth_id: user.auth_id,
        hole_number: index + 1,
        strokes
      }));

      // Delete existing scores
      await supabase
        .from('scores')
        .delete()
        .eq('round_id', dbRound.id)
        .eq('auth_id', user.auth_id);

      // Insert new scores
      const { error } = await supabase
        .from('scores')
        .insert(scoreRecords);

      if (error) throw error;
    } catch (error) {
      console.error('Error saving scores:', error);
      setError('Error saving scores');
    } finally {
      setSaving(false);
    }
  };

  const handleFinalizeScore = async (scores: number[]) => {
    if (!dbRound?.id || !user?.auth_id || !tee) return;

    setSaving(true);
    try {
      // Calculate totals
      const totalGross = scores.reduce((sum, score) => sum + score, 0);
      const courseHandicap = calculateCourseHandicap(
        user.handicapIndex || 0,
        tee.slope,
        tee.rating,
        tee.holes.reduce((sum, hole) => sum + hole.par, 0)
      );
      const totalNet = totalGross - courseHandicap;

      // Save final scores
      await handleSaveScores(scores);

      // Insert finalized score record
      const { error: finalizeError } = await supabase
        .from('finalized_scores')
        .insert({
          round_id: dbRound.id,
          auth_id: user.auth_id,
          total_gross: totalGross,
          total_net: totalNet,
          course_handicap: courseHandicap,
          finalized_at: new Date().toISOString()
        });

      if (finalizeError) throw finalizeError;

      setIsFinalized(true);
      navigate(`/rounds/${id}?tee=${teeId}`);
    } catch (error) {
      console.error('Error finalizing scores:', error);
      setError('Error finalizing scores');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-gray-500">Loading...</div>
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

  if (!roundDetails || !tee) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-gray-500">Round not found</div>
      </div>
    );
  }

  const initialScores = scores.length > 0
    ? Array.from({ length: 18 }, (_, i) => {
        const score = scores.find(s => s.hole_number === i + 1);
        return score ? score.strokes : tee.holes[i].par;
      })
    : undefined;

  // Format the date properly
  const formattedDate = new Date(roundDetails.date + 'T12:00:00').toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    year: 'numeric'
  });

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <button
            onClick={() => navigate(`/rounds/${id}?tee=${teeId}`)}
            className="flex items-center text-gray-600 hover:text-gray-900 mb-2"
          >
            <ArrowLeft className="w-4 h-4 mr-1" />
            Back to Round
          </button>
          <h1 className="text-2xl font-bold text-gray-900">{roundDetails.courseName}</h1>
          <div className="flex items-center space-x-2 text-gray-600 mt-2">
            <Flag className="w-4 h-4" />
            <span>{tee.name} ({tee.color})</span>
            <span>•</span>
            <span>{formattedDate}</span>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-lg p-6">
        <ScoreEntry
          roundId={id}
          courseName={roundDetails.courseName}
          teeId={teeId}
          onSave={handleSaveScores}
          onFinalize={handleFinalizeScore}
          initialScores={initialScores}
          playerHandicap={user?.handicapIndex}
          isFinalized={isFinalized}
          saving={saving}
        />
      </div>
    </div>
  );
}