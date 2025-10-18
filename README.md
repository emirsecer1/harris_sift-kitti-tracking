# harris_sift-kitti-tracking
Harris corner detection and feature tracking on KITTI  Raw dataset using MATLAB
# KITTI  - Harris Corner Detection & Feature Tracking

## 📋 Proje Özeti

Bu proje, KITTI veri setinde **Harris köşe algılama** ve **özellik izleme** işlemlerini gerçekleştirmektedir. Proje, bilgisayarlı görü ve otonom araç uygulamalarında temel olan özellik çıkarma ve izleme tekniklerini göstermektedir.

## 🎯 Amaçlar

1. **Harris Köşe Algılayıcısı** uygulamak
2. Zaman içinde **özellik noktalarını izlemek**
3. **Patch tabanlı** ve **SIFT tanımlayıcılar** ile izleme yapmak
4. KITTI veri setinde performans analizi yapmak
5. Sonuçları görselleştirmek ve raporlamak

## 📁 Dosya Yapısı

```
project/
│
├── harris_main.m              # Ana çalışma scripti
├── harris_detector.m      # Harris köşe algılama fonksiyonu
├── feature_tracker.m            # Patch tabanlı izleme fonksiyonu
├── trackFeaturesSIFT.m        # SIFT tabanlı izleme (opsiyonel)
├── analysis_report.m   # Rapor oluşturma fonksiyonu
├── test_demo.m                # Test ve demo scripti
└── README.md                  # Bu dosya
```

## 🛠️ Gereksinimler

### MATLAB Versiyonu
- MATLAB R2019b veya üzeri (önerilir)

### Gerekli Toolbox'lar
- **Image Processing Toolbox** (zorunlu)
- **Computer Vision Toolbox** (SIFT kullanımı için opsiyonel)

### Veri Seti
- **KITTI Raw Dataset**
  - İndirme linki: http://www.cvlibs.net/datasets/kitti/raw_data.php
  - Sequence 00 veya herhangi bir sequence kullanılabilir
  - Minimum 200 kare gereklidir

## 📥 Kurulum

### 1. KITTI Veri Setini İndirin

```bash
# KITTI web sitesinden gray scale image sequences indirin
# Örnek dizin yapısı:
KITTI/
└── sequences/
    └── 00/
        ├── image_0/
        │   ├── 000000.png
        │   ├── 000001.png
        │   └── ...
        └── image_1/
```

### 2. MATLAB Dosyalarını Yerleştirin

Tüm `.m` dosyalarını aynı dizine koyun veya MATLAB path'e ekleyin.

### 3. Veri Yolunu Ayarlayın

`harris_main.m` dosyasında `dataPath` değişkenini düzenleyin:

```matlab
dataPath = 'C:/KITTI/sequences/00/image_0/';  % Kendi yolunuzu yazın
```

## 🚀 Kullanım

### Hızlı Başlangıç (Test Modu)

KITTI veri seti olmadan test etmek için:

```matlab
% test_demo.m dosyasını çalıştırın
test_demo
```

Bu, sentetik görüntüler üzerinde Harris algılama ve tracking'i test edecektir.

### Ana Proje Çalıştırma

```matlab
% harris_main.m dosyasını çalıştırın
harris_main
```

veya

```matlab
% test_demo.m içinde mod 2'yi seçin
testMode = 2;
test_demo
```

