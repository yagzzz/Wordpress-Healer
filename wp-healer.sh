#!/bin/bash
#
# ============================================================
#   WP-HEALER PRO+ (Türkçe Sürüm)
#   WordPress Otomatik Onarım ve Optimizasyon Aracı
#   Modlar: Başlangıç • Standart • Gelişmiş • Gelişmiş+
# ============================================================

RENK_KIRMIZI="\e[31m"
RENK_YESIL="\e[32m"
RENK_SARI="\e[33m"
RENK_MAVI="\e[34m"
KALIN="\e[1m"
SIFIR="\e[0m"

sor() {
  read -r -p "$(echo -e "${RENK_SARI}$1 (E/h): ${SIFIR}")" cevap
  case "$cevap" in
    e|E|evet|EVET) return 0 ;;
    *) return 1 ;;
  esac
}

bekle() {
  read -r -p "$(echo -e "${RENK_SARI}Devam etmek için Enter'a basın...${SIFIR}")" _
}

banner() {
  clear
  echo -e "${KALIN}${RENK_MAVI}"
  echo "=================================================="
  echo "            WP-HEALER PRO+ (Türkçe)"
  echo "=================================================="
  echo -e "${SIFIR}"
  echo -e "${RENK_KIRMIZI}${KALIN}UYARI: İşleme başlamadan önce tam yedek almanız önerilir!${SIFIR}"
  echo
}

WP_DIZIN=""
WPC=""
WPP=""
WPT=""

veritabani_bilgilerini_yukle() {
  if ! command -v php >/dev/null 2>&1; then
    echo -e "${RENK_SARI}php komutu bulunamadı, veritabanı bilgileri okunamayabilir.${SIFIR}"
    return
  fi

  DB_ADI=$(php -r "include '$WP_DIZIN/wp-config.php'; echo DB_NAME;" 2>/dev/null)
  DB_KULLANICI=$(php -r "include '$WP_DIZIN/wp-config.php'; echo DB_USER;" 2>/dev/null)
  DB_SIFRE=$(php -r "include '$WP_DIZIN/wp-config.php'; echo DB_PASSWORD;" 2>/dev/null)
  DB_HOST=$(php -r "include '$WP_DIZIN/wp-config.php'; echo DB_HOST;" 2>/dev/null)

  echo -e "${RENK_YESIL}Veritabanı: $DB_ADI${SIFIR}"
}

wp_dizin_bul() {
  echo -e "${RENK_YESIL}WordPress dizini aranıyor...${SIFIR}"

  if [ -f "./wp-config.php" ]; then
    WP_DIZIN="$(pwd)"
  else
    KANDIDATES=($(find /home -maxdepth 6 -type f -name "wp-config.php" 2>/dev/null))
    if [ "${#KANDIDATES[@]}" -eq 1 ]; then
      WP_DIZIN=$(dirname "${KANDIDATES[0]}")
    else
      echo -e "${RENK_SARI}Birden fazla WordPress bulundu.${SIFIR}"
      i=1
      for k in "${KANDIDATES[@]}"; do
        echo " [$i] $k"
        i=$((i+1))
      done
      read -r -p "Seçiminiz: " secim
      WP_DIZIN=$(dirname "${KANDIDATES[$((secim-1))]}")
    fi
  fi

  if [ ! -f "$WP_DIZIN/wp-config.php" ]; then
    echo -e "${RENK_KIRMIZI}wp-config.php bulunamadı. Script durduruldu.${SIFIR}"
    exit 1
  fi

  WPC="$WP_DIZIN/wp-content"
  WPP="$WPC/plugins"
  WPT="$WPC/themes"

  echo -e "${RENK_YESIL}WordPress dizini: $WP_DIZIN${SIFIR}"
}

izinleri_duzelt() {
  echo -e "${RENK_MAVI}${KALIN}→ Dosya izinleri taranıyor...${SIFIR}"
  if sor "İzinleri WordPress standartlarına göre düzeltmek istiyor musunuz?"; then
    find "$WP_DIZIN" -type d -exec chmod 755 {} \;
    find "$WP_DIZIN" -type f -exec chmod 644 {} \;
    echo -e "${RENK_YESIL}İzinler düzeltildi.${SIFIR}"
  fi
}

htaccess_kontrol() {
  echo -e "${RENK_MAVI}${KALIN}→ .htaccess kontrol ediliyor...${SIFIR}"
  if [ ! -f "$WP_DIZIN/.htaccess" ]; then
    if sor ".htaccess dosyası bulunamadı. Oluşturulsun mu?"; then
      cat > "$WP_DIZIN/.htaccess" << 'EOF'
# WordPress Varsayılan
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
EOF
      echo "Oluşturuldu."
    fi
  else
    if sor ".htaccess bozuk olabilir. Varsayılana sıfırlansın mı?"; then
      cp "$WP_DIZIN/.htaccess" "$WP_DIZIN/.htaccess-yedek"
      echo "(yedek oluşturuldu)"
    fi
  fi
}

