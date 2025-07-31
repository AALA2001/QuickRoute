import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

import { AuthProvider, ProtectedRoute, AdminRoute } from './contexts/AuthContext';
import Layout from './components/Layout/Layout';
import Home from './pages/Home';
import Login from './pages/Auth/Login';
import Signup from './pages/Auth/Signup';
import Dashboard from './pages/Dashboard/Dashboard';
import Profile from './pages/Profile/Profile';
import ThreatReport from './pages/Threats/ThreatReport';
import ThreatList from './pages/Threats/ThreatList';
import ThreatDetail from './pages/Threats/ThreatDetail';
import AdminDashboard from './pages/Admin/AdminDashboard';
import AdminUsers from './pages/Admin/AdminUsers';
import AdminReports from './pages/Admin/AdminReports';
import NotFound from './pages/NotFound';

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="App">
          <Routes>
            {/* Public routes */}
            <Route path="/" element={<Home />} />
            <Route path="/login" element={<Login />} />
            <Route path="/signup" element={<Signup />} />
            
            {/* Protected routes with layout */}
            <Route path="/dashboard" element={
              <ProtectedRoute>
                <Layout>
                  <Dashboard />
                </Layout>
              </ProtectedRoute>
            } />
            
            <Route path="/profile" element={
              <ProtectedRoute>
                <Layout>
                  <Profile />
                </Layout>
              </ProtectedRoute>
            } />
            
            <Route path="/threats/report" element={
              <ProtectedRoute>
                <Layout>
                  <ThreatReport />
                </Layout>
              </ProtectedRoute>
            } />
            
            <Route path="/threats" element={
              <ProtectedRoute>
                <Layout>
                  <ThreatList />
                </Layout>
              </ProtectedRoute>
            } />
            
            <Route path="/threats/:id" element={
              <ProtectedRoute>
                <Layout>
                  <ThreatDetail />
                </Layout>
              </ProtectedRoute>
            } />
            
            {/* Admin routes */}
            <Route path="/admin" element={
              <AdminRoute>
                <Layout>
                  <AdminDashboard />
                </Layout>
              </AdminRoute>
            } />
            
            <Route path="/admin/users" element={
              <AdminRoute>
                <Layout>
                  <AdminUsers />
                </Layout>
              </AdminRoute>
            } />
            
            <Route path="/admin/reports" element={
              <AdminRoute>
                <Layout>
                  <AdminReports />
                </Layout>
              </AdminRoute>
            } />
            
            {/* Redirects */}
            <Route path="/app" element={<Navigate to="/dashboard" replace />} />
            
            {/* 404 */}
            <Route path="*" element={<NotFound />} />
          </Routes>
          
          {/* Toast notifications */}
          <ToastContainer
            position="top-right"
            autoClose={5000}
            hideProgressBar={false}
            newestOnTop={false}
            closeOnClick
            rtl={false}
            pauseOnFocusLoss
            draggable
            pauseOnHover
            theme="light"
            toastClassName="font-sans"
          />
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;