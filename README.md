# 📘 WP-Healer ULTRA (Türkçe Sürüm)
### WordPress Otomatik Onarım, Teşhis ve Optimizasyon Aracı

**Başlangıç • Standart • Gelişmiş • PRO • ULTRA • Özel (Custom)** modları ile tam koruma sağlar.

WP-Healer ULTRA, WordPress kurulumlarında karşılaşılan sorunları otomatik olarak algılayan, her adımda kullanıcıya sorarak güvenli şekilde onaran ve ayrıntılı performans / güvenlik / WooCommerce / Cloudflare / sunucu teşhisi yapan gelişmiş bir komut satırı betiğidir.

WordPress yolunu otomatik bulur, wp-config dosyasından veritabanı bilgilerini çıkarır, sistem kaynaklarını analiz eder, hata loglarını inceleyerek öneriler üretir ve isterseniz istatistiksel kullanım verilerini anonim şekilde toplayıp kendi sisteminize POST edebilir (tamamen isteğe bağlı).

---

## 📂 Klasör Yapısı (Türkçe)

Proje önerilen şekilde şu yapı ile kullanılabilir:

```text
wp-healer/
│
├─ wp-healer-ultra.sh     # Ana betik (ULTRA sürümü)
├─ README.md              # Bu dosya
├─ LISANS                 # MIT Lisansı (Türkçe açıklama)
│
├─ varliklar/             # Görsel, ikon vb. dosyalar (opsiyonel)
│   └─ terminal-goruntu.png
│
└─ ornekler/              # Örnek çıktı ve log kayıtları
    └─ ornek-log.txt
```

---

## 🚀 Öne Çıkan Özellikler

### 🎯 Otomatik Tespit & Sistem Özeti

Betik çalıştığında önce kapsamlı bir **sistem özeti** üretir:

- İşletim sistemi / sürüm
- Çekirdek (kernel) sürümü
- Toplam RAM ve kullanılabilir RAM
- Toplam CPU çekirdek sayısı
- Disk doluluk oranı (WordPress klasörü içeren disk)
- PHP sürümü (varsa)
- MySQL/MariaDB sürümü (varsa)
- WordPress dizini & wp-config konumu
- Aktif mod (Başlangıç, Standart, Gelişmiş, PRO, ULTRA, Özel)

Ve bu bilgilere göre **öneriler** üretir; örneğin:
- “WooCommerce için RAM düşük görünüyor, en az 4 GB önerilir.”
- “CPU çekirdek sayısı 1, yoğun trafik için ölçeklendirme düşünülebilir.”
- “PHP sürümünüz eski, 8.1+ tavsiye edilir.”

---

### 🧩 Onarım Modları

Betik çalıştığında şu menüyü sunar:

```text
1) Başlangıç Onarımı     (çok güvenli)
2) Standart Onarım       (önerilen)
3) Gelişmiş Onarım       (ileri düzey)
4) PRO Onarım            (performans + güvenlik)
5) ULTRA Onarım          (tüm modüller aktif)
6) Özel / Custom Onarım  (el ile mod seçimi)
```

Her üst seviye, bir önceki seviyedeki modüllerin tamamını içerir ve üzerine ek özellikler getirir.

---

### 1️⃣ Başlangıç Onarımı

En güvenli, temel mod:

- WordPress dizin doğrulama
- Dosya/klsör izinlerini WordPress standartlarına göre düzeltme
- Temel cache temizliği (onaylı)
- `.htaccess` kontrolü ve isteğe bağlı varsayılana sıfırlama
- Eklenti / tema klasör sağlık taraması (bozuk/sahte klasör tespiti)
- Eksik `index.php` tespiti

> Veritabanı yapısını değiştirmez. Yeni başlayanlar için uygundur.

---

### 2️⃣ Standart Onarım

Başlangıç + ek sistem bakımı:

- Veritabanı bağlantı testi
- wp-config optimizasyon önerileri (memory limit, cron vb.)
- FlyingPress klasör/config onarımı
- PHP-FPM / OPcache durum analizi
- WooCommerce temel tablo kontrolleri (var/yok)
- Symlink bozukluklarının temizlenmesi

---

### 3️⃣ Gelişmiş Onarım

Standart + wp-cli tabanlı derin kontroller:

- `wp core verify-checksums`
- `wp plugin verify-checksums --all`
- İsteğe bağlı: `wp plugin update --all`, `wp theme update --all`
- `wp db check` / `wp db repair` (onaylı)
- WooCommerce için REST API testleri ve checkout/sepet endpoint analizleri

---

### 4️⃣ PRO Onarım

Gelişmiş + performans ve güvenlik odaklı modüller:

- Performans testi (TTFB, WP boot time, basit SQL latency, disk IO)
- Basit benchmark ve skor üretimi
- Hafif güvenlik taraması:
  - `base64_decode`, `shell_exec`, `system`, `gzinflate` pattern taraması
  - wp-admin ve wp-includes içinde şüpheli dosya isimleri
- XML-RPC / REST API erişim testi
- WordPress yapılandırma ayarları için öneriler (WP_MEMORY_LIMIT vb.)

---

### 5️⃣ ULTRA Onarım

PRO + tüm “ağır” teşhis motorlarının devreye girdiği mod:

- Geniş kapsamlı log analizi (error_log, debug.log, access log yolu verilirse)
- Basit “AI-lite” hata sınıflandırma (ön tanımlı örüntüler ile)
- Eklenti çakışma analizi (kritik bilinen eşleşmelere bakar, gerçek “otomatik kapatma” yapmaz)
- WooCommerce derin tablo yapısı kontrolü (`wc_order_stats`, `wc_admin_notes` vb.)
- Sunucu tarafında:
  - Swap kullanımı kritik mi?
  - Disk inode kullanımı yüksek mi?
  - TCP bağlantı sayısı ve PHP-FPM havuzlarına olası yük
