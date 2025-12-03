import React, { useState, useEffect } from 'react';
import { challengeAPI } from '../api';

function Dashboard({ user, onLogout }) {
  const [challenges, setChallenges] = useState([]);
  const [progress, setProgress] = useState(null);
  const [loading, setLoading] = useState(true);
  const [submitFlag, setSubmitFlag] = useState('');
  const [selectedChallenge, setSelectedChallenge] = useState(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const [challengesRes, progressRes] = await Promise.all([
        challengeAPI.getChallenges(),
        challengeAPI.getProgress(),
      ]);
      setChallenges(challengesRes.data);
      setProgress(progressRes.data);
    } catch (err) {
      console.error('Error loading data:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmitFlag = async (e) => {
    e.preventDefault();
    if (!selectedChallenge) return;

    try {
      const response = await challengeAPI.submitFlag(selectedChallenge, submitFlag);
      alert(response.data.message);
      setSubmitFlag('');
      loadData();
    } catch (err) {
      alert(err.response?.data?.message || 'Error submitting flag');
    }
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div style={{ padding: '20px' }}>
      <h1>Welcome, {user?.username}!</h1>
      <button onClick={onLogout}>Logout</button>

      {progress && (
        <div style={{ marginTop: '20px', padding: '10px', backgroundColor: '#f0f0f0' }}>
          <h3>Your Progress</h3>
          <p>Challenges Solved: {progress.challenges_solved}</p>
          <p>Total Points: {progress.total_points}</p>
        </div>
      )}

      <h2>Challenges</h2>
      <div>
        {challenges.map((challenge) => (
          <div key={challenge.id} style={{ padding: '10px', margin: '10px 0', border: '1px solid #ccc' }}>
            <h3>{challenge.name}</h3>
            <p>{challenge.description}</p>
            <p>Points: {challenge.points} | Port: {challenge.port}</p>
            <button onClick={() => setSelectedChallenge(challenge.id)}>
              Select
            </button>
          </div>
        ))}
      </div>

      {selectedChallenge && (
        <form onSubmit={handleSubmitFlag} style={{ marginTop: '20px' }}>
          <h3>Submit Flag</h3>
          <input
            type="text"
            placeholder="Enter flag..."
            value={submitFlag}
            onChange={(e) => setSubmitFlag(e.target.value)}
            required
          />
          <button type="submit">Submit</button>
        </form>
      )}
    </div>
  );
}

export default Dashboard;
