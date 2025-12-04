#!/bin/bash

wpcli_core_plugin_checks() {
  log_section "wp-cli Core / Plugin / Theme Kontrolleri"
  if ! command -v wp >/dev/null 2>&1; then
    log_warn "wp-cli yok; bu adım atlandı."
    return
  fi

  if confirm_labeled "ILERI" "'wp core verify-checksums' çalıştırılsın mı?"; then
    wp core verify-checksums --path="$WP_DIR"
  fi

  if confirm_labeled "ILERI" "'wp plugin verify-checksums --all' çalıştırılsın mı?"; then
    wp plugin verify-checksums --all --path="$WP_DIR" || log_warn "Bazı eklentiler checksum desteklemiyor olabilir."
  fi

  if confirm_labeled "RISKLI" "Tüm eklentiler 'wp plugin update --all' ile GÜNCELLENSİN mi?"; then
    wp plugin update --all --path="$WP_DIR"
  fi

  if confirm_labeled "RISKLI" "Tüm temalar 'wp theme update --all' ile GÜNCELLENSİN mi?"; then
    wp theme update --all --path="$WP_DIR"
  fi
}

wpcli_core_restore_suggest() {
  log_section "WordPress Çekirdek Dosya Onarım Önerisi"
  if ! command -v wp >/dev/null 2>&1; then
    return
  fi

  log_info "Eğer çekirdek dosyalarda bozulma varsa:"
  echo "  wp core verify-checksums"
  echo "  wp core download --force"
  log_info "Bu komutlar bozuk çekirdek dosyaları düzeltebilir."

  if confirm_labeled "RISKLI" "ÇEKİRDEK dosyaları 'wp core download --force' ile yenilensin mi? (wp-content ve wp-config'e dokunmaz)"; then
    wp core download --force --path="$WP_DIR"
    log_ok "WordPress çekirdeği yeniden indirildi."
  fi
}
