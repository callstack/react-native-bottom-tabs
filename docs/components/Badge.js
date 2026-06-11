import React from 'react';

const Badge = ({ text, type }) => {
  const className = `badge-${type}`;

  return (
    <span className={className}>
      {text}
    </span>
  );
};

export default Badge;