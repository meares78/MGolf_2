import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Club, LogOut, Trophy, DollarSign, Users } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';

export default function Navbar() {
  const { user, signOut } = useAuth();
  const navigate = useNavigate();
  const adminPhones = ['+18563812930', '+18563414490']; // Admin phone numbers
  const isAdmin = user && adminPhones.includes(user.phone);

  return (
    <nav className="bg-green-700 text-white shadow-lg">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          <Link to="/" className="flex items-center space-x-2">
            <Club className="h-6 w-6" />
            <span className="font-bold text-xl">Golf Buddy</span>
          </Link>
          
          {user && (
            <div className="flex items-center space-x-4">
              <button
                onClick={() => navigate('/')}
                className="bg-green-600 hover:bg-green-500 px-4 py-2 rounded-md text-sm font-medium"
              >
                Available Rounds
              </button>
              <Link
                to="/results"
                className="flex items-center space-x-1 hover:text-green-200"
              >
                <Trophy className="h-4 w-4" />
                <span>Tournament Results</span>
              </Link>
              <Link
                to="/matches"
                className="flex items-center space-x-1 hover:text-green-200"
              >
                <Users className="h-4 w-4" />
                <span>Matches</span>
              </Link>
              <Link
                to="/match-leaderboard"
                className="flex items-center space-x-1 hover:text-green-200"
              >
                <DollarSign className="h-4 w-4" />
                <span>Match Leaderboard</span>
              </Link>
              <Link
                to="/leaderboard"
                className="flex items-center space-x-1 hover:text-green-200"
              >
                <Trophy className="h-4 w-4" />
                <span>Tournament Leaderboard</span>
              </Link>
              {isAdmin && (
                <Link
                  to="/admin/results"
                  className="flex items-center space-x-1 hover:text-green-200"
                >
                  <Trophy className="h-4 w-4" />
                  <span>Manage Results</span>
                </Link>
              )}
              <button
                onClick={() => signOut()}
                className="flex items-center space-x-1 hover:text-green-200"
              >
                <LogOut className="h-4 w-4" />
                <span>Logout</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </nav>
  );
}