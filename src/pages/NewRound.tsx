import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { courses } from '../data/courses';
import { Flag } from 'lucide-react';

export default function NewRound() {
  const [selectedCourse, setSelectedCourse] = useState('');
  const [selectedTee, setSelectedTee] = useState('');
  const navigate = useNavigate();

  // Get the course object for the selected course
  const course = courses.find(c => c.name === selectedCourse);

  // Helper function to get the display color
  const getDisplayColor = (color: string) => {
    // Handle compound colors like 'gold/blue'
    if (color.includes('/')) {
      const [primary, secondary] = color.split('/');
      return `${primary.charAt(0).toUpperCase() + primary.slice(1)}/${secondary.charAt(0).toUpperCase() + secondary.slice(1)}`;
    }
    return color.charAt(0).toUpperCase() + color.slice(1);
  };

  // Helper function to get the background color class
  const getTeeColorClass = (color: string) => {
    const colorMap: Record<string, string> = {
      'black': 'bg-gray-900',
      'gold': 'bg-yellow-600',
      'blue': 'bg-blue-600',
      'white': 'bg-gray-100',
      'gold/blue': 'bg-gradient-to-r from-yellow-600 to-blue-600'
    };
    return colorMap[color] || 'bg-gray-400';
  };

  // Generate tee ID
  const generateTeeId = (courseName: string, teeName: string, color: string) => {
    return `${courseName.toLowerCase()}-${teeName.toLowerCase()}-${color.toLowerCase()}`.replace(/\s+/g, '-');
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (selectedCourse && selectedTee) {
      // Generate a unique round ID
      const roundId = `custom-${Date.now()}`;
      // Navigate to the round details page with the selected tee
      navigate(`/rounds/${roundId}?tee=${selectedTee}`);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-8">
      <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">Start New Round</h1>
        
        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Course Selection */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-4">
              Select Course
            </label>
            <div className="grid gap-3">
              {courses.map((course) => (
                <button
                  key={course.name}
                  type="button"
                  onClick={() => {
                    setSelectedCourse(course.name);
                    setSelectedTee(''); // Reset tee selection
                  }}
                  className={`w-full text-left p-4 rounded-lg border transition-colors ${
                    selectedCourse === course.name
                      ? 'border-green-500 ring-2 ring-green-500 ring-opacity-50'
                      : 'border-gray-200 hover:border-green-200 hover:bg-green-50/50'
                  }`}
                >
                  <div className="font-medium text-gray-900">{course.name}</div>
                  <div className="text-sm text-gray-500 mt-1">
                    {course.tees.length} tee options available
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Tee Selection */}
          {selectedCourse && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-4">
                Select Tees
              </label>
              <div className="grid gap-3">
                {course?.tees.map((tee) => {
                  const teeId = generateTeeId(selectedCourse, tee.name, tee.color);
                  return (
                    <button
                      key={teeId}
                      type="button"
                      onClick={() => setSelectedTee(teeId)}
                      className={`w-full p-4 rounded-lg border transition-colors ${
                        selectedTee === teeId
                          ? 'border-green-500 ring-2 ring-green-500 ring-opacity-50'
                          : 'border-gray-200 hover:border-green-200 hover:bg-green-50/50'
                      }`}
                    >
                      <div className="flex items-center space-x-4">
                        <div className={`w-6 h-6 rounded-full ${getTeeColorClass(tee.color)} border border-gray-300`} />
                        <div className="flex-1">
                          <div className="font-medium text-gray-900">
                            {getDisplayColor(tee.color)} Tees
                          </div>
                          <div className="text-sm text-gray-500">
                            Rating: {tee.rating} / Slope: {tee.slope}
                          </div>
                        </div>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {/* Submit Button */}
          <button
            type="submit"
            disabled={!selectedCourse || !selectedTee}
            className="w-full bg-green-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-green-500 transition-colors disabled:opacity-50 disabled:hover:bg-green-600"
          >
            Start Round
          </button>
        </form>
      </div>
    </div>
  );
}