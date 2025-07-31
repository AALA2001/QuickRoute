import React, { createContext, useContext, useReducer, useEffect } from 'react';
import { authAPI } from '../services/api';
import { toast } from 'react-toastify';

// Auth action types
const AUTH_ACTIONS = {
  LOGIN_START: 'LOGIN_START',
  LOGIN_SUCCESS: 'LOGIN_SUCCESS',
  LOGIN_FAILURE: 'LOGIN_FAILURE',
  LOGOUT: 'LOGOUT',
  SIGNUP_START: 'SIGNUP_START',
  SIGNUP_SUCCESS: 'SIGNUP_SUCCESS',
  SIGNUP_FAILURE: 'SIGNUP_FAILURE',
  LOAD_USER: 'LOAD_USER',
  UPDATE_USER: 'UPDATE_USER',
  CLEAR_ERROR: 'CLEAR_ERROR',
};

// Initial auth state
const initialState = {
  user: null,
  token: localStorage.getItem('cybercare_token'),
  isAuthenticated: false,
  isLoading: true,
  error: null,
};

// Auth reducer
const authReducer = (state, action) => {
  switch (action.type) {
    case AUTH_ACTIONS.LOGIN_START:
    case AUTH_ACTIONS.SIGNUP_START:
      return {
        ...state,
        isLoading: true,
        error: null,
      };

    case AUTH_ACTIONS.LOGIN_SUCCESS:
    case AUTH_ACTIONS.SIGNUP_SUCCESS:
      return {
        ...state,
        user: action.payload.user,
        token: action.payload.token,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      };

    case AUTH_ACTIONS.LOGIN_FAILURE:
    case AUTH_ACTIONS.SIGNUP_FAILURE:
      return {
        ...state,
        user: null,
        token: null,
        isAuthenticated: false,
        isLoading: false,
        error: action.payload,
      };

    case AUTH_ACTIONS.LOGOUT:
      return {
        ...state,
        user: null,
        token: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      };

    case AUTH_ACTIONS.LOAD_USER:
      return {
        ...state,
        user: action.payload,
        isAuthenticated: true,
        isLoading: false,
      };

    case AUTH_ACTIONS.UPDATE_USER:
      return {
        ...state,
        user: { ...state.user, ...action.payload },
      };

    case AUTH_ACTIONS.CLEAR_ERROR:
      return {
        ...state,
        error: null,
      };

    default:
      return state;
  }
};

// Create context
const AuthContext = createContext();

