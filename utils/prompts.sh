#!/bin/bash

label_to_text() {
  case "$1" in
    GEREKLI)   echo -e "${C_RED}(GEREKLİ)${C_RESET}" ;;
    ONERILIR)  echo -e "${C_GREEN}(ÖNERİLİR)${C_RESET}" ;;
    RISKLI)    echo -e "${C_RED}(RİSKLİ)${C_RESET}" ;;
    OPSIYONEL) echo -e "${C_CYAN}(OPSİYONEL)${C_RESET}" ;;
    ILERI)     echo -e "${C_MAGENTA}(İLERİ SEVİYE)${C_RESET}" ;;
    *)
      echo ""
      ;;
  esac
}

confirm_labeled() {
  local label="$1"
  shift
  local q="$*"
  local label_txt
  label_txt="$(label_to_text "$label")"
  echo
  read -r -p "$(echo -e "${C_YELLOW}${q} ${label_txt} (E/h): ${C_RESET}")" ans
  case "$ans" in
    e|E|evet|EVET|Evet) return 0 ;;
    *) return 1 ;;
  esac
}
