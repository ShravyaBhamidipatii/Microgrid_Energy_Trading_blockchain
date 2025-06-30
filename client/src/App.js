import React, { useEffect, useState } from 'react';
import { LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';
import './App.css';

function App() {
  const [trades, setTrades] = useState([]);

  useEffect(() => {
    fetch('/api/trades')
      .then(res => res.json())
      .then(setTrades)
      .catch(console.error);
  }, []);

  return (
    <div className="p-4">
      <h1 className="text-2xl mb-4">Energy Trading Dashboard</h1>
      <LineChart width={600} height={300} data={trades} margin={{ top: 5, right: 20, left: 10, bottom: 5 }}>
        <XAxis dataKey="timestamp" tickFormatter={t => new Date(t).toLocaleTimeString()} />
        <YAxis />
        <Tooltip labelFormatter={t => new Date(t).toLocaleString()} />
        <CartesianGrid strokeDasharray="5 5" />
        <Line type="monotone" dataKey="amount" />
      </LineChart>
    </div>
  );
}

export default App;
