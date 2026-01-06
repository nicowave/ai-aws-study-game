import React from 'react';
import { currentLevelProgress } from '../data/constants';
import './MenuScreen.css';

const MenuScreen = ({ 
  globalStats, 
  onStartGame, 
  onViewStats, 
  soundEnabled, 
  onToggleSound 
}) => {
  const levelXp = currentLevelProgress(globalStats.xp);
  
  return (
    <div className="menu-screen">
      <div className="game-header">
        <div className="aws-badge">AWS</div>
        <h1 className="game-title">AI Practitioner</h1>
        <p className="game-subtitle">Certification Study Game</p>
      </div>

      <div className="level-display">
        <div className="level-badge">Level {globalStats.level}</div>
        <div className="xp-bar-container">
          <div
            className="xp-bar-fill"
            style={{ width: `${levelXp}%` }}
          />
        </div>
        <div className="xp-text">{levelXp} / 100 XP</div>
      </div>

      <div className="menu-buttons">
        <button className="menu-button primary" onClick={onStartGame}>
          <span className="button-icon">🎮</span>
          Start Studying
        </button>
        <button className="menu-button secondary" onClick={onViewStats}>
          <span className="button-icon">📊</span>
          View Progress
        </button>
        <button className="menu-button tertiary" onClick={onToggleSound}>
          <span className="button-icon">{soundEnabled ? '🔊' : '🔇'}</span>
          Sound: {soundEnabled ? 'On' : 'Off'}
        </button>
      </div>

      <div className="quick-stats">
        <div className="quick-stat">
          <span className="stat-value">{globalStats.totalAnswered}</span>
          <span className="stat-label">Questions</span>
        </div>
        <div className="quick-stat">
          <span className="stat-value">
            {globalStats.totalAnswered > 0
              ? Math.round((globalStats.totalCorrect / globalStats.totalAnswered) * 100)
              : 0}%
          </span>
          <span className="stat-label">Accuracy</span>
        </div>
        <div className="quick-stat">
          <span className="stat-value">{globalStats.maxStreak}</span>
          <span className="stat-label">Best Streak</span>
        </div>
      </div>
    </div>
  );
};

export default MenuScreen;
