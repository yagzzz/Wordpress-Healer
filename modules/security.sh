#!/bin/bash

security_scan_light() {
  log_section "Hafif Güvenlik Taraması"
  local target="$WP_DIR"
  log_info "Şüpheli fonksiyonlar aranıyor (base64_decode, shell_exec, system, gzinflate)..."
  grep -R --line-number --include="*.php" -E "base64_decode\(|shell_exec\(|system\(|gzinflate\(" "$target" 2>/dev/null | head -n 50 \
    && log_warn "Yukarıdaki satırlar POTANSİYEL şüpheli kodlar olabilir. Elle kontrol et." \
    || log_ok "Belirgin şüpheli pattern bulunamadı."
}

logs_analysis_ai_like() {
  log_section "Log Analizi (error_log / debug.log)"

  local candidates=(
    "$WP_DIR/error_log"
    "$WP_DIR/debug.log"
    "$WP_CONTENT/debug.log"
  )

  for f in "${candidates[@]}"; do
    if [ -f "$f" ]; then
      log_info "Log dosyası: $f"
      echo "- Son 20 satır:"
      tail -n 20 "$f"
      echo
      echo "- Önemli hata pattern'leri:"
      grep -Ei "fatal|error|warning|deprecated|out of memory|allowed memory size|maximum execution time" "$f" 2>/dev/null | tail -n 20
      echo
    fi
  done
}
