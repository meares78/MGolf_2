import React, { useState } from 'react';
import { Club } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { Navigate } from 'react-router-dom';

export default function Login() {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [error, setError] = useState('');
  const { signIn, loading, user } = useAuth();

  // Redirect if already logged in
  if (user) {
    return <Navigate to="/" replace />;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');

    try {
      // Remove any non-numeric characters from the input
      const cleanPhone = phoneNumber.replace(/\D/g, '');
      await signIn(cleanPhone);
    } catch (err) {
      setError('Invalid phone number. Please try again.');
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-green-900 to-black flex items-center justify-center px-4">
      <div className="w-full max-w-md space-y-8">
        {/* Logo */}
        <div className="text-center">
          <div className="flex items-center justify-center space-x-2 text-white mb-4">
            <Club className="h-12 w-12" />
            <span className="text-3xl font-bold">Golf Buddy</span>
          </div>
          <p className="text-white/60">Enter your phone number to continue</p>
        </div>

        {/* Login Form */}
        <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-8 shadow-2xl border border-white/10">
          {error && (
            <div className="bg-red-500/10 border border-red-500 text-red-500 p-3 rounded-lg text-sm mb-6">
              {error}
            </div>
          )}
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="phone" className="block text-sm font-medium text-white/80 mb-2">
                Phone Number
              </label>
              <input
                id="phone"
                type="tel"
                placeholder="(856) 381-2930"
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value)}
                className="w-full bg-white/5 border border-white/10 text-white rounded-lg px-4 py-3 focus:ring-2 focus:ring-green-500 focus:border-transparent placeholder-white/40"
                required
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-green-500 text-white py-3 px-4 rounded-lg font-medium hover:bg-green-400 transition-colors duration-200 disabled:opacity-50 disabled:hover:bg-green-500"
            >
              {loading ? 'Signing in...' : 'Sign In'}
            </button>
          </form>
        </div>

        <div className="text-center text-white/60 text-sm">
          Need help? Contact your club administrator
        </div>
      </div>
    </div>
  );
}