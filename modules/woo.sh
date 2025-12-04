#!/bin/bash

woo_basic_checks() {
  log_section "WooCommerce Temel Kontroller"
  if [ ! -d "$WP_PLUGINS/woocommerce" ]; then
    log_info "WooCommerce yüklü değil."
    return
  fi

  if ! command -v mysql >/dev/null 2>&1 || [ -z "$DB_NAME" ]; then
    log_warn "DB komutları kullanılamıyor; Woo tabloları atlandı."
    return
  fi

  local table="${DB_PREFIX}wc_sessions"
  local exists
  exists=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -N -e "SHOW TABLES LIKE '$table';" 2>/dev/null)
  if [ -n "$exists" ]; then
    log_ok "$table tablosu mevcut."
  else
    log_err "$table tablosu eksik. Sepet fonksiyonu bozulabilir."
  fi
}

woo_advanced_checks() {
  log_section "WooCommerce Gelişmiş Tablo Kontrolleri"
  if [ ! -d "$WP_PLUGINS/woocommerce" ]; then
    return
  fi
  if ! command -v mysql >/dev/null 2>&1 || [ -z "$DB_NAME" ]; then
    log_warn "DB komutları kullanılamıyor; gelişmiş Woo kontrolü atlandı."
    return
  fi

  local tables=(
    "${DB_PREFIX}wc_order_stats"
    "${DB_PREFIX}wc_customer_lookup"
    "${DB_PREFIX}wc_admin_notes"
  )
  for t in "${tables[@]}"; do
    local exists
    exists=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -N -e "SHOW TABLES LIKE '$t';" 2>/dev/null)
    if [ -n "$exists" ]; then
      log_ok "$t tablosu mevcut."
    else
      log_warn "$t tablosu eksik. Rapor/istatistik özellikleri bozulmuş olabilir."
    fi
  done
}

woo_cron_analysis() {
  log_section "WooCommerce Cron Analizi"
  if ! command -v wp >/dev/null 2>&1; then
    log_warn "wp-cli yok; cron analizi sınırlı."
    return
  fi

  log_info "WooCommerce ile ilgili cron event'leri listeleniyor (ilk 10):"
  wp cron event list --path="$WP_DIR" 2>/dev/null | grep -Ei "woo|wc_" | head -n 10 || echo "İlgili cron bulunamadı."

  log_info "Cron ile ilgili sorun yaşarsan: 'wp cron event run --due-now' komutlarıyla test edebilirsin."
}

