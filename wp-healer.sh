#!/bin/bash
#
# ============================================================
#   WP-HEALER ULTRA (Türkçe Sürüm)
#   WordPress Otomatik Onarım, Teşhis ve Optimizasyon Aracı
#   Modlar: Başlangıç • Standart • Gelişmiş • PRO • ULTRA • Özel
# ============================================================

# -------- RENKLER / GENEL --------

C_RESET="\e[0m"
C_BOLD="\e[1m"
C_RED="\e[31m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_BLUE="\e[34m"
C_MAGENTA="\e[35m"
C_CYAN="\e[36m"

confirm() {
  local q="$1"
  echo
  read -r -p "$(echo -e "${C_YELLOW}${q} (E/h): ${C_RESET}")" ans
  case "$ans" in
    e|E|evet|EVET|Evet) return 0 ;;
    *) return 1 ;;
  esac
}

pause() {
  echo
  read -r -p "$(echo -e \"${C_YELLOW}Devam etmek için Enter'a basın...${C_RESET}\")" _
}

log_info() {
  echo -e "${C_CYAN}[i]${C_RESET} $1"
}

log_ok() {
  echo -e "${C_GREEN}[✓]${C_RESET} $1"
}

log_warn() {
  echo -e "${C_YELLOW}[!]${C_RESET} $1"
}

log_err() {
  echo -e "${C_RED}[X]${C_RESET} $1"
}

# -------- GLOBAL DEĞİŞKENLER --------

WP_DIR=""
WP_CONTENT=""
WP_PLUGINS=""
WP_THEMES=""

DB_NAME=""
DB_USER=""
DB_PASS=""
DB_HOST=""
DB_PREFIX=""

OS_NAME=""
OS_VERSION=""
KERNEL=""
CPU_CORES=0
RAM_TOTAL_MB=0
PHP_VERSION_STR=""
MYSQL_VERSION_STR=""
DISK_USAGE=""
MODE_NAME=""

STATS_FILE="wp-healer-istatistikler.jsonl"
ISTATISTIK_ENDPOINT="${ISTATISTIK_ENDPOINT:-}"  # İsteğe bağlı uzaktan log

HAS_WPCLI=0
HAS_MYSQL=0
HAS_PHP=0

# -------- BANNER --------

banner() {
  clear
  echo -e "${C_BOLD}${C_MAGENTA}"
  echo "======================================================"
  echo "              WP-HEALER ULTRA  (Türkçe)"
  echo "======================================================"
  echo -e "${C_RESET}"
  echo -e "${C_RED}${C_BOLD}UYARI:${C_RESET} Devam etmeden önce mutlaka DOSYA + VERİTABANI YEDEĞİ almanız tavsiye edilir."
  echo
}

# -------- SISTEM BILGI --------

get_system_info() {
  log_info "Sistem bilgileri toplanıyor..."

  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_NAME="$NAME"
    OS_VERSION="$VERSION"
  else
    OS_NAME="$(uname -s)"
    OS_VERSION="$(uname -r)"
  fi

  KERNEL="$(uname -r 2>/dev/null || echo "")"
  CPU_CORES=$(nproc 2>/dev/null || echo 0)

  # RAM
  if command -v free >/dev/null 2>&1; then
    RAM_TOTAL_MB=$(free -m | awk '/Mem:/ {print $2}')
  fi

  # Disk (varsayılan /)
  DISK_USAGE="$(df -h / | awk 'NR==2 {print $5" ("$3"/"$2")"}')"

  # PHP
  if command -v php >/dev/null 2>&1; then
    HAS_PHP=1
    PHP_VERSION_STR="$(php -r 'echo PHP_VERSION;' 2>/dev/null)"
  fi

  # MySQL / MariaDB
  if command -v mysql >/dev/null 2>&1; then
    HAS_MYSQL=1
    MYSQL_VERSION_STR="$(mysql -V 2>/dev/null)"
  fi

  # WP-CLI
  if command -v wp >/dev/null 2>&1; then
    HAS_WPCLI=1
  fi

  echo
  echo -e "${C_BOLD}Sistem Özeti:${C_RESET}"
  echo "- OS:           ${OS_NAME} ${OS_VERSION}"
  echo "- Kernel:       ${KERNEL}"
  echo "- RAM Toplam:   ${RAM_TOTAL_MB} MB"
  echo "- CPU Çekirdek: ${CPU_CORES}"
  echo "- Disk Kullanım: ${DISK_USAGE}"
  [ $HAS_PHP -eq 1 ] && echo "- PHP:          ${PHP_VERSION_STR}" || echo "- PHP:          bulunamadı"
  [ $HAS_MYSQL -eq 1 ] && echo "- MySQL/MariaDB: ${MYSQL_VERSION_STR}" || echo "- MySQL/MariaDB: bulunamadı"
  echo
}

