import React, { createContext, useContext, useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';

export const AUTHORIZED_USERS = {
  '+18563812930': { id: '1', name: 'Chris Meares' },
  '+18563414490': { id: '2', name: 'Tim Tullio' },
  '+1609579940': { id: '3', name: 'Dan Ayars' },
  '+18563696658': { id: '4', name: 'Dave Ayars' },
  '+16098203771': { id: '5', name: 'Gil Moniz' },
  '+18563050314': { id: '6', name: 'Rocky Dare' },
  '+18568168735': { id: '7', name: 'Joe Zulli' },
  '+18564197121': { id: '8', name: 'Ryan Cass' },
  '+18569046062': { id: '9', name: 'Joey Russo' },
  '+18564667354': { id: '10', name: "John O'Brien" },
  '+16099328795': { id: '11', name: 'Ed Kochanek' },
  '+18562292916': { id: '12', name: 'Jimmy Gillespie' }
};

interface User {
  id: string;
  auth_id: string;
  name: string;
  phone: string;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  signIn: (phone: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

function generateSecurePassword(userId: string): string {
  return `GolfBuddy${userId}!2025`;
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const initAuth = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        
        if (session?.user) {
          const { data: player } = await supabase
            .from('players')
            .select('*')
            .eq('auth_id', session.user.id)
            .single();

          if (player) {
            setUser({
              id: player.id,
              auth_id: session.user.id,
              name: player.name,
              phone: player.phone
            });
          } else {
            await signOut();
          }
        }
      } catch (error) {
        console.error('Auth initialization error:', error);
        await signOut();
      } finally {
        setLoading(false);
      }
    };

    initAuth();
  }, []);

  const signIn = async (phone: string) => {
    setLoading(true);
    try {
      // Format phone number
      const formattedPhone = phone.startsWith('+1') ? phone : `+1${phone}`;
      const authorizedUser = AUTHORIZED_USERS[formattedPhone];
      
      if (!authorizedUser) {
        throw new Error('Unauthorized phone number');
      }

      // Generate email and password for auth
      const email = `user${authorizedUser.id}@golfbuddy.app`;
      const password = generateSecurePassword(authorizedUser.id);

      // Sign in or sign up
      let authUser;
      const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (signInError) {
        const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: {
              name: authorizedUser.name,
              phone: formattedPhone
            }
          }
        });

        if (signUpError) throw signUpError;
        authUser = signUpData.user;
      } else {
        authUser = signInData.user;
      }

      if (!authUser) throw new Error('Authentication failed');

      // Get or create player record
      const { data: existingPlayer } = await supabase
        .from('players')
        .select('*')
        .eq('auth_id', authUser.id)
        .single();

      if (existingPlayer) {
        setUser({
          id: existingPlayer.id,
          auth_id: authUser.id,
          name: existingPlayer.name,
          phone: existingPlayer.phone
        });
      } else {
        // Create new player record
        const { data: newPlayer, error: createError } = await supabase
          .from('players')
          .insert({
            auth_id: authUser.id,
            name: authorizedUser.name,
            phone: formattedPhone
          })
          .select()
          .single();

        if (createError) throw createError;
        
        setUser({
          id: newPlayer.id,
          auth_id: authUser.id,
          name: newPlayer.name,
          phone: newPlayer.phone
        });
      }

      navigate('/');
    } catch (error) {
      console.error('Sign in error:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const signOut = async () => {
    try {
      await supabase.auth.signOut();
      setUser(null);
      navigate('/login');
    } catch (error) {
      console.error('Sign out error:', error);
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, signIn, signOut }}>
      {!loading && children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}