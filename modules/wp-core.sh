#!/bin/bash

wp_detect_and_load() {
  log_section "WordPress Dizini ve Veritabanı Bilgileri"

  if [ -f "./wp-config.php" ]; then
    WP_DIR="$(pwd)"
  else
    mapfile -t candidates < <(find /home -maxdepth 6 -type f -name "wp-config.php" 2>/dev/null)
    if [ "${#candidates[@]}" -eq 1 ]; then
      WP_DIR="$(dirname "${candidates[0]}")"
    elif [ "${#candidates[@]}" -gt 1 ]; then
      log_warn "Birden fazla wp-config.php bulundu:"
      local i=1
      for c in "${candidates[@]}"; do
        echo "  [$i] $c"
        i=$((i+1))
      done
      read -r -p "Kullanmak istediğin kurulumu seç (sayı): " n
      if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#candidates[@]}" ]; then
        WP_DIR="$(dirname "${candidates[$((n-1))]}")"
      fi
    else
      read -r -p "WordPress dizinini elle gir (/home/.../public_html): " WP_DIR
    fi
  fi

  if [ ! -f "$WP_DIR/wp-config.php" ]; then
    log_err "$WP_DIR içinde wp-config.php bulunamadı. Çıkılıyor."
    exit 1
  fi

  WP_CONTENT="$WP_DIR/wp-content"
  WP_PLUGINS="$WP_CONTENT/plugins"
  WP_THEMES="$WP_CONTENT/themes"

  export WP_DIR WP_CONTENT WP_PLUGINS WP_THEMES

  log_ok "WordPress dizini: $WP_DIR"

  if command -v php >/dev/null 2>&1; then
    DB_NAME=$(php -r "include '$WP_DIR/wp-config.php'; echo DB_NAME;" 2>/dev/null)
    DB_USER=$(php -r "include '$WP_DIR/wp-config.php'; echo DB_USER;" 2>/dev/null)
    DB_PASS=$(php -r "include '$WP_DIR/wp-config.php'; echo DB_PASSWORD;" 2>/dev/null)
    DB_HOST=$(php -r "include '$WP_DIR/wp-config.php'; echo DB_HOST;" 2>/dev/null)
    DB_PREFIX=$(php -r "include '$WP_DIR/wp-config.php'; global \$table_prefix; echo \$table_prefix;" 2>/dev/null)

    export DB_NAME DB_USER DB_PASS DB_HOST DB_PREFIX

    echo "- DB Adı:   ${DB_NAME:-bilinmiyor}"
    echo "- DB Host:  ${DB_HOST:-localhost}"
    echo "- Prefix:   ${DB_PREFIX:-wp_}"
  else
    log_warn "PHP CLI yok, DB bilgileri otomatik okunamadı."
  fi
}
