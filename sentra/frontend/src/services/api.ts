// src/services/api.ts
import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export interface User {
  id: string;
  email: string;
  name: string;
  created_at: string;
}

export interface AuthResponse {
  token: string;
  user: User;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface SignupRequest {
  email: string;
  password: string;
  name: string;
}

export interface ThreatReportRequest {
  title: string;
  description: string;
  links?: string[];
  evidence?: string;
}

export interface ThreatReport {
  id: string;
  title: string;
  description: string;
  links: any;
  evidence?: string;
  status: string;
  submitted_by: string;
  virus_total_result?: any;
  admin_remarks?: string;
  validated_by?: string;
  created_at: string;
  updated_at: string;
}

export interface Notification {
  id: string;
  user_id: string;
  type: string;
  title: string;
  message: string;
  status: string;
  created_at: string;
}

export const authAPI = {
  login: (credentials: LoginRequest) => api.post<AuthResponse>('/login', credentials),
  signup: (userData: SignupRequest) => api.post<AuthResponse>('/signup', userData),
  getProfile: () => api.get<User>('/me'),
};

export const reportsAPI = {
  submit: (reportData: ThreatReportRequest) => api.post('/reports', reportData),
  getAll: () => api.get<ThreatReport[]>('/reports'),
  getById: (id: string) => api.get<ThreatReport>(`/reports/${id}`),
};

export const notificationsAPI = {
  getAll: () => api.get<Notification[]>('/notifications'),
  markRead: (id: string) => api.put(`/notifications/${id}/read`),
  getUnreadCount: () => api.get<{count: number}>('/notifications/unread-count'),
};

export const breachAPI = {
  getLogs: () => api.get('/breach-logs'),
  initiateScan: () => api.post('/breach-scan'),
};

export const adminAPI = {
  getReports: () => api.get<ThreatReport[]>('/admin/reports'),
  validateReport: (id: string, status: string, remarks?: string) => 
    api.put(`/admin/reports/${id}/validate`, { status, remarks }),
};

export default api;