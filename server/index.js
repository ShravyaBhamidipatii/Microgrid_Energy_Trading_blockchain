const express = require('express');
const Web3   = require('web3');
const fs     = require('fs');
require('dotenv').config();

const app = express();
app.use(express.json());

// Load contract ABI and connect to Ethereum node
const abi      = JSON.parse(fs.readFileSync(process.env.ABI_PATH));
const web3     = new Web3(new Web3.providers.HttpProvider(process.env.PROVIDER_URL));
const contract = new web3.eth.Contract(abi, process.env.CONTRACT_ADDRESS);

// Unlock account for transactions
const account = web3.eth.accounts.privateKeyToAccount(process.env.PRIVATE_KEY);
web3.eth.accounts.wallet.add(account);

// Stream simulated meter data every 10s
setInterval(async () => {
  const reading = { meterId: 'MG1', timestamp: Date.now(), kWh: Math.random() * 5 };
  try {
    const tx  = contract.methods.reportMeter(reading.meterId, reading.timestamp, reading.kWh);
    const gas = await tx.estimateGas({ from: account.address });
    await tx.send({ from: account.address, gas });
    console.log('Meter data reported');
  } catch (err) {
    console.error('Error streaming', err);
  }
}, 10000);

// Endpoint to fetch past trades
app.get('/api/trades', async (_req, res) => {
  try {
    const events = await contract.getPastEvents('TradeExecuted', { fromBlock: 0, toBlock: 'latest' });
    res.json(events.map(e => e.returnValues));
  } catch (err) {
    res.status(500).json({ error: err.toString() });
  }
});

// Start server
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
