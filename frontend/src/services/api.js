import axios from 'axios';
import { toast } from 'react-toastify';

// Create axios instance with default config
const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('cybercare_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('cybercare_token');
      localStorage.removeItem('cybercare_user');
      window.location.href = '/login';
    }
    
    const message = error.response?.data?.message || 'An error occurred';
    toast.error(message);
    
    return Promise.reject(error);
  }
);

// Authentication API calls
export const authAPI = {
  // User registration
  signup: async (userData) => {
    const response = await api.post('/auth/signup', userData);
    return response.data;
  },

  // User login
  login: async (credentials) => {
    const response = await api.post('/auth/login', credentials);
    return response.data;
  },

  // Get current user profile
  getProfile: async () => {
    const response = await api.get('/auth/me');
    return response.data;
  },

  // Refresh JWT token
  refreshToken: async () => {
    const response = await api.post('/auth/refresh');
    return response.data;
  },

  // Logout
  logout: async () => {
    const response = await api.post('/auth/logout');
    return response.data;
  },
};

// Threat reporting API calls
export const threatAPI = {
  // Submit new threat report
  submitReport: async (reportData) => {
    const response = await api.post('/threats/report', reportData);
    return response.data;
  },

  // Get all threat reports (admin)
  getAllReports: async () => {
    const response = await api.get('/threats/reports');
    return response.data;
  },

  // Get specific threat report
  getReport: async (reportId) => {
    const response = await api.get(`/threats/report/${reportId}`);
    return response.data;
  },

  // Validate threat report (admin)
  validateReport: async (reportId, validationData) => {
    const response = await api.put(`/threats/report/${reportId}/validate`, validationData);
    return response.data;
  },

  // Get user's own reports
  getMyReports: async () => {
    const response = await api.get('/threats/my-reports');
    return response.data;
  },
};

// Notification API calls
export const notificationAPI = {
  // Get user notifications
  getNotifications: async () => {
    const response = await api.get('/notifications');
    return response.data;
  },

  // Mark notification as seen
  markAsSeen: async (notificationId) => {
    const response = await api.put(`/notifications/${notificationId}/seen`);
    return response.data;
  },

  // Mark all notifications as seen
  markAllAsSeen: async () => {
    const response = await api.put('/notifications/mark-all-seen');
    return response.data;
  },
};

// Admin API calls
export const adminAPI = {
  // Get dashboard statistics
  getDashboardStats: async () => {
    const response = await api.get('/admin/dashboard');
    return response.data;
  },

  // Get all users
  getUsers: async () => {
    const response = await api.get('/admin/users');
    return response.data;
  },

  // Update user role
  updateUserRole: async (userId, roleData) => {
    const response = await api.put(`/admin/user/${userId}/role`, roleData);
    return response.data;
  },

  // Get pending reports
  getPendingReports: async () => {
    const response = await api.get('/admin/reports/pending');
    return response.data;
  },

  // Bulk validate reports
  bulkValidate: async (reportIds, action) => {
    const response = await api.post('/admin/bulk-validate', { reportIds, action });
    return response.data;
  },
};

// CERT API calls
export const certAPI = {
  // Export report as PDF
  exportReportPDF: async (reportId) => {
    const response = await api.get(`/cert/export/${reportId}/pdf`, {
      responseType: 'blob',
    });
    return response.data;
  },

  // Export report as JSON
  exportReportJSON: async (reportId) => {
    const response = await api.get(`/cert/export/${reportId}/json`);
    return response.data;
  },

  // Get validated threats for CERT
  getValidatedThreats: async () => {
    const response = await api.get('/cert/validated-threats');
    return response.data;
  },
};

// Utility functions
export const apiUtils = {
  // Upload file (for evidence)
  uploadFile: async (file) => {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await api.post('/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  // Convert file to base64
  fileToBase64: (file) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => resolve(reader.result.split(',')[1]); // Remove data:type/subtype;base64, prefix
      reader.onerror = (error) => reject(error);
    });
  },

  // Download file
  downloadFile: (blob, filename) => {
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  },

  // Format file size
  formatFileSize: (bytes) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  },
};

// Error handling helpers
export const handleApiError = (error, defaultMessage = 'An error occurred') => {
  if (error.response?.data?.message) {
    return error.response.data.message;
  }
  if (error.message) {
    return error.message;
  }
  return defaultMessage;
};

// Status badge helpers
export const getStatusBadge = (status) => {
  const statusMap = {
    'Pending': { color: 'warning', text: 'Pending Review' },
    'Validated': { color: 'success', text: 'Validated' },
    'False Alarm': { color: 'danger', text: 'False Alarm' },
    'Escalated': { color: 'info', text: 'Escalated to CERT' },
  };
  return statusMap[status] || { color: 'gray', text: status };
};

// Date formatting helpers
export const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

export const formatRelativeTime = (dateString) => {
  const date = new Date(dateString);
  const now = new Date();
  const diffInSeconds = Math.floor((now - date) / 1000);
  
  if (diffInSeconds < 60) return 'Just now';
  if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)} minutes ago`;
  if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)} hours ago`;
  if (diffInSeconds < 604800) return `${Math.floor(diffInSeconds / 86400)} days ago`;
  
  return formatDate(dateString);
};

export default api;