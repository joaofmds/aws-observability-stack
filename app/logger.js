const pino = require('pino');

const destination = process.env.PINO_LOG_FILE ? pino.destination(process.env.PINO_LOG_FILE) : undefined;
const logger = destination ? pino({}, destination) : pino();

module.exports = logger;
