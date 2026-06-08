# 🕌 Namoz Vaqtlari

O'zbekiston foydalanuvchilari uchun maxsus yaratilgan professional darajadagi "Namoz Vaqtlari" mobil ilovasi.

## ✨ Xususiyatlar

- 🕐 **Aniq namoz vaqtlari** - Bomdod, Quyosh, Peshin, Asr, Shom, Xufton
- 📍 **Joylashuv aniqlash** - GPS yoki qo'lda viloyat/tuman tanlash
- 🏛️ **Qibla yo'nalishi** - Kompas yordamida
- 📿 **Tasbeh sanagichi** - Vibratsiya bilan
- 📅 **Haftalik jadval** - 7 kunlik namoz vaqtlari
- 🔔 **Bildirishnomalar** - Namoz vaqtidan oldin va vaqtida
- 💾 **Oflayn ishlash** - Internet bo'lmasa ham saqlangan ma'lumotlar
- 🌙 **Dark/Light Mode** - Yorug' va qorong'i rejimlar
- 🇺🇿 **100% o'zbek tilida**

## 🚀 Texnologiyalar

- **Flutter** (eng so'nggi versiya)
- **Provider** - State management
- **Hive + SharedPreferences** - Mahalliy saqlash
- **flutter_local_notifications** - Bildirishnomalar
- **geolocator** - GPS joylashuv
- **flutter_compass** - Qibla yo'nalishi
- **http** - API bilan ishlash
- **intl + hijri** - Sanalar formati
- **Google Fonts** - Chiroyli shriftlar
- **Material Design 3**

## 📋 Talablar

- **Android**: 10.0+ (API 29+)
- **Dart**: 3.12.1+
- **Flutter**: Eng so'nggi versiya

## 🛠️ O'rnatish

```bash
# Paketlarni o'rnatish
flutter pub get

# Lokalizatsiya kodini generatsiya qilish (ixtiyoriy)
flutter gen-l10n

# Build qilish
flutter build apk --release
```

## 📁 Loyiha tuzilmasi

```
lib/
├── main.dart                      # Ilovaning kirish nuqtasi
├── app.dart                       # MaterialApp konfiguratsiyasi
├── core/
│   ├── constants/                 # Konstanatalar (ranglar, matnlar, viloyatlar)
│   ├── models/                    # Ma'lumotlar modellari
│   ├── providers/                 # State management
│   └── services/                  # API, saqlash, bildirishnomalar
├── features/
│   ├── about/                     # Ilova haqida sahifasi
│   ├── home/                      # Bosh sahifa
│   ├── onboarding/                # Ruxsatlarni so'rash
│   ├── qibla/                     # Qibla yo'nalishi
│   ├── settings/                  # Sozlamalar
│   ├── tasbeh/                    # Tasbeh sanagichi
│   └── weekly/                    # Haftalik jadval
└── shared/
    └── widgets/                   # Umumiy widgetlar
```

## 🔧 API Integratsiyasi

API manzilni `lib/core/services/api_service.dart` faylidagi `_baseUrl` o'zgaruvchisiga o'rnating:

```dart
static const String _baseUrl = 'https://sizning-api.com/v1';
```

Hozirda fallback sifatida **Aladhan API** va **Pray.zone** ishlatilmoqda.

## 🔐 Ruxsatlar

- `INTERNET` - API bilan ishlash
- `ACCESS_FINE_LOCATION` - GPS orqali joylashuv
- `POST_NOTIFICATIONS` - Bildirishnomalar
- `SCHEDULE_EXACT_ALARM` - Aniq budilnik
- `RECEIVE_BOOT_COMPLETED` - Telefon qayta yoqilganda
- `VIBRATE` - Vibratsiya
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` - Batareya optimallashtirishni o'chirish

## 📱 Ekranlar

1. **Bugun** - Bugungi namoz vaqtlari, keyingi namozgacha qolgan vaqt
2. **Haftalik** - 7 kunlik namoz jadvali
3. **Qibla** - Kompas bilan Qibla yo'nalishi
4. **Tasbeh** - Tasbeh sanagichi
5. **Sozlamalar** - Mavzu, bildirishnomalar, hisoblash usuli
6. **Ilova haqida** - Ilova ma'lumotlari

## 👨‍💻 Muallif

Namoz Vaqtlari jamoasi © 2025

## 📄 Litsenziya

Bu ilova Maxsus litsenziya asosida tarqatiladi.
