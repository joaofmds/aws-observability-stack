auth_enabled: false

server:
  http_listen_address: 0.0.0.0
  http_listen_port: 3100
  grpc_listen_address: 0.0.0.0
  grpc_listen_port: 9095
  log_level: info

common:
  path_prefix: /loki
  replication_factor: 1
  ring:
    instance_addr: 0.0.0.0
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: "2024-01-01"
      store: tsdb
      object_store: s3
      schema: v13
      index:
        prefix: index_
        period: 24h

storage_config:
  tsdb_shipper:
    active_index_directory: /loki/index
    cache_location: /loki/index-cache
    cache_ttl: 24h         # pode aumentar pra queries muito longas, mas usa mais disco

  aws:
    s3: s3://${region}
    bucketnames: ${s3_bucket_name}
    s3forcepathstyle: true

ruler:
  storage:
    type: local
    local:
      directory: /loki/rules
  rule_path: /loki/rules-temp
  ring:
    kvstore:
      store: inmemory
  alertmanager_url: ""

limits_config:
  retention_period: ${retention_days}d

compactor:
  working_directory: /loki/compactor
  compaction_interval: 10m

  retention_enabled: true
  retention_delete_delay: 2h
  retention_delete_worker_count: 150

  delete_request_store: s3

analytics:
  reporting_enabled: false
