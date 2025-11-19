#!/usr/bin/env node
const express = require('express');
const logger = require('./logger');
const os = require('os');

const app = express();
const port = process.env.PORT || 3000;

let generator = { running: false, intervalId: null, rate: 1000 };

function startGenerator(rate) {
  if (generator.running) return;
  generator.rate = rate || generator.rate;
  generator.running = true;
  const perSecond = generator.rate;
  logger.info({ msg: 'Starting log generator', rate: perSecond });
  generator.intervalId = setInterval(() => {
    for (let i = 0; i < perSecond; i++) {
      const level = i % 1000 === 0 ? 'error' : (i % 100 === 0 ? 'warn' : 'info');
      const payload = {
        ts: new Date().toISOString(),
        host: os.hostname(),
        pid: process.pid,
        idx: i,
        message: `Synthetic log message #${i}`
      };
      if (level === 'info') logger.info(payload);
      else if (level === 'warn') logger.warn(payload);
      else logger.error(payload);
    }
  }, 1000);
}

function stopGenerator() {
  if (!generator.running) return;
  clearInterval(generator.intervalId);
  generator.intervalId = null;
  generator.running = false;
  logger.info({ msg: 'Stopped log generator' });
}

app.get('/', (req, res) => res.send('POC logs backend running'));

app.get('/start', (req, res) => {
  const rate = parseInt(req.query.rate, 10) || 1000;
  if (generator.running) return res.json({ ok: false, running: true });
  startGenerator(rate);
  res.json({ ok: true, running: true, rate });
});

app.get('/stop', (req, res) => {
  stopGenerator();
  res.json({ ok: true, running: false });
});

app.get('/status', (req, res) => {
  res.json({ running: generator.running, rate: generator.rate });
});

app.get('/burst', (req, res) => {
  const count = parseInt(req.query.count, 10) || 10000;
  for (let i = 0; i < count; i++) {
    logger.info({ burst: true, idx: i, msg: `burst log ${i}` });
  }
  res.json({ ok: true, count });
});

app.listen(port, () => {
  logger.info({ msg: 'Server started', port });
});
