#!/bin/bash

cf_module() {
  log_section "Cloudflare Modülü"

  if ! confirm_labeled "OPSIYONEL" "Cloudflare API ile işlem yapmak istiyor musun?"; then
    return
  fi

  read -r -p "Cloudflare API Key (Global veya Token): " CF_KEY
  read -r -p "Cloudflare E-posta (Global key için): " CF_MAIL
  read -r -p "Cloudflare Zone ID: " CF_ZONE

  if [ -z "$CF_KEY" ] || [ -z "$CF_ZONE" ]; then
    log_err "API Key veya Zone ID boş. Cloudflare işlemleri iptal."
    return
  fi

  if confirm_labeled "ONERILIR" "FULL cache purge yapılsın mı? (tüm site cache'i temizler)"; then
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE/purge_cache" \
      -H "X-Auth-Email: $CF_MAIL" \
      -H "X-Auth-Key: $CF_KEY" \
      -H "Content-Type: application/json" \
      --data '{"purge_everything":true}' >/dev/null 2>&1 \
      && log_ok "Cloudflare full cache purge isteği gönderildi." \
      || log_warn "Cloudflare purge isteği başarısız olabilir."
  fi
}
