#!/bin/bash

system_collect_info() {
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

  if command -v free >/dev/null 2>&1; then
    RAM_TOTAL_MB=$(free -m | awk '/Mem:/ {print $2}')
  fi

  DISK_USAGE="$(df -h / | awk 'NR==2 {print $5" ("$3"/"$2")"}')"

  if command -v php >/dev/null 2>&1; then
    PHP_VERSION_STR="$(php -r 'echo PHP_VERSION;' 2>/dev/null)"
  fi

  if command -v mysql >/dev/null 2>&1; then
    MYSQL_VERSION_STR="$(mysql -V 2>/dev/null)"
  fi
}

system_print_summary() {
  log_section "Sistem Özeti"
  echo "- OS:           ${OS_NAME} ${OS_VERSION}"
  echo "- Kernel:       ${KERNEL}"
  echo "- RAM Toplam:   ${RAM_TOTAL_MB} MB"
  echo "- CPU Çekirdek: ${CPU_CORES}"
  echo "- Disk Kullanım: ${DISK_USAGE}"
  echo "- PHP:          ${PHP_VERSION_STR:-bulunamadı}"
  echo "- MySQL/MariaDB: ${MYSQL_VERSION_STR:-bulunamadı}"
}

system_print_suggestions() {
  log_section "Sistem Bazlı Öneriler"

  if [ "$RAM_TOTAL_MB" -gt 0 ] && [ "$RAM_TOTAL_MB" -lt 4000 ]; then
    log_warn "RAM düşük görünüyor (${RAM_TOTAL_MB} MB). WooCommerce için en az 4 GB önerilir."
  else
    log_ok "RAM miktarı çoğu WooCommerce sitesi için yeterli seviyede."
  fi

  if [ "$CPU_CORES" -gt 0 ] && [ "$CPU_CORES" -lt 2 ]; then
    log_warn "CPU çekirdek sayısı çok düşük (${CPU_CORES}). Yüksek trafikte yavaşlama yaşayabilirsin."
  elif [ "$CPU_CORES" -ge 2 ] && [ "$CPU_CORES" -lt 4 ]; then
    log_info "CPU çekirdek sayısı orta seviye (${CPU_CORES}). Orta ölçekli siteler için kabul edilebilir."
  else
    log_ok "CPU çekirdek sayısı iyi (${CPU_CORES})."
  fi

  if [ -n "$PHP_VERSION_STR" ]; then
    major=$(echo "$PHP_VERSION_STR" | cut -d. -f1)
    minor=$(echo "$PHP_VERSION_STR" | cut -d. -f2)
    if [ "$major" -lt 8 ] || { [ "$major" -eq 8 ] && [ "$minor" -lt 1 ]; }; then
      log_warn "PHP sürümün (${PHP_VERSION_STR}) eski olabilir. Güvenlik ve performans için PHP 8.1+ tavsiye edilir."
    else
      log_ok "PHP sürümün (${PHP_VERSION_STR}) güncel ve uyumlu."
    fi
  fi
}

system_capacity_report() {
  log_section "Kapasite Öneri Raporu"

  echo "Bu rapor yaklaşık tavsiye verir (özellikle WooCommerce için):"
  echo

  if [ "$CPU_CORES" -ge 4 ] && [ "$RAM_TOTAL_MB" -ge 6000 ]; then
    echo "- Tahmini seviye: Orta-Büyük WooCommerce mağazası için UYGUN."
  elif [ "$CPU_CORES" -ge 2 ] && [ "$RAM_TOTAL_MB" -ge 4000 ]; then
    echo "- Tahmini seviye: Küçük/Orta WooCommerce mağazası için YETERLİ."
  else
    echo "- Tahmini seviye: Küçük site için uygun, yoğun WooCommerce trafiğinde sorun yaşanabilir."
  fi

  echo
  echo "Önerilen minimumlar:"
  echo "- CPU: 2–4 çekirdek"
  echo "- RAM: 4–8 GB"
  echo "- PHP Worker: 5–10+ (sunucuna göre)"
}