- Cloudflare için gelişmiş raporlama (API bilgisi verilmişse):
  - Full cache purge (onaylı)
  - Sadece WordPress yolu purge (opsiyonel)
  - Minify / Rocket Loader uyumluluk notları

---

### 6️⃣ Özel / Custom Onarım Modu

Bu modda, kullanıcıya:

- MySQL / DB kontrolleri
- WooCommerce teşhis
- Performans testleri
- Cloudflare işlemleri
- Güvenlik taraması
- wp-cli tabanlı işlemler

gibi modüllerden istediklerini seçme imkânı sunar.  
Böylece sadece ihtiyaç duyduğun alanlarda çalışır ve rapor üretir.

---

## 📊 İstatistik Toplama (Anonim ve İsteğe Bağlı)

WP-Healer ULTRA, isterseniz bazı **anonim metrikleri** bir JSON satır log dosyasına yazabilir:

Toplanan veriler örnek olarak şunlardır:

- Tarih / saat
- Seçilen mod (Başlangıç / Standart / Gelişmiş / PRO / ULTRA / Özel)
- İşletim sistemi adı ve sürümü
- CPU çekirdek sayısı (ör. 2, 4, 8)
- Toplam RAM miktarı (GB cinsinden)
- PHP sürümü
- MySQL/MariaDB sürümü
- WordPress sürümü (wp-cli varsa)
- Aktif eklenti sayısı (wp-cli varsa)
- İşlemin başarılı/başarısız olup olmadığı

**Toplanmayan veriler:**

- IP adresi (betik düzeyinde okunmaz)
- Veritabanı kullanıcı adı/parolası
- Gerçek alan adı (domain), isterseniz anonimleştirilebilir
- Yönetici kullanıcı isimleri, e-postalar, sipariş verileri vb.

Varsayılan olarak bu veriler yerel sunucunuzda:

```text
wp-healer-istatistikler.jsonl
```

dosyasına her satır bir JSON olacak şekilde yazılır.

### İsteğe Bağlı Uzaktan Gönderim (Kendi Sistemine)

Ek olarak, **ISTATISTIK_ENDPOINT** isminde bir ortam değişkeni tanımlarsanız, betik her çalışmada bu verileri JSON POST isteği ile kendi belirlediğiniz API’ye gönderebilir.

Örneğin:

```bash
export ISTATISTIK_ENDPOINT="https://ornek-siten.com/wp-healer-istatistik-alici.php"
./wp-healer-ultra.sh
```

Basit bir PHP alıcı örneği:

```php
<?php
// wp-healer-istatistik-alici.php
$raw = file_get_contents('php://input');
if ($raw) {
    file_put_contents(__DIR__ . '/wp-healer-uzak-log.jsonl', $raw . PHP_EOL, FILE_APPEND);
}
http_response_code(200);
echo "OK";
```

Bu sayede kendi istatistik dosyalarınızı merkezî bir yerde biriktirebilir, sonrasında Excel / Python / Grafana gibi araçlarla analiz edebilirsiniz.

> Betik açık kaynaktır, hangi verilerin gönderildiğini ve nasıl işlendiğini koddan direkt görebilirsiniz.

---

## 📦 Kurulum

```bash
git clone https://github.com/yagzzz/Wordpress-Healer
cd Wordpress-Healer
chmod +x wp-healer.sh
```

---

## ▶ Çalıştırma

```bash
./wp-healer.sh
```

Ardından menüden bir mod seçersiniz.

---

## 🧪 Örnek Çalışma Çıktısı

```text
Sistem Özeti:
- OS: AlmaLinux 8.10
- RAM: 6.6 GB (kullanılabilir ~2.3 GB)
- CPU Çekirdek: 4
- PHP: 8.1.12
- MySQL: 10.6.18-MariaDB
- WordPress dizini: /home/USER/public_html

Öneriler:
- WooCommerce için RAM sınırda, 4+ GB önerilir.
- PHP sürümü uygun, 8.1+ devam edilebilir.
- CPU çekirdek sayısı düşükse yoğun kampanyalarda ölçeklendirme düşünebilirsiniz.

Seçilen mod: ULTRA
→ Dosya izinleri kontrol edildi
→ .htaccess yedeklenip kontrol edildi
→ Cache klasörleri temizlendi (onaylı)
→ Veritabanı bağlantısı test edildi
→ wp-cli ile çekirdek ve eklenti checksum taraması yapıldı
→ WooCommerce tabloları analiz edildi
→ Performans testi yapıldı (TTFB: 170ms, WP Boot: 420ms)
→ Güvenlik taraması tamamlandı (kritik bulunmadı)
→ Cloudflare cache purge isteği gönderildi (onaylı)

Durum: BAŞARILI
```

---

## ⚠ Önemli Uyarı

- Bu betik **hiçbir dosyayı KULLANICI ONAYI OLMADAN silmez**.
- Buna rağmen kullanım öncesi:
  - Dosya yedeği
  - Veritabanı yedeği  
  alınması **şiddetle tavsiye edilir**.
- ULTRA ve PRO modları, sistem hakkında ayrıntılı teşhis yaptığından, öncelikle test/staging ortamında denenmesi iyi bir pratiktir.

---

## 📜 Lisans

Bu proje **MIT Lisansı** ile yayınlanmaktadır.  
Dilediğiniz gibi kullanabilir, değiştirebilir ve dağıtabilirsiniz.
