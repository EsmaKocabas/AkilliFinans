# Akıllı Finans Mobil Uygulaması

## Proje Düzeni

Bu proje artık kök dizinde tek klasör altında tutulur:

- `app/` : Flutter uygulamasının tüm kaynak kodu ve platform klasörleri

## Çalıştırma

1. Flutter kurulumunu tamamla ve `flutter` komutunu PATH'e ekle.
2. VS Code içinde Dart ve Flutter eklentilerini kur.
3. Terminalde proje kökünden uygulama klasörüne geç:

```powershell
cd app
```

4. Bağımlılıkları kur:

```powershell
flutter pub get
```

5. Bağlı cihazları ve emülatörleri kontrol et:

```powershell
flutter devices
flutter emulators
```

6. Emülatörü başlat (örnek):

```powershell
flutter emulators --launch <emulator_id>
```

7. Uygulamayı çalıştır:

```powershell
flutter run
```

Emülatör/cihaz seçerek çalıştırmak için:

```powershell
flutter run -d <device_id>
```

## Doğrulama Komutları

```powershell
flutter --version
where flutter
flutter doctor -v
```

## GitHub Akışı

1. Branch aç ve değişiklikleri o branch'e commit et.
2. PR açıp `main` ile birleştir.