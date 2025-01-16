import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Navbar from './components/Navbar';
import Dashboard from './pages/Dashboard';
import NewRound from './pages/NewRound';
import RoundDetails from './pages/RoundDetails';
import ScoreEntryPage from './pages/ScoreEntryPage';
import HandicapAdmin from './pages/HandicapAdmin';
import Results from './pages/Results';
import ResultsAdmin from './pages/ResultsAdmin';
import MoneyLeaderboard from './pages/MoneyLeaderboard';
import MatchLeaderboard from './pages/MatchLeaderboard';
import Matches from './pages/Matches';
import MatchResults from './pages/MatchResults';
import Login from './pages/Login';
import { AuthProvider } from './contexts/AuthContext';
import { useAuth } from './contexts/AuthContext';

// Protected Route wrapper
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  
  if (loading) {
    return <div className="min-h-screen flex items-center justify-center">Loading...</div>;
  }
  
  if (!user) {
    return <Navigate to="/login" replace />;
  }
  
  return <>{children}</>;
}

// Admin Route wrapper
function AdminRoute({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const adminPhones = ['+18563812930', '+18563414490']; // Admin phone numbers
  
  if (loading) {
    return <div className="min-h-screen flex items-center justify-center">Loading...</div>;
  }
  
  if (!user || !adminPhones.includes(user.phone)) {
    return <Navigate to="/" replace />;
  }
  
  return <>{children}</>;
}

function AppRoutes() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route
          path="/*"
          element={
            <ProtectedRoute>
              <>
                <Navbar />
                <main className="container mx-auto px-4 py-8">
                  <Routes>
                    <Route path="/" element={<Dashboard />} />
                    <Route path="/rounds/new" element={<NewRound />} />
                    <Route path="/rounds/:id" element={<RoundDetails />} />
                    <Route path="/rounds/:id/score" element={<ScoreEntryPage />} />
                    <Route path="/matches" element={<Matches />} />
                    <Route path="/matches/:matchId" element={<MatchResults />} />
                    <Route path="/match-leaderboard" element={<MatchLeaderboard />} />
                    <Route path="/results" element={<Results />} />
                    <Route path="/leaderboard" element={<MoneyLeaderboard />} />
                    <Route
                      path="/admin/handicaps"
                      element={
                        <AdminRoute>
                          <HandicapAdmin />
                        </AdminRoute>
                      }
                    />
                    <Route
                      path="/admin/results"
                      element={
                        <AdminRoute>
                          <ResultsAdmin />
                        </AdminRoute>
                      }
                    />
                    <Route path="*" element={<Navigate to="/" replace />} />
                  </Routes>
                </main>
              </>
            </ProtectedRoute>
          }
        />
      </Routes>
    </div>
  );
}

function App() {
  return (
    <Router>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </Router>
  );
}

export default App;