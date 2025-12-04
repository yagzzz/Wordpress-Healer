#!/bin/bash

fs_fix_permissions() {
  log_section "Dosya İzinleri"
  if ! confirm_labeled "ONERILIR" "WP dosya ve klasör izinlerini (755/644) düzeltmek istiyor musun?"; then
    log_warn "İzin düzeltme atlandı."
    return
  fi
  find "$WP_DIR" -type d -exec chmod 755 {} \; 2>/dev/null
  find "$WP_DIR" -type f -exec chmod 644 {} \; 2>/dev/null
  [ -f "$WP_DIR/wp-config.php" ] && chmod 640 "$WP_DIR/wp-config.php" 2>/dev/null
  log_ok "İzinler WordPress standartlarına getirildi."
}

fs_fix_htaccess() {
  log_section ".htaccess"
  local ht="$WP_DIR/.htaccess"

  if [ -f "$ht" ]; then
    local backup="$WP_DIR/.htaccess.yedek-$(date +%F-%H%M%S)"
    cp "$ht" "$backup"
    log_ok ".htaccess yedeklendi: $backup"
    if confirm_labeled "ONERILIR" ".htaccess dosyasını WordPress varsayılana sıfırlamak ister misin?"; then
      cat > "$ht" << 'EOF'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF
      chmod 644 "$ht"
      log_ok ".htaccess varsayılana getirildi."
    fi
  else
    log_warn ".htaccess bulunamadı."
    if confirm_labeled "OPSIYONEL" "Yeni varsayılan .htaccess oluşturulsun mu?"; then
      cat > "$ht" << 'EOF'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF
      chmod 644 "$ht"
      log_ok ".htaccess oluşturuldu."
    fi
  fi
}

fs_cache_and_flyingpress() {
  log_section "Cache & FlyingPress"

  local caches=(
    "$WP_CONTENT/cache"
    "$WP_CONTENT/litespeed"
    "$WP_CONTENT/wp-rocket-config"
  )

  for c in "${caches[@]}"; do
    if [ -d "$c" ]; then
      log_info "Bulunan cache klasörü: $c"
      if confirm_labeled "ONERILIR" "$c içeriği temizlensin mi?"; then
        rm -rf "$c"/* 2>/dev/null
        log_ok "$c temizlendi."
      fi
    fi
  done

  if [ -d "$WP_PLUGINS/flying-press" ]; then
    local fp_dir="$WP_CONTENT/flying-press"
    if [ ! -d "$fp_dir" ]; then
      if confirm_labeled "ONERILIR" "FlyingPress klasörü eksik. Oluşturulsun mu?"; then
        mkdir -p "$fp_dir"
        touch "$fp_dir/config.json"
        chmod 755 "$fp_dir"
        chmod 644 "$fp_dir/config.json"
        log_ok "FlyingPress klasörü ve config.json oluşturuldu."
      fi
    else
      if [ ! -f "$fp_dir/config.json" ]; then
        if confirm_labeled "ONERILIR" "FlyingPress config.json eksik. Oluşturulsun mu?"; then
          touch "$fp_dir/config.json"
          chmod 644 "$fp_dir/config.json"
          log_ok "FlyingPress config.json oluşturuldu."
        fi
      fi
    fi
  fi
}

fs_scan_plugins_themes() {
  log_section "Plugin / Tema Sağlık Taraması"

  for dir in "$WP_PLUGINS"/*; do
    [ -d "$dir" ] || continue
    local count_php
    count_php=$(find "$dir" -maxdepth 2 -type f -name "*.php" | wc -l)
    if [ "$count_php" -eq 0 ]; then
      log_warn "Şüpheli eklenti klasörü (hiç .php yok): $dir"
      if confirm_labeled "OPSIYONEL" "Bu klasörü .disabled yapıp devre dışı bırakmak ister misin?"; then
        mv "$dir" "${dir}.disabled"
        log_ok "$dir devre dışı bırakıldı."
      fi
    fi
  done

  for dir in "$WP_THEMES"/*; do
    [ -d "$dir" ] || continue
    local count_php
    count_php=$(find "$dir" -maxdepth 2 -type f -name "*.php" | wc -l)
    if [ "$count_php" -eq 0 ]; then
      log_warn "Şüpheli tema klasörü (hiç .php yok): $dir"
      if confirm_labeled "OPSIYONEL" "Bu tema klasörünü .disabled yapıp devre dışı bırakmak ister misin?"; then
        mv "$dir" "${dir}.disabled"
        log_ok "$dir devre dışı bırakıldı."
      fi
    fi
  done

  log_info "Bozuk symlinkler aranıyor..."
  find "$WP_CONTENT" -xtype l -print 2>/dev/null | while read -r link; do
    log_warn "Bozuk symlink: $link"
    if confirm_labeled "OPSIYONEL" "Bu symlink kaldırılsın mı?"; then
      rm "$link"
      log_ok "$link kaldırıldı."
    fi
  done
}
