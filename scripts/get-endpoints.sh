#!/bin/bash
# Script para obter todos os endpoints da aplicação

cd "$(dirname "$0")/../infra/envs/dev" || exit 1

echo "========================================="
echo "Endpoints da Aplicação"
echo "========================================="
echo ""

echo "📍 Aplicação Principal (ALB):"
ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null)
if [ -n "$ALB_DNS" ]; then
  echo "   HTTP: http://${ALB_DNS}"
  echo "   Teste: curl http://${ALB_DNS}/"
else
  echo "   ⚠️  ALB não criado ou não disponível"
fi
echo ""

echo "📊 Grafana Workspace:"
GRAFANA_URL=$(terraform output -raw grafana_workspace_url 2>/dev/null)
if [ -n "$GRAFANA_URL" ]; then
  echo "   URL: ${GRAFANA_URL}"
  echo "   Acesso: Abra no navegador e faça login via AWS SSO"
else
  echo "   ⚠️  Grafana não criado ou não disponível"
fi
echo ""

echo "📝 Loki (Logs):"
LOKI_ENDPOINT=$(terraform output -raw loki_endpoint_http 2>/dev/null)
LOKI_DNS=$(terraform output -raw loki_nlb_dns_name 2>/dev/null)
if [ -n "$LOKI_ENDPOINT" ]; then
  echo "   Endpoint: ${LOKI_ENDPOINT}"
  echo "   DNS: ${LOKI_DNS}"
  echo "   Porta: 3100"
  echo "   Health Check: curl ${LOKI_ENDPOINT}/ready"
  echo "   Query API: curl ${LOKI_ENDPOINT}/loki/api/v1/query?query={job=\"your-job\"}"
else
  echo "   ⚠️  Loki não criado ou não disponível (habilitar com enable_loki=true)"
fi
echo ""

echo "📈 Prometheus (Métricas):"
PROM_QUERY=$(terraform output -raw prometheus_query_endpoint 2>/dev/null)
PROM_REMOTE=$(terraform output -raw prometheus_remote_write_endpoint 2>/dev/null)
if [ -n "$PROM_QUERY" ]; then
  echo "   Query Endpoint: ${PROM_QUERY}"
  echo "   Remote Write: ${PROM_REMOTE}"
  echo "   Nota: Usado como data source no Grafana"
else
  echo "   ⚠️  Prometheus não criado ou não disponível"
fi
echo ""

echo "🏗️  ECS:"
ECS_CLUSTER=$(terraform output -raw ecs_cluster_name 2>/dev/null)
ECS_SERVICE=$(terraform output -raw ecs_service_name 2>/dev/null)
if [ -n "$ECS_CLUSTER" ]; then
  echo "   Cluster: ${ECS_CLUSTER}"
  echo "   Service: ${ECS_SERVICE}"
  echo "   Ver logs: aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${ECS_SERVICE}"
else
  echo "   ⚠️  ECS não criado ou não disponível"
fi
echo ""

echo "========================================="
echo "Comandos Úteis"
echo "========================================="
echo ""
echo "🔍 Ver status do serviço ECS:"
echo "   aws ecs describe-services --cluster \$(terraform output -raw ecs_cluster_name) --services \$(terraform output -raw ecs_service_name)"
echo ""
echo "📋 Ver logs do Loki:"
echo "   aws logs tail \$(terraform output -raw loki_cloudwatch_log_group_name) --follow"
echo ""
echo "📊 Ver health check do Loki:"
echo "   curl http://\$(terraform output -raw loki_nlb_dns_name):3100/ready"
echo ""

