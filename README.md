# 📈 RSI_EMA_CLRDMA_EA_V5 (MetaTrader 5 Expert Advisor)

![Platform](https://img.shields.io/badge/Platform-MetaTrader%205-green)
![Language](https://img.shields.io/badge/Language-MQL5-blue)
![Version](https://img.shields.io/badge/Version-5.0-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**RSI_EMA_CLRDMA_EA_V5**, çoklu teknik göstergeleri (RSI, EMA, CLRDMA) ve özel fiyat formasyonlarını (Flat Top/Bottom) birleştirerek trend takibi yapan gelişmiş bir algoritmik alım-satım robotudur. 

Bu sistem, sadece işlem açmaya değil, **Risk Yönetimi** (günlük zarar limiti, işlem sınırı) ve **Dinamik Stop Loss** (ZigZag) mekanizmalarıyla sermayeyi korumaya odaklanır.

## 🚀 Özellikler

* **Trend Takibi:** Kısa ve Uzun vadeli Üstel Hareketli Ortalamalar (EMA) ile ana trend yönünü belirler.
* **Momentum Analizi (CLRDMA):** Özelleştirilmiş Lineer Göreceli Ortalama Farkı (CLRDMA) ile trendin gücünü doğrular.
* **Gürültü Filtreleme:** `Flat Top` ve `Flat Bottom` algoritmaları sayesinde yatay (konsolidasyon) piyasalarda hatalı işlem açılmasını engeller.
* **Dinamik Stop Loss:** Statik pip değeri yerine, **ZigZag** indikatörünü kullanarak son destek/direnç seviyelerine göre Stop Loss belirler.
* **Günlük Risk Yönetimi:**
    * `MaxTradesPerDay`: Günlük maksimum işlem sayısını sınırlar.
    * `MaxDailyLoss`: Günlük maksimum parasal zararı sınırlar.
* **Raporlama:** İşlemleri ve sinyal değerlerini (RSI, EMA, CLRDMA) detaylı olarak loglar.

## 🧠 Strateji Mantığı

EA, her yeni mum (bar) açılışında piyasayı analiz eder ve aşağıdaki koşullar sağlandığında işlem açar:

### 🟢 Alış (Long) Sinyali
1.  **Trend:** Hızlı EMA (8), Yavaş EMA'nın (21) **üzerinde** olmalı.
2.  **Momentum:** CLRDMA değeri **0'dan büyük** (pozitif) olmalı.
3.  **Formasyon:** Son 3 barda `Flat Bottom` (Yatay Dip) formasyonu oluşmalı.

### 🔴 Satış (Short) Sinyali
1.  **Trend:** Hızlı EMA (8), Yavaş EMA'nın (21) **altında** olmalı.
2.  **Momentum:** CLRDMA değeri **0'dan küçük** (negatif) olmalı.
3.  **Formasyon:** Son 3 barda `Flat Top` (Yatay Tepe) formasyonu oluşmalı.

### 🛡️ Çıkış ve Risk Yönetimi
* **Stop Loss (SL):** Eğer `UseZigZagSL` aktifse, son ZigZag dip/tepe noktası SL olarak atanır. Değilse statik `StopLoss` puanı kullanılır.
* **Take Profit (TP):** `RiskRewardRatio` (Örn: 2.0) kullanılarak SL mesafesinin katı kadar TP belirlenir.
* **Güvenlik:** Günlük zarar limiti veya işlem sayısı dolarsa, o gün için yeni işlem açılması engellenir.

## 🛠️ Kurulum

1.  **Dosyaları İndirin:** Bu repodaki `.mq5` dosyasını indirin.
2.  **Klasöre Taşıyın:** Dosyayı `MetaTrader 5 -> MQL5 -> Experts` klasörüne atın.
3.  **ZigZag Gereksinimi:** EA, `Examples/ZigZag` indikatörünü kullanır. MT5'inizde bu indikatörün `MQL5/Indicators/Examples/ZigZag.ex5` yolunda olduğundan emin olun (Standart MT5 kurulumunda gelir).
4.  **Derleme:** MetaEditor'ü açın (F4), dosyayı açın ve **Compile (F7)** butonuna basın.
5.  **Çalıştırma:** MT5 terminalinde **USDJPY** paritesini ve **M15** zaman dilimini açın. EA'yı grafiğe sürükleyin.

## ⚙️ Parametreler (Inputs)

| Parametre | Varsayılan | Açıklama |
| :--- | :--- | :--- |
| **rsiPeriod** | 14 | RSI indikatör periyodu (İzleme amaçlı) |
| **emaFastPeriod** | 8 | Kısa vadeli trend için EMA periyodu |
| **emaSlowPeriod** | 21 | Uzun vadeli trend için EMA periyodu |
| **UseCLRDMA** | true | CLRDMA momentum filtresini aktif eder |
| **clrFastPeriod** | 5 | CLRDMA hesaplaması için hızlı periyot |
| **clrSlowPeriod** | 20 | CLRDMA hesaplaması için yavaş periyot |
| **LotSize** | 0.1 | İşlem hacmi (Lot) |
| **RiskRewardRatio** | 2.0 | Risk/Kazanç oranı (TP hesaplaması için) |
| **UseZigZagSL** | true | SL'yi ZigZag seviyelerine göre belirle |
| **MaxTradesPerDay** | 5 | Bir günde açılacak maksimum işlem sayısı |
| **MaxDailyLoss** | 100.0 | Günlük maksimum zarar limiti ($) |

## 📊 Test Sonuçları (Özet)

Teknik raporda belirtilen **USDJPY M15** testlerinde:
* **Görsel Mod:** Grafik üzerinde trend dönüşlerinde (EMA Cross) ve momentum onaylarında (CLRDMA) doğru girişler gözlemlenmiştir.
* **Risk Yönetimi:** Günlük limitlere ulaşıldığında sistemin otomatik olarak durduğu doğrulanmıştır.
* **Filtreleme:** Yatay piyasalarda `Flat Top/Bottom` tespiti sayesinde hatalı sinyallerin elendiği görülmüştür.

## 🤝 Katkıda Bulunma

Geliştirmeye açık alanlar (V6 için planlananlar):
* [ ] Trailing Stop (İz süren stop) eklenmesi.
* [ ] Haber filtresi entegrasyonu.
* [ ] Hedging desteği.

Katkıda bulunmak için Fork yapıp Pull Request gönderebilirsiniz.

## 📄 Lisans

Bu proje MIT lisansı ile lisanslanmıştır.
