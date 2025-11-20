# Multi-stage build para Node.js
# Stage 1: Build dependencies
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar arquivos de dependências
COPY app/package.json app/package-lock.json* ./

# Instalar dependências de produção
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Runtime image
FROM node:20-alpine

# Criar usuário não-root para segurança
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copiar node_modules do stage anterior
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copiar código da aplicação
COPY --chown=nodejs:nodejs app/*.js ./

# Mudar para usuário não-root
USER nodejs

# Expor porta da aplicação
EXPOSE 3000

# Healthcheck opcional
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Comando para iniciar a aplicação
CMD ["node", "app.js"]

