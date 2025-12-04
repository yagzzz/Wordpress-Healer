#!/bin/bash

LOG_ROOT="$BASE_DIR/logs"
RUN_ID="$(date +%Y-%m-%d_%H-%M-%S)"
LOG_DIR="$LOG_ROOT/$RUN_ID"
STATS_FILE="$LOG_DIR/wp-healer-istatistik.json"
export LOG_DIR STATS_FILE

init_logging() {
  mkdir -p "$LOG_DIR"
  # Tüm çıktıyı hem ekrana hem log dosyasına yaz
  exec > >(tee -a "$LOG_DIR/wp-healer-output.log") 2>&1
  log_ok "Log dizini: $LOG_DIR"
}

write_stats_json() {
  local status="$1"

  local wp_version="unknown"
  local plugin_count="unknown"

  if command -v wp >/dev/null 2>&1 && [ -n "$WP_DIR" ]; then
    wp_version=$(wp core version --path="$WP_DIR" 2>/dev/null || echo "unknown")
    plugin_count=$(wp plugin list --path="$WP_DIR" 2>/dev/null | wc -l)
  fi

  cat > "$STATS_FILE" <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "mode": "$MODE_NAME",
  "status": "$status",
  "os_name": "$OS_NAME",
  "os_version": "$OS_VERSION",
  "kernel": "$KERNEL",
  "cpu_cores": $CPU_CORES,
  "ram_mb": $RAM_TOTAL_MB,
  "php_version": "$PHP_VERSION_STR",
  "mysql_version": "$MYSQL_VERSION_STR",
  "wp_version": "$wp_version",
  "plugin_count": "$plugin_count"
}
EOF

  log_ok "İstatistik dosyası oluşturuldu: $STATS_FILE"
}