// Auth provider component
export const AuthProvider = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  // Load user on app start
  useEffect(() => {
    const loadUser = async () => {
      const token = localStorage.getItem('cybercare_token');
      
      if (token) {
        try {
          const user = await authAPI.getProfile();
          dispatch({ type: AUTH_ACTIONS.LOAD_USER, payload: user });
        } catch (error) {
          localStorage.removeItem('cybercare_token');
          localStorage.removeItem('cybercare_user');
          dispatch({ type: AUTH_ACTIONS.LOGOUT });
        }
      } else {
        dispatch({ type: AUTH_ACTIONS.LOGOUT });
      }
    };

    loadUser();
  }, []);

  // Login function
  const login = async (credentials) => {
    try {
      dispatch({ type: AUTH_ACTIONS.LOGIN_START });
      
      const response = await authAPI.login(credentials);
      
      if (response.success) {
        localStorage.setItem('cybercare_token', response.token);
        localStorage.setItem('cybercare_user', JSON.stringify(response.user));
        
        dispatch({
          type: AUTH_ACTIONS.LOGIN_SUCCESS,
          payload: { user: response.user, token: response.token },
        });
        
        toast.success('Login successful!');
        return { success: true };
      } else {
        throw new Error(response.message || 'Login failed');
      }
    } catch (error) {
      const errorMessage = error.response?.data?.message || error.message || 'Login failed';
      dispatch({ type: AUTH_ACTIONS.LOGIN_FAILURE, payload: errorMessage });
      toast.error(errorMessage);
      return { success: false, error: errorMessage };
    }
  };

  // Signup function
  const signup = async (userData) => {
    try {
      dispatch({ type: AUTH_ACTIONS.SIGNUP_START });
      
      const response = await authAPI.signup(userData);
      
      if (response.success) {
        localStorage.setItem('cybercare_token', response.token);
        localStorage.setItem('cybercare_user', JSON.stringify(response.user));
        
        dispatch({
          type: AUTH_ACTIONS.SIGNUP_SUCCESS,
          payload: { user: response.user, token: response.token },
        });
        
        toast.success('Registration successful!');
        
        // Check for breach notification
        if (response.user.breachHistory && response.user.breachHistory.length > 0) {
          const breachedSites = response.user.breachHistory[0].breachedIn;
          if (breachedSites.length > 0) {
            toast.warning(
              `Security Alert: Your email was found in ${breachedSites.length} data breach(es). Please check your profile for details.`,
              { autoClose: 10000 }
            );
          }
        }
        
        return { success: true };
      } else {
        throw new Error(response.message || 'Registration failed');
      }
    } catch (error) {
      const errorMessage = error.response?.data?.message || error.message || 'Registration failed';
      dispatch({ type: AUTH_ACTIONS.SIGNUP_FAILURE, payload: errorMessage });
      toast.error(errorMessage);
      return { success: false, error: errorMessage };
    }
  };

  // Logout function
  const logout = async () => {
    try {
      await authAPI.logout();
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      localStorage.removeItem('cybercare_token');
      localStorage.removeItem('cybercare_user');
      dispatch({ type: AUTH_ACTIONS.LOGOUT });
      toast.info('You have been logged out');
    }
  };

  // Update user profile
  const updateUser = (userData) => {
    dispatch({ type: AUTH_ACTIONS.UPDATE_USER, payload: userData });
    localStorage.setItem('cybercare_user', JSON.stringify({ ...state.user, ...userData }));
  };

  // Clear error
  const clearError = () => {
    dispatch({ type: AUTH_ACTIONS.CLEAR_ERROR });
  };

  // Check if user has specific role
  const hasRole = (role) => {
    if (!state.user) return false;
    
    switch (role) {
      case 'admin':
        return state.user.role === 'admin';
      case 'cert_viewer':
        return state.user.role === 'admin' || state.user.role === 'cert_viewer';
      case 'user':
        return ['admin', 'cert_viewer', 'user'].includes(state.user.role);
      default:
        return false;
    }
  };

  // Check if user is admin
  const isAdmin = () => hasRole('admin');

  // Check if user is CERT viewer
  const isCertViewer = () => hasRole('cert_viewer');

  // Get user's breach status
  const getBreachStatus = () => {
    if (!state.user?.breachHistory) return { isBreached: false, count: 0, sites: [] };
    
    const breachedSites = state.user.breachHistory
      .filter(log => log.status === 'breached')
      .flatMap(log => log.breachedIn);
    
    return {
      isBreached: breachedSites.length > 0,
      count: breachedSites.length,
      sites: [...new Set(breachedSites)], // Remove duplicates
    };
  };

  // Token refresh function
  const refreshToken = async () => {
    try {
      const response = await authAPI.refreshToken();
      if (response.success && response.token) {
        localStorage.setItem('cybercare_token', response.token);
        return response.token;
      }
    } catch (error) {
      console.error('Token refresh failed:', error);
      logout();
    }
    return null;
  };

  // Auth context value
  const value = {
    // State
    user: state.user,
    token: state.token,
    isAuthenticated: state.isAuthenticated,
    isLoading: state.isLoading,
    error: state.error,
    
    // Actions
    login,
    signup,
    logout,
    updateUser,
    clearError,
    refreshToken,
    
    // Helpers
    hasRole,
    isAdmin,
    isCertViewer,
    getBreachStatus,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

// Custom hook to use auth context
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

// Protected route component
export const ProtectedRoute = ({ children, requiredRole = 'user' }) => {
  const { isAuthenticated, isLoading, hasRole } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="loading-spinner"></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    window.location.href = '/login';
    return null;
  }

  if (!hasRole(requiredRole)) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-900 mb-4">Access Denied</h1>
          <p className="text-gray-600 mb-6">You don't have permission to access this page.</p>
          <button
            onClick={() => window.history.back()}
            className="btn-primary"
          >
            Go Back
          </button>
        </div>
      </div>
    );
  }

  return children;
};

// Admin route component
export const AdminRoute = ({ children }) => (
  <ProtectedRoute requiredRole="admin">{children}</ProtectedRoute>
);

// CERT route component
export const CertRoute = ({ children }) => (
  <ProtectedRoute requiredRole="cert_viewer">{children}</ProtectedRoute>
);

export default AuthContext;