# Backend POC Logs

Backend simples em Node.js que gera muitos logs para provas de conceito de observabilidade e testes de carga.

Início rápido

1. Instale as dependências:

```bash
npm install
```

2. Execute o aplicativo:

```bash
npm start
```

3. Controle o gerador de logs:

- Inicie o gerador com `rate` logs por segundo (padrão 1000):

```bash
curl "http://localhost:3000/start?rate=2000"
```

- Pare o gerador:

```bash
curl "http://localhost:3000/stop"
```

- Consulte o status:

```bash
curl "http://localhost:3000/status"
```

- Gere uma explosão de logs (requisição única):

```bash
curl "http://localhost:3000/burst?count=50000"
```

Notas

- Por padrão os logs são enviados para stdout. Para escrevê-los em arquivo defina a variável de ambiente `PINO_LOG_FILE` antes de iniciar o app, por exemplo `PINO_LOG_FILE=logs/out.log npm start`.
- Taxas muito altas de logs podem saturar CPU e I/O; ajuste o `rate` conforme seu ambiente.