system_suggestions() {
  echo -e "${C_BOLD}Sistem Bazlı Öneriler:${C_RESET}"

  # RAM
  if [ "$RAM_TOTAL_MB" -gt 0 ] && [ "$RAM_TOTAL_MB" -lt 4000 ]; then
    echo -e "- ${C_YELLOW}RAM düşük görünüyor (${RAM_TOTAL_MB} MB). WooCommerce için en az 4 GB önerilir.${C_RESET}"
  else
    echo "- RAM miktarı WooCommerce için genel olarak yeterli görünüyor."
  fi

  # CPU
  if [ "$CPU_CORES" -gt 0 ] && [ "$CPU_CORES" -lt 2 ]; then
    echo -e "- ${C_YELLOW}CPU çekirdek sayısı çok düşük (${CPU_CORES}). Trafik artışında gecikmeler yaşanabilir.${C_RESET}"
  elif [ "$CPU_CORES" -ge 2 ] && [ "$CPU_CORES" -lt 4 ]; then
    echo "- CPU çekirdek sayısı orta seviyede (${CPU_CORES}). Orta ölçekli siteler için idare eder."
  else
    echo "- CPU çekirdek sayısı iyi (${CPU_CORES})."
  fi

  # PHP
  if [ -n "$PHP_VERSION_STR" ]; then
    major=$(echo "$PHP_VERSION_STR" | cut -d. -f1)
    minor=$(echo "$PHP_VERSION_STR" | cut -d. -f2)
    if [ "$major" -lt 8 ] || { [ "$major" -eq 8 ] && [ "$minor" -lt 1 ]; }; then
      echo -e "- ${C_YELLOW}PHP sürümünüz (${PHP_VERSION_STR}) eski olabilir. Güvenlik ve performans için PHP 8.1+ tavsiye edilir.${C_RESET}"
    else
      echo "- PHP sürümünüz (${PHP_VERSION_STR}) güncel ve uygun görünüyor."
    fi
  fi

  echo
}

# -------- WORDPRESS BULMA & DB BILGI --------

