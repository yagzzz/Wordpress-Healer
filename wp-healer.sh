#!/bin/bash
# ============================================================
#   WP-HEALER ULTRA+ (Türkçe, Modüler Sürüm)
#   WordPress Otomatik Onarım, Teşhis ve Optimizasyon Aracı
#   Modlar: Başlangıç • Standart • Gelişmiş • PRO • ULTRA • Özel
# ============================================================

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
export BASE_DIR

# Utils dosyalarını yükle
# (Sıralama önemli: önce colors, sonra logging, sonra prompts)
for util in "colors.sh" "logging.sh" "prompts.sh"; do
  if [ -f "$BASE_DIR/utils/$util" ]; then
    # shellcheck source=/dev/null
    . "$BASE_DIR/utils/$util"
  else
    echo "Eksik utils dosyası: utils/$util"
    exit 1
  fi
done

# Modülleri yükle
for mod in system.sh wp-core.sh filesystem.sh db.sh woo.sh wpcli.sh perf.sh security.sh cloudflare.sh; do
  if [ -f "$BASE_DIR/modules/$mod" ]; then
    # shellcheck source=/dev/null
    . "$BASE_DIR/modules/$mod"
  else
    log_warn "Modül yüklenemedi (opsiyonel olabilir): modules/$mod"
  fi
done

banner() {
  clear
  echo -e "${C_BOLD}${C_MAGENTA}"
  echo "======================================================"
  echo "              WP-HEALER ULTRA+  (Türkçe)"
  echo "======================================================"
  echo -e "${C_RESET}"
  echo -e "${C_RED}${C_BOLD}UYARI:${C_RESET} Devam etmeden önce mutlaka DOSYA + VERİTABANI YEDEĞİ alman ÖNERİLİR."
  echo
}

main_menu() {
  echo -e "${C_BOLD}Bir onarım modu seç:${C_RESET}"
  echo "  1) Başlangıç Onarımı          (çok güvenli, temel) [ÖNERİLİR]"
  echo "  2) Standart Onarım            (ek testler)        [ÖNERİLİR]"
  echo "  3) Gelişmiş Onarım            (wp-cli, Woo)       [İLERİ SEVİYE]"
  echo "  4) PRO Onarım                 (performans+güvenlik) [İLERİ SEVİYE]"
  echo "  5) ULTRA+ Onarım              (tüm modüller)      [RİSKLİ / PRO]"
  echo "  6) Özel / Custom Onarım       (istediğin modülleri seç)"
  echo
  read -r -p "Seçimin (1-6): " MODE_CHOICE
}

run_mode_baslangic() {
  MODE_NAME="Baslangic"
  log_section "Başlangıç Onarımı"
  fs_fix_permissions         # (ÖNERİLİR)
  fs_fix_htaccess            # (ÖNERİLİR)
  fs_cache_and_flyingpress   # (ÖNERİLİR)
  fs_scan_plugins_themes     # (ÖNERİLİR)
}

run_mode_standart() {
  MODE_NAME="Standart"
  log_section "Standart Onarım"
  run_mode_baslangic
  db_basic_tests             # (GEREKLİ / ÖNERİLİR)
  wp_config_tweaks           # (ÖNERİLİR)
  woo_basic_checks           # (Woo varsa ÖNERİLİR)
}

run_mode_gelismis() {
  MODE_NAME="Gelismis"
  log_section "Gelişmiş Onarım"
  run_mode_standart
  db_wpcli_repair            # (İLERİ SEVİYE)
  woo_advanced_checks        # (İLERİ SEVİYE)
  woo_cron_analysis          # (İLERİ SEVİYE)
}

run_mode_pro() {
  MODE_NAME="PRO"
  log_section "PRO Onarım"
  run_mode_gelismis
  wpcli_core_plugin_checks   # (İLERİ SEVİYE / RİSKLİ - güncelleme)
  wpcli_core_restore_suggest # (OPSİYONEL, riskli öneri)
  perf_run_basic             # (ÖNERİLİR)
  perf_phpfpm_suggest        # (ÖNERİLİR)
  security_scan_light        # (ÖNERİLİR)
}

run_mode_ultra() {
  MODE_NAME="ULTRA+"
  log_section "ULTRA+ Onarım"
  run_mode_pro
  logs_analysis_ai_like      # (İLERİ SEVİYE)
  system_capacity_report     # (ÖNERİLİR)
  cf_module                  # (OPSİYONEL, Cloudflare)
}

run_mode_custom() {
  MODE_NAME="Custom"
  log_section "Özel / Custom Onarım"

  echo -e "${C_BOLD}Aktif etmek istediğin modülleri seç (virgülle):${C_RESET}"
  echo "  1) Dosya sistemi / izinler / .htaccess / cache / plugin-tema"
  echo "  2) Veritabanı testleri ve wp-config optimizasyonları"
  echo "  3) WooCommerce kontrolleri (temel + gelişmiş + cron)"
  echo "  4) wp-cli core/plugin/theme ve DB onarımları"
  echo "  5) Performans testleri + PHP-FPM önerileri"
  echo "  6) Güvenlik taraması + log analizi"
  echo "  7) Cloudflare API ile cache purge vb."
  echo
  read -r -p "Seçim (örnek: 1,3,5): " CHOICES

  IFS=',' read -ra arr <<< "$CHOICES"
  for c in "${arr[@]}"; do
    c="$(echo "$c" | xargs)"
    case "$c" in
      1)
        fs_fix_permissions
        fs_fix_htaccess
        fs_cache_and_flyingpress
        fs_scan_plugins_themes
        ;;
      2)
        db_basic_tests
        wp_config_tweaks
        ;;
      3)
        woo_basic_checks
        woo_advanced_checks
        woo_cron_analysis
        ;;
      4)
        db_wpcli_repair
        wpcli_core_plugin_checks
        wpcli_core_restore_suggest
        ;;
      5)
        perf_run_basic
        perf_phpfpm_suggest
        ;;
      6)
        security_scan_light
        logs_analysis_ai_like
        ;;
      7)
        cf_module
        ;;
      *)
        log_warn "Geçersiz seçim: $c"
        ;;
    esac
  done
}

main() {
  banner

  if ! confirm_labeled "GEREKLI" "Bu aracı çalıştırmadan önce dosya + veritabanı yedeği aldın mı?"; then
    log_err "Yedek almadan devam etmek önerilmez. Çıkılıyor."
    exit 1
  fi

  init_logging                           # logs/ klasörü + temel log
  system_collect_info                    # OS / RAM / CPU / PHP / MySQL
  system_print_summary
  system_print_suggestions               # RAM/CPU/PHP önerileri
  wp_detect_and_load                     # WP yolu + wp-config + DB bilgisi

  main_menu

  STATUS="unknown"

  case "$MODE_CHOICE" in
    1) run_mode_baslangic; STATUS="ok" ;;
    2) run_mode_standart; STATUS="ok" ;;
    3) run_mode_gelismis; STATUS="ok" ;;
    4) run_mode_pro; STATUS="ok" ;;
    5) run_mode_ultra; STATUS="ok" ;;
    6) run_mode_custom; STATUS="ok" ;;
    *)
      log_err "Geçersiz mod seçimi. Betik sonlandırıldı."
      STATUS="invalid_mode"
      ;;
  esac

  write_stats_json "$STATUS"
  log_ok "WP-Healer ULTRA+ tamamlandı. Seçilen mod: $MODE_NAME"
  echo -e "${C_YELLOW}Lütfen siteni, admin panelini ve WooCommerce sepet/checkout akışını test etmeyi unutma.${C_RESET}"
}

main
