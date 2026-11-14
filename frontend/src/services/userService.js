import axios from 'axios';

const API_BASE_URL = '/users';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const userService = {
  getAllUsers: () => api.get(''),
  getUserById: (id) => api.get(`/${id}`),
  createUser: (user) => api.post('', user),
  updateUser: (id, user) => api.put(`/${id}`, user),
  deleteUser: (id) => api.delete(`/${id}`),
};

export default api;

