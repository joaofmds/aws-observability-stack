#!/bin/sh
set -e

mkdir -p /etc/loki

cat > /etc/loki/local-config.yaml << 'EOF'
${loki_config}
EOF

exec /usr/bin/loki -config.file=/etc/loki/local-config.yaml
