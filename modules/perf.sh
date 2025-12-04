#!/bin/bash

perf_run_basic() {
  log_section "Performans Testleri"

  local url=""
  if command -v wp >/dev/null 2>&1; then
    url=$(wp option get siteurl --path="$WP_DIR" 2>/dev/null)
  fi
  if [ -z "$url" ]; then
    read -r -p "Ana sayfa URL (https://site.com): " url
  fi
  if [ -z "$url" ]; then
    log_warn "URL yok; performans testi atlandı."
    return
  fi

  log_info "TTFB testi: $url"
  curl -s -o /dev/null -w "HTTP: %{http_code}, TTFB: %{time_starttransfer}s, Toplam: %{time_total}s\n" "$url"
}

perf_phpfpm_suggest() {
  log_section "PHP-FPM Önerileri"

  if [ "$RAM_TOTAL_MB" -le 0 ] || [ "$CPU_CORES" -le 0 ]; then
    log_warn "RAM/CPU bilgisi alınamadı; tahmini FPM önerisi sınırlı."
    return
  fi

  local suggested_children=$((RAM_TOTAL_MB / 256))
  if [ "$suggested_children" -lt 4 ]; then
    suggested_children=4
  fi

  echo "Örnek PHP-FPM ayar önerisi (yaklaşık):"
  echo "  pm = dynamic"
  echo "  pm.max_children = $suggested_children"
  echo "  pm.start_servers = 3"
  echo "  pm.min_spare_servers = 2"
  echo "  pm.max_spare_servers = 5"
  echo
  echo "Gerçek değerler sitenin trafiğine ve PHP-FPM havuz sayısına göre değişir."
}
