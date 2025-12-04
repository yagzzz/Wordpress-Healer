#!/bin/bash

C_RESET="\e[0m"
C_BOLD="\e[1m"
C_RED="\e[31m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_BLUE="\e[34m"
C_MAGENTA="\e[35m"
C_CYAN="\e[36m"

log_info()  { echo -e "${C_CYAN}[i]${C_RESET} $1"; }
log_ok()    { echo -e "${C_GREEN}[✓]${C_RESET} $1"; }
log_warn()  { echo -e "${C_YELLOW}[!]${C_RESET} $1"; }
log_err()   { echo -e "${C_RED}[X]${C_RESET} $1"; }

log_section() {
  echo
  echo -e "${C_BOLD}${C_BLUE}========== $1 ==========${C_RESET}"
}
