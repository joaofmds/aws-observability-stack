# POC Logs Backend

Simple Node.js backend that generates many logs for observability/load testing proof-of-concept.

Quick start

1. Install dependencies:

```bash
npm install
```

2. Run the app:

```bash
npm start
```

3. Control the log generator:

- Start generator with `rate` logs per second (default 1000):

```bash
curl "http://localhost:3000/start?rate=2000"
```

- Stop generator:

```bash
curl "http://localhost:3000/stop"
```

- Status:

```bash
curl "http://localhost:3000/status"
```

- Generate a burst of logs (single request):

```bash
curl "http://localhost:3000/burst?count=50000"
```

Notes

- By default logs are output to stdout. To write logs to a file set `PINO_LOG_FILE` environment variable before starting the app, e.g. `PINO_LOG_FILE=logs/out.log npm start`.
- High log rates can saturate CPU and I/O; tune `rate` according to your environment.
