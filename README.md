📘 WP-Healer PRO+ (Türkçe Sürüm)
WordPress Otomatik Onarım ve Optimizasyon Aracı
Başlangıç • Standart • Gelişmiş • Gelişmiş+ Modları ile tam koruma
WP-Healer PRO+, WordPress kurulumlarında karşılaşılan hataları otomatik olarak algılayan ve her adımda kullanıcıya sorarak güvenli şekilde düzelten gelişmiş bir onarım betiğidir.
WordPress yolunu otomatik bulur, wp-config dosyasından veritabanı bilgilerini çıkarır, WooCommerce ve önbellek eklentisi sorunlarını tespit eder ve kullanıcı onayına bağlı olarak düzeltir.



📂 Klasör Yapısı (Türkçe)
Proje şu şekilde düzenlenmiştir:

wp-healer/
wp-healer.sh                # Ana betik
README.md                   # Bu dosya
LISANS                      # MIT Lisansı (Türkçe açıklama)
varliklar/                  # Görsel, ikon vb. dosyalar
terminal-goruntu.png
ornekler/                   # Örnek çıktı ve log kayıtları
    └─ ornek-log.txt


Not: “assets” yerine varlıklar, “examples” yerine örnekler klasörü kullanılır.
Tamamen Türkçe proje standardına uygun şekilde düzenlenmiştir.



🚀 Öne Çıkan Özellikler
🎯 Otomatik Tespit
WordPress kurulum yolunu otomatik bulur
wp-config içinden DB bilgilerini güvenle okur
Dosya izinlerini tarar
Bozuk ya da eksik .htaccess’i düzeltir
WordPress dosya bütünlüğünü inceler
Eklenti ve tema klasörlerinin sağlığını kontrol eder
Bozuk symlink tespiti
Eksik index.php dosyası kontrolü



🚀 Önbellek & Cache Analizi
Birden fazla cache eklentisi çakışmasını tespit eder
FlyingPress yapılandırma onarımı
LiteSpeed, WP Rocket, Autoptimize, W3TC taraması
wp-content/cache temizliği (izinli)



🛒 WooCommerce Destek
wc_sessions, wc_orders, wc_cart tablolarını kontrol eder
WooCommerce sepet & checkout hatalarını tespit eder
REST API /cart testleri
Cart Fragments kontrolü
⚙ Veritabanı İşlemleri
DB bağlantı testi
wp-cli ile tablo onarımı (isteğe bağlı)
wp db check
wp db repair
☁ Cloudflare Entegrasyonu (PRO+ Modunda)
Tüm cache temizleme
APO, minify, Rocket Loader kontrolleri
Güvenlik seviyesi önerisi



🧩 Onarım Modları
Betik çalıştığında aşağıdaki menü sunulur:
1) Başlangıç Onarımı     (çok güvenli)
2) Standart Onarım       (önerilen)
3) Gelişmiş Onarım       (ileri düzey)
4) Gelişmiş+ Onarım      (tam kapsamlı)


🟢 1) Başlangıç Onarımı
En güvenli, risksiz onarım türüdür:
WordPress dizin doğrulama
Dosya izinleri düzeltme
Temel cache temizliği
.htaccess tamiri (sorarak)
Plugin / tema klasör sağlık taraması
Eksik index.php kontrolü
Veritabanına dokunmaz.
Yeni kullanıcılar için tavsiye edilir.


🟡 2) Standart Onarım
Başlangıç + ek sistem tamiri:
Veritabanı bağlantı testi
wp-config optimizasyonu (memory limit, cron)
FlyingPress klasör/config onarımı
PHP-FPM yük kontrolü
WooCommerce temel tabloları kontrol
Symlink temizleme
WooCommerce mağazaları ve aktif siteler için ideal.


🔥 3) Gelişmiş Onarım
Standart + wp-cli tabanlı derin analiz:
✔ wp-cli doğrulama ve güvenlik
wp core verify-checksums
wp plugin verify-checksums
wp plugin update --all (isteğe bağlı)
wp theme update --all (isteğe bağlı)
✔ Veritabanı Gelişmiş Onarım
wp db check
wp db repair
✔ WooCommerce Pro Testleri
sepet API testleri
checkout 500 hata simülasyonu
fragments AJAX testi
Geliştiriciler için özel mod.


🧨 4) Gelişmiş+ Onarım (PRO+)
En kapsamlı moddur.
Gelişmiş mod + ekstra analizler:



🔍 Gelişmiş Malware Tarayıcı
base64_decode
shell_exec
system()
gzinflate
→ Sadece raporlar, silmez.
☁ Cloudflare API İşlemleri
Tüm site cache temizleme
APO durumu sorgulama
Minify ve Rocket Loader uyumluluk analizi



🧪 SSH & Sistem Analizi
ping testi
disk kullanımı
uptime
CPU yükü
Bu mod WordPress, WooCommerce ve sunucu düzeyinde tam kapsamlı teşhis sunar.



📦 Kurulum
git clone https://github.com/yagzzz/Wordpress-Healer
chmod +x wp-healer.sh



▶ Çalıştırma
./wp-healer.sh



🧪 Örnek Çalışma Çıktısı
WordPress dizini bulundu: /home/site/public_html
DB bağlantısı başarılı
Önbellek eklentileri taranıyor...
FlyingPress config onarımı başarılı
WooCommerce tabloları kontrol edildi
wp-cli bulundu, gelişmiş işlemler aktif
İşlem tamamlandı: Gelişmiş+ Modu



⚠ Önemli Uyarı
Bu betik hiçbir dosyayı KULLANICI ONAYI OLMADAN silmez.
Yine de kullanım öncesi:
✔ Dosya yedeği
✔ Veritabanı yedeği
alınması tavsiye edilir.



📜 Lisans
Bu proje MIT Lisansı ile sunulmaktadır.
Dilediğiniz gibi kullanabilir, değiştirebilir ve dağıtabilirsiniz.