detect_wp_dir() {
  log_info "WordPress dizini aranıyor..."

  if [ -f "./wp-config.php" ]; then
    WP_DIR="$(pwd)"
  else
    # /home altında tarama
    mapfile -t candidates < <(find /home -maxdepth 6 -type f -name "wp-config.php" 2>/dev/null)
    if [ "${#candidates[@]}" -eq 1 ]; then
      WP_DIR="$(dirname "${candidates[0]}")"
    elif [ "${#candidates[@]}" -gt 1 ]; then
      echo -e "${C_YELLOW}Birden fazla WordPress kurulumu bulundu:${C_RESET}"
      local i=1
      for c in "${candidates[@]}"; do
        echo "  [$i] $c"
        i=$((i+1))
      done
      echo
      read -r -p "Hangi kurulumu kullanmak istiyorsunuz? (sayı): " choice
      if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#candidates[@]}" ]; then
        WP_DIR="$(dirname "${candidates[$((choice-1))]}")"
      fi
    else
      read -r -p "wp-config.php dosyasının olduğu WordPress dizinini elle girin (/home/.../public_html): " WP_DIR
    fi
  fi

  if [ ! -f "$WP_DIR/wp-config.php" ]; then
    log_err "$WP_DIR içinde wp-config.php bulunamadı. Betik durduruluyor."
    exit 1
  fi

  WP_CONTENT="$WP_DIR/wp-content"
  WP_PLUGINS="$WP_CONTENT/plugins"
  WP_THEMES="$WP_CONTENT/themes"

  echo
  echo -e "${C_BOLD}WordPress Dizini:${C_RESET} $WP_DIR"
  echo "- wp-content: $WP_CONTENT"
  echo "- plugins:    $WP_PLUGINS"
  echo "- themes:     $WP_THEMES"
  echo
}

load_db_creds() {
  if [ $HAS_PHP -ne 1 ]; then
    log_warn "PHP CLI bulunamadı, veritabanı bilgileri wp-config içinden otomatik okunamayabilir."
    return
  fi

  log_info "Veritabanı bilgileri wp-config.php'den okunuyor..."
  DB_NAME=$(php -r "include '$WP_DIR/wp-config.php'; echo DB_NAME;" 2>/dev/null)
  DB_USER=$(php -r "include '$WP_DIR/wp-config.php'; echo DB_USER;" 2>/dev/null)
  DB_PASS=$(php -r "include '$WP_DIR/wp-config.php'; echo DB_PASSWORD;" 2>/dev/null)
  DB_HOST=$(php -r "include '$WP_DIR/wp-config.php'; echo DB_HOST;" 2>/dev/null)
  DB_PREFIX=$(php -r "include '$WP_DIR/wp-config.php'; global \$table_prefix; echo \$table_prefix;" 2>/dev/null)

  echo -e "${C_GREEN}DB Adı: ${DB_NAME:-bilinmiyor}${C_RESET}"
  echo -e "${C_GREEN}DB Host: ${DB_HOST:-localhost}${C_RESET}"
  echo -e "${C_GREEN}Tablo Öneki (prefix): ${DB_PREFIX:-wp_}${C_RESET}"
  echo
}

# -------- ISTATISTIK LOG --------

write_local_stats() {
  # WP sürümü, aktif eklenti sayısı varsa çek
  local wp_version="unknown"
  local plugin_count="unknown"
  if [ $HAS_WPCLI -eq 1 ]; then
    wp_version=$(wp core version --path="$WP_DIR" 2>/dev/null || echo "unknown")
    plugin_count=$(wp plugin list --path="$WP_DIR" 2>/dev/null | wc -l)
  fi

  local status="$1"

  local now
  now=$(date -Iseconds)

  local json
  json=$(cat <<EOF
{
  "timestamp": "$now",
  "mode": "$MODE_NAME",
  "os_name": "$OS_NAME",
  "os_version": "$OS_VERSION",
  "kernel": "$KERNEL",
  "cpu_cores": $CPU_CORES,
  "ram_mb": $RAM_TOTAL_MB,
  "php_version": "$PHP_VERSION_STR",
  "mysql_version": "$MYSQL_VERSION_STR",
  "wp_version": "$wp_version",
  "plugin_count": "$plugin_count",
  "status": "$status"
}
EOF
)

  echo "$json" >> "$STATS_FILE"
  log_ok "İstatistik kaydı $STATS_FILE dosyasına yazıldı."

  # İsteğe bağlı uzak endpoint
  if [ -n "$ISTATISTIK_ENDPOINT" ]; then
    curl -s -X POST -H "Content-Type: application/json" -d "$json" "$ISTATISTIK_ENDPOINT" >/dev/null 2>&1 \
      && log_ok "İstatistikler uzaktaki ISTATISTIK_ENDPOINT adresine POST edildi." \
      || log_warn "ISTATISTIK_ENDPOINT'e POST başarısız olmuş olabilir."
  fi
}

