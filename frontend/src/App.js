import React, { useState, useEffect } from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';
import './App.css';
import UserList from './components/UserList';
import UserForm from './components/UserForm';
import { userService } from './services/userService';

function App() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [editingUser, setEditingUser] = useState(null);
  const [showForm, setShowForm] = useState(false);

  // Fetch all users
  const fetchUsers = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await userService.getAllUsers();
      setUsers(response.data);
    } catch (err) {
      setError('Failed to load users: ' + (err.response?.data?.message || err.message));
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  // Load users on mount
  useEffect(() => {
    fetchUsers();
  }, []);

  // Handle create user
  const handleCreateUser = async (userData) => {
    try {
      await userService.createUser(userData);
      setShowForm(false);
      await fetchUsers();
    } catch (err) {
      setError('Failed to create user: ' + (err.response?.data?.message || err.message));
    }
  };

  // Handle update user
  const handleUpdateUser = async (userData) => {
    if (!editingUser) return;
    try {
      await userService.updateUser(editingUser.id, userData);
      setEditingUser(null);
      setShowForm(false);
      await fetchUsers();
    } catch (err) {
      setError('Failed to update user: ' + (err.response?.data?.message || err.message));
    }
  };

  // Handle delete user
  const handleDeleteUser = async (id) => {
    if (!window.confirm('Are you sure you want to delete this user?')) return;
    try {
      await userService.deleteUser(id);
      await fetchUsers();
    } catch (err) {
      setError('Failed to delete user: ' + (err.response?.data?.message || err.message));
    }
  };

  // Handle edit click
  const handleEditClick = (user) => {
    setEditingUser(user);
    setShowForm(true);
  };

  // Handle cancel/close form
  const handleCloseForm = () => {
    setEditingUser(null);
    setShowForm(false);
  };

  return (
    <div className="app-container">
      <nav className="navbar navbar-dark bg-primary mb-4">
        <div className="container-fluid">
          <span className="navbar-brand mb-0 h1">🐳 MVC Docker Demo</span>
          <span className="navbar-text text-light">User Management System</span>
        </div>
      </nav>

      <div className="container mt-4">
        {/* Error Alert */}
        {error && (
          <div className="alert alert-danger alert-dismissible fade show" role="alert">
            {error}
            <button
              type="button"
              className="btn-close"
              onClick={() => setError(null)}
            ></button>
          </div>
        )}

        {/* Header with Add Button */}
        <div className="row mb-4">
          <div className="col-md-6">
            <h2>Users</h2>
          </div>
          <div className="col-md-6 text-end">
            {!showForm && (
              <button
                className="btn btn-success"
                onClick={() => {
                  setEditingUser(null);
                  setShowForm(true);
                }}
              >
                ➕ Add New User
              </button>
            )}
          </div>
        </div>

        {/* Form Section */}
        {showForm && (
          <div className="card mb-4 bg-light">
            <div className="card-body">
              <h4 className="card-title">{editingUser ? 'Edit User' : 'Create New User'}</h4>
              <UserForm
                user={editingUser}
                onSubmit={editingUser ? handleUpdateUser : handleCreateUser}
                onCancel={handleCloseForm}
              />
            </div>
          </div>
        )}

        {/* Users List */}
        {loading ? (
          <div className="text-center">
            <div className="spinner-border" role="status">
              <span className="visually-hidden">Loading...</span>
            </div>
          </div>
        ) : users.length === 0 ? (
          <div className="alert alert-info">
            No users found. {!showForm && <a href="#create" onClick={() => setShowForm(true)}>Create one now!</a>}
          </div>
        ) : (
          <UserList
            users={users}
            onEdit={handleEditClick}
            onDelete={handleDeleteUser}
          />
        )}
      </div>

      <footer className="bg-light text-center py-3 mt-5">
        <small className="text-muted">
          Full-stack application: React Frontend + Spring Boot API + MySQL Database (All in Docker)
        </small>
      </footer>
    </div>
  );
}

export default App;

