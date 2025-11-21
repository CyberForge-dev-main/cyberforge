import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_URL,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const authAPI = {
  register: (username, email, password) =>
    api.post('/register', { username, email, password }),
  login: (username, password) =>
    api.post('/login', { username, password }),
};

export const challengeAPI = {
  getChallenges: () => api.get('/challenges'),
  submitFlag: (challenge_id, flag) =>
    api.post('/submit_flag', { challenge_id, flag }),
  getProgress: () => api.get('/user/progress'),
};

export const leaderboardAPI = {
  getLeaderboard: () => api.get('/leaderboard'),
};

export default api;