# -------- MODÜLLER --------
# Aşağıda her biri belirli iş yapan modüller var. Modlara göre kombine edilecek.

# -- Temel: izin, htaccess, cache, plugin/theme basic --

fix_permissions() {
  log_info "Dosya ve klasör izinleri kontrol ediliyor..."
  if ! confirm "WordPress dizinindeki izinleri (755 klasör, 644 dosya) olarak düzeltmek istiyor musunuz?"; then
    log_warn "İzin düzeltme atlandı."
    return
  fi

  find "$WP_DIR" -type d -exec chmod 755 {} \; 2>/dev/null
  find "$WP_DIR" -type f -exec chmod 644 {} \; 2>/dev/null

  if [ -f "$WP_DIR/wp-config.php" ]; then
    chmod 640 "$WP_DIR/wp-config.php" 2>/dev/null
  fi

  log_ok "İzinler varsayılan WordPress standartlarına çekildi."
}

fix_htaccess() {
  log_info ".htaccess dosyası kontrol ediliyor..."
  local ht="$WP_DIR/.htaccess"

  if [ -f "$ht" ]; then
    local backup="$WP_DIR/.htaccess.yedek-$(date +%F-%H%M%S)"
    cp "$ht" "$backup"
    log_ok ".htaccess yedeklendi: $backup"
    if confirm ".htaccess dosyasını WordPress varsayılanına sıfırlamak istiyor musunuz?"; then
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
    else
      log_warn ".htaccess olduğu gibi bırakıldı."
    fi
  else
    log_warn ".htaccess bulunamadı."
    if confirm "Yeni bir varsayılan WordPress .htaccess oluşturmak istiyor musunuz?"; then
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

cache_cleanup_and_fp() {
  log_info "Önbellek klasörleri ve FlyingPress yapısı analiz ediliyor..."

  # Önbellek klasörleri
  local caches=(
    "$WP_CONTENT/cache"
    "$WP_CONTENT/litespeed"
    "$WP_CONTENT/wp-rocket-config"
  )

  for c in "${caches[@]}"; do
    if [ -d "$c" ]; then
      log_info "Bulunan cache klasörü: $c"
      if confirm "Bu klasörün içini temizlemek istiyor musunuz? (klasör silinmez, sadece içi boşaltılır)"; then
        rm -rf "$c"/* 2>/dev/null
        log_ok "$c içeriği temizlendi."
      fi
    fi
  done

  # FlyingPress
  if [ -d "$WP_PLUGINS/flying-press" ]; then
    local fp_dir="$WP_CONTENT/flying-press"
    log_info "FlyingPress eklentisi kurulu görünüyor."

    if [ ! -d "$fp_dir" ]; then
      if confirm "wp-content/flying-press klasörü eksik. Oluşturulsun mu?"; then
        mkdir -p "$fp_dir"
        touch "$fp_dir/config.json"
        chmod 755 "$fp_dir"
        chmod 644 "$fp_dir/config.json"
        log_ok "FlyingPress klasörü ve config.json oluşturuldu."
      fi
    else
      if [ ! -f "$fp_dir/config.json" ]; then
        if confirm "FlyingPress config.json dosyası eksik. Oluşturulsun mu?"; then
          touch "$fp_dir/config.json"
          chmod 644 "$fp_dir/config.json"
          log_ok "config.json oluşturuldu."
        fi
      fi
    fi
  fi
}

scan_plugins_themes_basic() {
  log_info "Eklenti ve tema klasörleri temel sağlık taraması yapılıyor..."

  # Plugins
  for dir in "$WP_PLUGINS"/*; do
    [ -d "$dir" ] || continue
    local count_php
    count_php=$(find "$dir" -maxdepth 2 -type f -name "*.php" | wc -l)
    if [ "$count_php" -eq 0 ]; then
      log_warn "Şüpheli eklenti klasörü (hiç .php yok): $dir"
      if confirm "Bu klasörü '.disabled' yaparak devre dışı bırakmak ister misiniz?"; then
        mv "$dir" "${dir}.disabled"
        log_ok "$dir devre dışı bırakıldı."
      fi
    fi
  done

  # Themes
  for dir in "$WP_THEMES"/*; do
    [ -d "$dir" ] || continue
    local count_php
    count_php=$(find "$dir" -maxdepth 2 -type f -name "*.php" | wc -l)
    if [ "$count_php" -eq 0 ]; then
      log_warn "Şüpheli tema klasörü (hiç .php yok): $dir"
      if confirm "Bu tema klasörünü '.disabled' yaparak devre dışı bırakmak ister misiniz?"; then
        mv "$dir" "${dir}.disabled"
        log_ok "$dir devre dışı bırakıldı."
      fi
    fi
  done

  # Bozuk symlink
  log_info "Bozuk symlinkler aranıyor..."
  find "$WP_CONTENT" -xtype l -print 2>/dev/null | while read -r link; do
    log_warn "Bozuk symlink: $link"
    if confirm "Bu symlink'i kaldırmak ister misiniz?"; then
      rm "$link"
      log_ok "$link kaldırıldı."
    fi
  done
}

# -- DB temel test --

db_connection_test() {
  if [ $HAS_MYSQL -ne 1 ] || [ -z "$DB_NAME" ]; then
    log_warn "MySQL CLI veya DB bilgileri yok; DB bağlantı testi atlandı."
    return
  fi

  log_info "Veritabanı bağlantısı test ediliyor..."
  if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" >/dev/null 2>&1; then
    log_ok "Veritabanı bağlantısı başarılı."
  else
    log_err "Veritabanı bağlantısı başarısız! wp-config.php içindeki DB bilgilerini kontrol ediniz."
  fi
}

# -- wp-config önerileri --

wp_config_suggestions() {
  local conf="$WP_DIR/wp-config.php"
  [ -f "$conf" ] || return

  log_info "wp-config.php ayarları analiz ediliyor..."
  # Sadece öneri çıktıları; istenirse ekleme yapar.

  if ! grep -q "WP_MEMORY_LIMIT" "$conf"; then
    log_warn "WP_MEMORY_LIMIT tanımlı değil."
    if confirm "WooCommerce için WP_MEMORY_LIMIT'i 256M olarak eklemek ister misiniz?"; then
      echo "define('WP_MEMORY_LIMIT', '256M');" >> "$conf"
      echo "define('WP_MAX_MEMORY_LIMIT', '512M');" >> "$conf"
      log_ok "WP_MEMORY_LIMIT ve WP_MAX_MEMORY_LIMIT eklendi."
    fi
  fi

  if ! grep -q "DISABLE_WP_CRON" "$conf"; then
    log_warn "DISABLE_WP_CRON tanımlı değil."
    if confirm "Gerçek cron kullanmak üzere DISABLE_WP_CRON sabitini eklemek ister misiniz?"; then
      echo "define('DISABLE_WP_CRON', true);" >> "$conf"
      log_ok "DISABLE_WP_CRON eklendi. Sunucunuzda gerçek cron job tanımlamayı unutmayın."
    fi
  fi
}

# -- Woo temel / gelişmiş --

woo_basic_checks() {
  log_info "WooCommerce temel kontrolü yapılıyor..."
  if [ ! -d "$WP_PLUGINS/woocommerce" ]; then
    log_warn "WooCommerce eklentisi kurulu görünmüyor."
    return
  fi

  if [ $HAS_MYSQL -ne 1 ] || [ -z "$DB_NAME" ]; then
    log_warn "DB komutları kullanılamıyor; WooCommerce tablo kontrolü atlandı."
    return
  fi

  local table
  table="${DB_PREFIX}wc_sessions"
  local exists
  exists=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -N -e "SHOW TABLES LIKE '$table';" 2>/dev/null)
  if [ -n "$exists" ]; then
    log_ok "$table tablosu mevcut."
  else
    log_err "$table tablosu eksik! WooCommerce sepet sistemi sorun çıkarabilir."
  fi
}

woo_advanced_checks() {
  log_info "WooCommerce gelişmiş tablo kontrolleri yapılıyor..."
  if [ ! -d "$WP_PLUGINS/woocommerce" ]; then
    return
  fi

  if [ $HAS_MYSQL -ne 1 ] || [ -z "$DB_NAME" ]; then
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
      log_warn "$t tablosu bulunamadı. WooCommerce raporları veya istatistikleri eksik olabilir."
    fi
  done
}

# -- wp-cli tabanlı işlemler --

wpcli_core_plugin_checks() {
  if [ $HAS_WPCLI -ne 1 ]; then
    log_warn "WP-CLI bulunamadı; gelişmiş wp-cli işlemleri atlandı."
    return
  fi

  log_info "wp-cli ile core/plugin checksum kontrolleri yapılıyor..."
  if confirm "WordPress çekirdek dosyaları için 'wp core verify-checksums' çalıştırılsın mı?"; then
    wp core verify-checksums --path="$WP_DIR"
  fi

  if confirm "Tüm eklentiler için 'wp plugin verify-checksums --all' çalıştırılsın mı?"; then
    wp plugin verify-checksums --all --path="$WP_DIR" || \
      log_warn "Bazı eklentiler checksum desteği vermiyor olabilir."
  fi

  if confirm "Tüm eklentileri 'wp plugin update --all' ile güncellemek ister misiniz?"; then
    wp plugin update --all --path="$WP_DIR"
  fi

  if confirm "Tüm temaları 'wp theme update --all' ile güncellemek ister misiniz?"; then
    wp theme update --all --path="$WP_DIR"
  fi
}

wpcli_db_repair() {
  if [ $HAS_WPCLI -ne 1 ]; then
    return
  fi

  log_info "wp-cli ile veritabanı sağlık kontrolleri..."
  if confirm "'wp db check' çalıştırılsın mı?"; then
    wp db check --path="$WP_DIR"
  fi
  if confirm "'wp db repair' çalıştırılsın mı? (bozuk tabloları onarmaya çalışır)"; then
    wp db repair --path="$WP_DIR"
  fi
}

woo_rest_api_tests() {
  if [ $HAS_WPCLI -ne 1 ]; then
    log_warn "WP-CLI yok; Woo REST API testleri sınırlıdır."
  fi

  log_info "WooCommerce REST API sepet endpoint testi..."
  local url=""
  if [ $HAS_WPCLI -eq 1 ]; then
    url=$(wp option get siteurl --path="$WP_DIR" 2>/dev/null)
  fi
  if [ -z "$url" ]; then
    read -r -p "Site URL'ini (https://site.com) manuel girin: " url
  fi

  if [ -n "$url" ]; then
    curl -s -o /dev/null -w "HTTP Kodu: %{http_code}, Süre: %{time_total}s\n" "$url/wp-json/wc/store/cart"
  fi
}

# -- Performans testleri --

performance_tests() {
  log_info "Performans testleri yapılıyor (basit benchmark)..."
  local url=""
  if [ $HAS_WPCLI -eq 1 ]; then
    url=$(wp option get siteurl --path="$WP_DIR" 2>/dev/null)
  fi
  if [ -z "$url" ]; then
    read -r -p "Ana sayfa URL'inizi girin (https://site.com): " url
  fi
  if [ -z "$url" ]; then
    log_warn "URL verilmedi, TTFB testi atlandı."
    return
  fi

  log_info "TTFB testi: $url"
  curl -s -o /dev/null -w "TTFB: %{time_starttransfer}s, Toplam Süre: %{time_total}s, HTTP: %{http_code}\n" "$url"

  # Disk IO (çok hafif bir test)
  log_info "Disk IO (yazma-okuma) mini test..."
  local testfile="$WP_DIR/wp-healer-io-test.tmp"
  dd if=/dev/zero of="$testfile" bs=1M count=5 oflag=dsync 2>/dev/null
  dd if="$testfile" of=/dev/null bs=1M 2>/dev/null
  rm -f "$testfile"
  log_ok "Disk IO mini test tamamlandı. (Detay için iostat / sar gibi araçlar kullanılabilir.)"
}

# -- Güvenlik taraması --

security_scan_light() {
  log_info "Hafif güvenlik taraması çalıştırılıyor (şüpheli fonksiyon arama)..."
  local target="$WP_DIR"
  grep -R --line-number --include="*.php" -E "base64_decode\(|shell_exec\(|system\(|gzinflate\(" "$target" 2>/dev/null | head -n 50 \
    && log_warn "Yukarıdaki satırlar POTANSİYEL şüpheli kodlar olabilir. Manuel inceleme önerilir." \
    || log_ok "Belirgin şüpheli pattern bulunamadı (bu %100 temiz olduğu anlamına gelmez)."
}

# -- Log analizi (AI-lite tarzı pattern) --

logs_analysis() {
  log_info "Log analizi (error_log, debug.log) yapılıyor..."
  local candidates=(
    "$WP_DIR/error_log"
    "$WP_DIR/debug.log"
    "$WP_CONTENT/debug.log"
  )

  for f in "${candidates[@]}"; do
    if [ -f "$f" ]; then
      log_info "Log dosyası bulundu: $f"
      echo -e "${C_BOLD}Son 30 satır:${C_RESET}"
      tail -n 30 "$f"
      echo
      log_info "Örüntü analizi:"
      grep -Ei "fatal|error|warning|deprecated|out of memory|allowed memory size|maximum execution time" "$f" 2>/dev/null | tail -n 20
      echo
    fi
  done
}

# -- Cloudflare işlemleri --

cloudflare_module() {
  log_info "Cloudflare modülü (isteğe bağlı)..."
  if ! confirm "Cloudflare API ile işlem yapmak istiyor musunuz?"; then
    return
  fi

  read -r -p "Cloudflare API Key (Global API Key veya Token): " CF_KEY
  read -r -p "Cloudflare E-posta (Global Key kullanıyorsanız): " CF_MAIL
  read -r -p "Cloudflare Zone ID: " CF_ZONE

  if [ -z "$CF_KEY" ] || [ -z "$CF_ZONE" ]; then
    log_err "API Key veya Zone ID eksik; Cloudflare işlemleri iptal edildi."
    return
  fi

  if confirm "Cloudflare FULL cache purge yapılsın mı?"; then
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE/purge_cache" \
      -H "X-Auth-Email: $CF_MAIL" \
      -H "X-Auth-Key: $CF_KEY" \
      -H "Content-Type: application/json" \
      --data '{"purge_everything":true}' >/dev/null 2>&1 \
      && log_ok "Cloudflare full cache purge isteği gönderildi." \
      || log_warn "Cloudflare purge isteği başarısız olabilir."
  fi
}

# -------- MOD ÇALIŞTIRMA FONKSIYONLARI --------

run_baslangic() {
  MODE_NAME="Baslangic"
  log_info "Başlangıç Onarımı başlatılıyor..."
  fix_permissions
  fix_htaccess
  cache_cleanup_and_fp
  scan_plugins_themes_basic
}

run_standart() {
  MODE_NAME="Standart"
  log_info "Standart Onarım başlatılıyor..."
  run_baslangic
  db_connection_test
  wp_config_suggestions
  woo_basic_checks
}

run_gelismis() {
  MODE_NAME="Gelismis"
  log_info "Gelişmiş Onarım başlatılıyor..."
  run_standart
  wpcli_core_plugin_checks
  wpcli_db_repair
  woo_rest_api_tests
}

run_pro() {
  MODE_NAME="PRO"
  log_info "PRO Onarım başlatılıyor..."
  run_gelismis
  performance_tests
  security_scan_light
}

run_ultra() {
  MODE_NAME="ULTRA"
  log_info "ULTRA Onarım başlatılıyor..."
  run_pro
  logs_analysis
  woo_advanced_checks
  cloudflare_module
}

run_custom() {
  MODE_NAME="Custom"
  log_info "Özel / Custom Onarım Modu başlatılıyor..."

  echo
  echo -e "${C_BOLD}Aktif etmek istediğiniz modülleri seçin (virgülle ayırın):${C_RESET}"
  echo "1) Temel İzin + .htaccess + Cache + Plugin/Theme taraması"
  echo "2) Veritabanı bağlantı testi + wp-config önerileri"
  echo "3) WooCommerce temel + gelişmiş tablo kontrolleri"
  echo "4) wp-cli çekirdek / eklenti / DB işlemleri"
  echo "5) Performans testleri"
  echo "6) Güvenlik taraması"
  echo "7) Log analizi"
  echo "8) Cloudflare işlemleri"
  echo
  read -r -p "Seçim (örnek: 1,3,5): " choices

  IFS=',' read -ra arr <<< "$choices"
  for c in "${arr[@]}"; do
    c="$(echo "$c" | xargs)"  # trim
    case "$c" in
      1)
        fix_permissions
        fix_htaccess
        cache_cleanup_and_fp
        scan_plugins_themes_basic
        ;;
      2)
        db_connection_test
        wp_config_suggestions
        ;;
      3)
        woo_basic_checks
        woo_advanced_checks
        ;;
      4)
        wpcli_core_plugin_checks
        wpcli_db_repair
        ;;
      5)
        performance_tests
        ;;
      6)
        security_scan_light
        ;;
      7)
        logs_analysis
        ;;
      8)
        cloudflare_module
        ;;
      *)
        log_warn "Geçersiz seçim: $c"
        ;;
    esac
  done
}

# -------- MAIN --------

main() {
  banner

  if ! confirm "Bu betiği çalıştırmadan önce tam dosya + veritabanı yedeği aldınız mı?"; then
    log_err "Yedek almadan devam etmek önerilmez. İşlem iptal edildi."
    exit 1
  fi

  get_system_info
  system_suggestions

  detect_wp_dir
  load_db_creds

  echo -e "${C_BOLD}Bir onarım modu seçin:${C_RESET}"
  echo "1) Başlangıç Onarımı   (çok güvenli)"
  echo "2) Standart Onarım     (önerilen)"
  echo "3) Gelişmiş Onarım     (ileri düzey)"
  echo "4) PRO Onarım          (performans + güvenlik)"
  echo "5) ULTRA Onarım        (tüm modüller)"
  echo "6) Özel / Custom Onarım"
  echo
  read -r -p "Seçiminiz (1-6): " mode

  local status="unknown"

  case "$mode" in
    1) run_baslangic; status="ok" ;;
    2) run_standart; status="ok" ;;
    3) run_gelismis; status="ok" ;;
    4) run_pro; status="ok" ;;
    5) run_ultra; status="ok" ;;
    6) run_custom; status="ok" ;;
    *)
      log_err "Geçersiz seçim. Betik sonlandırıldı."
      status="invalid_mode"
      ;;
  esac

  write_local_stats "$status"

  echo
  log_ok "WP-Healer ULTRA işlemleri tamamlandı. Seçilen mod: $MODE_NAME"
  echo -e "${C_YELLOW}Lütfen sitenizi, admin panelini ve WooCommerce sepet/checkout akışını test etmeyi unutmayın.${C_RESET}"
  pause
}

main
