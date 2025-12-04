#!/bin/bash

db_basic_tests() {
  log_section "Veritabanı Temel Testleri"

  if ! command -v mysql >/dev/null 2>&1 || [ -z "$DB_NAME" ]; then
    log_warn "MySQL CLI veya DB bilgisi yok, DB testi atlandı."
    return
  fi

  if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" >/dev/null 2>&1; then
    log_ok "Veritabanı bağlantısı başarılı."
  else
    log_err "Veritabanı bağlantısı BAŞARISIZ. wp-config ayarlarını kontrol et."
  fi
}

wp_config_tweaks() {
  log_section "wp-config Optimizasyon Önerileri"
  local conf="$WP_DIR/wp-config.php"
  [ -f "$conf" ] || return

  if ! grep -q "WP_MEMORY_LIMIT" "$conf"; then
    log_warn "WP_MEMORY_LIMIT tanımlı değil."
    if confirm_labeled "ONERILIR" "WP_MEMORY_LIMIT=256M ve WP_MAX_MEMORY_LIMIT=512M eklensin mi?"; then
      {
        echo "define('WP_MEMORY_LIMIT', '256M');"
        echo "define('WP_MAX_MEMORY_LIMIT', '512M');"
      } >> "$conf"
      log_ok "Memory limit sabitleri eklendi."
    fi
  fi

  if ! grep -q "DISABLE_WP_CRON" "$conf"; then
    log_warn "DISABLE_WP_CRON tanımlı değil."
    if confirm_labeled "OPSIYONEL" "Gerçek cron kullanmak için DISABLE_WP_CRON true yapılsın mı?"; then
      echo "define('DISABLE_WP_CRON', true);" >> "$conf"
      log_ok "DISABLE_WP_CRON eklendi. Sunucuda cron job eklemeyi unutma."
    fi
  fi
}

db_wpcli_repair() {
  log_section "wp-cli DB Kontrol / Onarım"
  if ! command -v wp >/dev/null 2>&1; then
    log_warn "wp-cli bulunamadı; DB onarım atlandı."
    return
  fi

  if confirm_labeled "ILERI" "'wp db check' çalıştırılsın mı?"; then
    wp db check --path="$WP_DIR"
  fi
  if confirm_labeled "ILERI" "'wp db repair' çalıştırılsın mı? (bozuk tabloları onarır)"; then
    wp db repair --path="$WP_DIR"
  fi
}

