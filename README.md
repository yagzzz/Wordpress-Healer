# WP-Healer ULTRA+ (Türkçe)
Modüler WordPress Onarım, Teşhis ve Optimizasyon Aracı

Bu proje; WordPress, WooCommerce ve sunucu ortamlarını derinlemesine analiz edip hataları kullanıcı onayıyla güvenli biçimde düzelten tam kapsamlı bir CLI aracıdır.

## 🚀 Özellikler (Güncellenmiş ULTRA+ Sürümü)
- **Modüler mimari** (modules/ & utils/)
- **Gelişmiş terminal arayüzü** (renkli, bölümlü)
- **Etiket sistemi:** (ÖNERİLİR), (GEREKLİ), (RİSKLİ), (OPSİYONEL), (İLERİ SEVİYE)
- **Auto-Heal sistemi** (düşük riskli işlemleri otomatik çözen mekanizma)
- **Log sistemi** (her çalışmada ayrı klasör ve istatistik JSON)
- **Anonim sistem istatistik toplayıcı** (IP veya kişisel veri toplamaz)
- **Custom mod seçici** (istediğin modları seçip yalnızca onları çalıştırır)

## 📂 Klasör Yapısı
```
wp-healer/
│
├─ wp-healer.sh
│
├─ modules/
│   ├─ system.sh
│   ├─ wp-core.sh
│   ├─ filesystem.sh
│   ├─ db.sh
│   ├─ woo.sh
│   ├─ wpcli.sh
│   ├─ perf.sh
│   ├─ security.sh
│   ├─ cloudflare.sh
│   └─ custom.sh (gerekirse)
│
├─ utils/
│   ├─ colors.sh
│   ├─ logging.sh
│   ├─ prompts.sh
│
└─ logs/
    └─ (otomatik oluşturulur)
```

## 🔧 Modlar
Her mod bir öncekini içerir.

### 1️⃣ Başlangıç Modu (çok güvenli)
- Dosya izin düzeltme  
- .htaccess onarım  
- Cache temizleme  
- Plugin/Tema sağlık taraması  

### 2️⃣ Standart Mod
+ Veritabanı bağlantı testi  
+ wp-config optimizasyon önerileri  
+ WooCommerce temel tablo kontrolü  

### 3️⃣ Gelişmiş Mod
+ wp-cli DB repair  
+ WooCommerce gelişmiş kontroller  
+ Woo cron analizi  

### 4️⃣ PRO Mod
+ wp-cli çekirdek/e­klenti doğrulama  
+ wp-cli otomatik çekirdek onarım önerisi  
+ Performans testi  
+ PHP-FPM optimizasyon önerileri  
+ Güvenlik taraması  

### 5️⃣ ULTRA+ Mod (En kapsamlı)
+ Tüm PRO özellikleri  
+ Log analizi  
+ Kapasite öneri raporu  
+ Cloudflare API modülü  

### 6️⃣ Özel / Custom Mod
Kullanıcı hangi modüllerin çalışacağını kendisi seçer.

## 🧠 Toplanan İstatistikler (Anonim)
Aşağıdaki bilgiler toplanır:

- OS adı ve sürümü  
- CPU çekirdek sayısı  
- RAM miktarı  
- PHP sürümü  
- MySQL sürümü  
- WordPress sürümü  
- Eklenti sayısı  
- Çalıştırılan mod  
- Başarı-durum bilgisi  

**Toplanmayan veriler:**  
❌ IP adresi  
❌ Domain  
❌ Kullanıcı adı  
❌ Şifre  
❌ Sunucu özel kimlik bilgileri  

Kod tamamen açık kaynaktır ve istatistik dosyası (`wp-healer-istatistik.json`) kullanıcı tarafından görülebilir.

## 📦 Kurulum
```
git clone https://github.com/kullanici/wp-healer
cd wp-healer
chmod +x wp-healer.sh
```

## ▶️ Çalıştırma
```
./wp-healer.sh
```

## 📑 Log ve Raporlama
Her çalıştırmada:

```
logs/2025-12-04_14-55-33/
 ├─ wp-healer-output.log
 └─ wp-healer-istatistik.json
```

## ⚠️ Uyarı
Bu araç bir şey silmez, değiştirme yapmadan önce her zaman **kullanıcı onayı ister**.  
Yine de öneri:  
**Dosya ve veritabanı yedeği almadan kullanmayın.**

## 📜 Lisans
MIT Lisansı  
Bu araç özgür ve açık kaynaklıdır. Değiştirilebilir, dağıtılabilir.
