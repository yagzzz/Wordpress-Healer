# 📘 WP-Healer PRO+ (Türkçe Sürüm)
### **WordPress Otomatik Onarım ve Optimizasyon Aracı**
**Başlangıç • Standart • Gelişmiş • Gelişmiş+** modları ile tam koruma sağlar.

WP-Healer PRO+, WordPress kurulumlarında karşılaşılan hataları otomatik olarak algılayan ve her adımda kullanıcıya sorarak güvenli şekilde düzelten gelişmiş bir onarım betiğidir.

WordPress yolunu otomatik bulur, wp-config dosyasından veritabanı bilgilerini çıkarır, WooCommerce ve önbellek eklentisi sorunlarını tespit eder ve kullanıcı onayına bağlı olarak düzeltir.

---

## 📂 **Klasör Yapısı (Türkçe)**

Proje şu şekilde düzenlenmiştir:

```
wp-healer/
│
├─ wp-healer.sh          # Ana betik
├─ README.md             # Bu dosya
├─ LISANS                # MIT Lisansı (Türkçe açıklama)
│
├─ varliklar/            # Görsel, ikon vb. dosyalar
│   └─ terminal-goruntu.png
│
└─ ornekler/             # Örnek çıktı ve log kayıtları
    └─ ornek-log.txt
```

> “assets” yerine **varliklar**, “examples” yerine **ornekler** klasörü kullanılır.  
> Tamamen Türkçe proje standardına uygun şekilde düzenlenmiştir.

---

# 🚀 **Öne Çıkan Özellikler**

## 🎯 **Otomatik Tespit**
- WordPress kurulum yolunu otomatik bulur  
- wp-config içinden DB bilgilerini güvenle okur  
- Dosya izinlerini tarar  
- Bozuk ya da eksik `.htaccess` dosyasını düzeltir  
- WordPress dosya bütünlüğünü inceler  
- Eklenti ve tema klasörlerinin sağlığını kontrol eder  
- Bozuk symlink tespiti  
- Eksik `index.php` dosyası kontrolü  

---

## 🚀 **Önbellek & Cache Analizi**
- Birden fazla cache eklentisi çakışmasını tespit eder  
- FlyingPress yapılandırma onarımı  
- LiteSpeed, WP Rocket, Autoptimize, W3TC taraması  
- `wp-content/cache` temizliği (kullanıcı onayıyla)  

---

## 🛒 **WooCommerce Destek**
- `wc_sessions`, `wc_orders`, `wc_cart` tablolarını kontrol eder  
- WooCommerce sepet & checkout hatalarını tespit eder  
- REST API `/cart` testleri  
- Cart Fragments kontrolü  

---

## ⚙️ **Veritabanı İşlemleri**
- DB bağlantı testi  
- wp-cli ile tablo onarımı (isteğe bağlı)  
- `wp db check`  
- `wp db repair`  

---

## ☁️ **Cloudflare Entegrasyonu (PRO+ Modunda)**
- Tüm cache temizleme  
- APO durumu sorgulama  
- Minify ve Rocket Loader kontrolleri  
- Güvenlik seviyesi önerisi  

---

# 🧩 **Onarım Modları**

Betik çalıştığında aşağıdaki menü sunulur:

### 🟢 **1) Başlangıç Onarımı**
En güvenli, risksiz onarım türüdür:

- WordPress dizin doğrulama  
- Dosya izinleri düzeltme  
- Temel cache temizliği  
- `.htaccess` tamiri (sorarak)  
- Eklenti / tema klasör sağlık taraması  
- Eksik `index.php` kontrolü  

> Veritabanına dokunmaz.  
> Yeni kullanıcılar için **tavsiye edilir**.

---

### 🟡 **2) Standart Onarım**

Başlangıç + ek sistem tamiri:

- Veritabanı bağlantı testi  
- wp-config optimizasyonu (memory limit, cron)  
- FlyingPress klasör/config onarımı  
- PHP-FPM yük kontrolü  
- WooCommerce temel tabloları kontrol  
- Symlink temizleme  

---

### 🔥 **3) Gelişmiş Onarım**

Standart + daha derin analiz:

#### ✔ wp-cli doğrulama ve güvenlik
- `wp core verify-checksums`
- `wp plugin verify-checksums`
- `wp plugin update --all`
- `wp theme update --all`

#### ✔ Veritabanı Gelişmiş Onarım
- `wp db check`
- `wp db repair`

#### ✔ WooCommerce Pro Testleri
- Sepet API testleri  
- Checkout 500 hata simülasyonu  
- Cart Fragments AJAX testi  

---

# 🧨 **4) Gelişmiş+ Onarım (PRO+)**

En kapsamlı moddur. Gelişmiş mod + ekstra analizler içerir.

### 🔍 Gelişmiş Malware Tarayıcı
- `base64_decode`
- `shell_exec`
- `system()`
- `gzinflate`
> Bu test yalnızca raporlar, **hiçbir dosyayı silmez**.

### ☁ Cloudflare API İşlemleri
- Full cache temizleme  
- APO durumu sorgulama  
- Minify & Rocket Loader uyumluluk kontrolü  

### 🧪 SSH & Sistem Analizi
- ping testi  
- disk kullanımı  
- uptime bilgisi  
- CPU yükü  

---

# 📦 **Kurulum**

```bash
git clone https://github.com/yagzzz/Wordpress-Healer
chmod +x wp-healer.sh
```

---

# ▶ **Çalıştırma**

```bash
./wp-healer.sh
```

---

# 🧪 **Örnek Çalışma Çıktısı**

```
WordPress dizini bulundu: /home/site/public_html
DB bağlantısı başarılı
Önbellek eklentileri taranıyor...
FlyingPress config onarımı başarılı
WooCommerce tabloları kontrol edildi
wp-cli bulundu, gelişmiş işlemler aktif
İşlem tamamlandı: Gelişmiş+ Modu
```

---

# ⚠ **Önemli Uyarı**

Bu betik **hiçbir dosyayı KULLANICI ONAYI OLMADAN silmez**.  
Yine de kullanım öncesi:

- ✔ Dosya yedeği  
- ✔ Veritabanı yedeği  

alınması tavsiye edilir.

---

# 📜 **Lisans**

Bu proje **MIT Lisansı** ile sunulmaktadır.  
Dilediğiniz gibi kullanabilir, değiştirebilir ve dağıtabilirsiniz.