cache_kontrol() {
  echo -e "${RENK_MAVI}${KALIN}→ Cache taraması yapılıyor...${SIFIR}"

  CACHE_KLASORLER=(
    "$WPC/cache"
    "$WPC/litespeed"
    "$WPC/wp-rocket-config"
  )

  for c in "${CACHE_KLASORLER[@]}"; do
    if [ -d "$c" ]; then
      echo "- Bulundu: $c"
      if sor "İçi temizlensin mi?"; then
        rm -rf "$c"/*
        echo "Temizlendi."
      fi
    fi
  done
}

woo_kontrol() {
  echo -e "${RENK_MAVI}${KALIN}→ WooCommerce temel tablo kontrolü...${SIFIR}"

  if [ ! -d "$WPP/woocommerce" ]; then
    echo -e "${RENK_SARI}WooCommerce kurulu değil, bu adım atlandı.${SIFIR}"
    return
  fi

  mysql -h "$DB_HOST" -u "$DB_KULLANICI" -p"$DB_SIFRE" "$DB_ADI" -e \
    "SHOW TABLES LIKE '%wc_sessions%';" | grep wc_sessions && \
    echo -e "${RENK_YESIL}wc_sessions tablosu mevcut.${SIFIR}" || \
    echo -e "${RENK_KIRMIZI}wc_sessions tablosu EKSİK!${SIFIR}"
}

gelismis_wpcli() {
  if ! command -v wp >/dev/null 2>&1; then
    echo -e "${RENK_SARI}wp-cli bulunamadı, gelişmiş işlemler atlandı.${SIFIR}"
    return
  fi

  echo -e "${RENK_MAVI}${KALIN}→ wp-cli ile gelişmiş bakım${SIFIR}"

  if sor "WordPress çekirdek checksum doğrulaması yapılsın mı?"; then
    wp core verify-checksums --path="$WP_DIZIN"
  fi

  if sor "Eklentilerin checksum doğrulaması yapılsın mı?"; then
    wp plugin verify-checksums --all --path="$WP_DIZIN"
  fi

  if sor "Tüm eklentiler güncellensin mi?"; then
    wp plugin update --all --path="$WP_DIZIN"
  fi
}

cloudflare_proplus() {
  echo -e "${RENK_MAVI}${KALIN}→ Cloudflare PRO+ Modu${SIFIR}"

  if ! sor "Cloudflare API işlemlerini aktif etmek istiyor musunuz?"; then
    return
  fi

  read -r -p "API Key: " CF_KEY
  read -r -p "E-Posta: " CF_MAIL
  read -r -p "Zone ID: " CF_ZONE

  if sor "Cloudflare Full Cache Purge yapılsın mı?"; then
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE/purge_cache" \
      -H "X-Auth-Email: $CF_MAIL" \
      -H "X-Auth-Key: $CF_KEY" \
      -H "Content-Type: application/json" \
      --data '{"purge_everything":true}'
    echo "İstek gönderildi."
  fi
}

# ——————————————————————————
# ——————— ÇALIŞTIRMA ——————
# ——————————————————————————

banner

wp_dizin_bul
veritabani_bilgilerini_yukle

echo
echo -e "${KALIN}Bir onarım modu seçin:${SIFIR}"
echo "1) Başlangıç Onarımı"
echo "2) Standart Onarım"
echo "3) Gelişmiş Onarım"
echo "4) Gelişmiş+ Onarım"
echo
read -r -p "Seçim: " MOD

case "$MOD" in
  1)
    izinleri_duzelt
    htaccess_kontrol
    cache_kontrol
    ;;
  2)
    izinleri_duzelt
    htaccess_kontrol
    cache_kontrol
    woo_kontrol
    ;;
  3)
    izinleri_duzelt
    htaccess_kontrol
    cache_kontrol
    woo_kontrol
    gelismis_wpcli
    ;;
  4)
    izinleri_duzelt
    htaccess_kontrol
    cache_kontrol
    woo_kontrol
    gelismis_wpcli
    cloudflare_proplus
    ;;
  *)
    echo -e "${RENK_KIRMIZI}Geçersiz seçim!${SIFIR}"
    exit 1
    ;;
esac

echo -e "${RENK_YESIL}İşlem başarıyla tamamlandı.${SIFIR}"
bekle
exit 0
