import React from 'react';
import './ResultsScreen.css';

const ResultsScreen = ({
  domain,
  sessionStats,
  totalQuestions,
  onRetry,
  onSelectDomain,
  onMainMenu
}) => {
  const percentage = Math.round((sessionStats.correct / totalQuestions) * 100);

  const getResultEmoji = () => {
    if (percentage === 100) return '🏆';
    if (percentage >= 80) return '⭐';
    if (percentage >= 60) return '👍';
    return '📚';
  };

  const getResultMessage = () => {
    if (percentage === 100) return 'Perfect Score!';
    if (percentage >= 80) return 'Great Job!';
    if (percentage >= 60) return 'Good Effort!';
    return 'Keep Practicing!';
  };

  return (
    <div className="results-screen" style={{ '--domain-color': domain?.color }}>
      <div className="results-card">
        <div className="results-icon">{getResultEmoji()}</div>
        <h2 className="results-title">{getResultMessage()}</h2>

        <div className="results-score">
          <span className="score-num">{sessionStats.correct}</span>
          <span className="score-divider">/</span>
          <span className="score-total">{totalQuestions}</span>
        </div>

        <div className="results-percentage">{percentage}% Correct</div>

        <div className="results-stats">
          <div className="result-stat">
            <span className="stat-icon">⏱️</span>
            <span className="stat-info">
              {Math.round((Date.now() - sessionStats.startTime) / 1000)}s
            </span>
          </div>
          <div className="result-stat">
            <span className="stat-icon">🔥</span>
            <span className="stat-info">Best Streak: {sessionStats.streak}</span>
          </div>
        </div>

        <div className="results-actions">
          <button
            className="result-button primary"
            onClick={onRetry}
            style={{ background: domain?.gradient }}
          >
            🔄 Try Again
          </button>
          <button className="result-button secondary" onClick={onSelectDomain}>
            📚 Other Domains
          </button>
          <button className="result-button tertiary" onClick={onMainMenu}>
            🏠 Main Menu
          </button>
        </div>
      </div>
    </div>
  );
};

export default ResultsScreen;
