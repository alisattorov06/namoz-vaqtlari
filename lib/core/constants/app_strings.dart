class AppStrings {
  // App
  static const String appName = 'Namoz Vaqtlari';
  static const String appTagline = "O'zbekiston uchun namoz vaqtlari";

  // Navigation
  static const String navHome = 'Asosiy';
  static const String navWeekly = 'Haftalik';
  static const String navQibla = 'Qibla';
  static const String navTasbeh = 'Tasbeh';
  static const String navSettings = 'Sozlamalar';

  // Prayer names
  static const String bomdod = 'Bomdod';
  static const String quyosh = 'Quyosh';
  static const String peshin = 'Peshin';
  static const String asr = 'Asr';
  static const String shom = 'Shom';
  static const String xufton = 'Xufton';

  // Prayer descriptions
  static const String bomdodDesc = 'Tong namozi';
  static const String quyoshDesc = 'Quyosh chiqishi';
  static const String peshinDesc = 'Peshin namozi';
  static const String asrDesc = 'Asr namozi';
  static const String shomDesc = 'Shom namozi';
  static const String xuftonDesc = 'Xufton namozi';

  // Home
  static const String nextPrayer = 'Keyingi namoz';
  static const String todayPrayers = "Bugungi namoz vaqtlari";
  static const String passed = "O'tib ketdi";
  static const String active = 'Hozir';
  static const String remaining = 'qoldi';
  static const String hour = 'soat';
  static const String minute = 'daqiqa';
  static const String second = 'soniya';

  // Weekly
  static const String weeklySchedule = 'Haftalik jadval';
  static const String today = 'Bugun';
  static const String tomorrow = 'Ertaga';

  // Qibla
  static const String qiblaTitle = 'Qibla yo\'nalishi';
  static const String qiblaDescription = 'Makkaga yo\'nalish';
  static const String qiblaSearching = 'Qibla topilmoqda...';
  static const String qiblaFound = 'Qibla topildi';
  static const String compassNotAvailable = 'Kompas mavjud emas';

  // Tasbeh
  static const String tasbehTitle = 'Tasbeh';
  static const String tasbehCount = 'son';
  static const String tasbehReset = 'Qayta boshlash';
  static const String tasbehVibration = 'Vibratsiya';
  static const String subhanallah = 'Subhanallah';
  static const String alhamdulillah = 'Alhamdulillah';
  static const String allahuakbar = 'Allahu Akbar';

  // Settings
  static const String settingsTitle = 'Sozlamalar';
  static const String locationSettings = 'Joylashuv';
  static const String gpsLocation = 'GPS orqali aniqlash';
  static const String manualLocation = "Qo'lda tanlash";
  static const String selectRegion = 'Viloyat tanlang';
  static const String selectDistrict = 'Tuman tanlang';
  static const String notificationSettings = 'Bildirishnomalar';
  static const String alarmSettings = 'Alarmlar';
  static const String alarmSound = 'Alarm ovozi';
  static const String themeSettings = 'Dizayn';
  static const String darkMode = 'Qorong\'u rejim';
  static const String lightMode = 'Yorug\' rejim';
  static const String systemMode = 'Tizim sozlamasi';
  static const String language = 'Til';
  static const String uzbek = "O'zbek";

  // Notifications
  static const String notifBefore5 = '5 daqiqa oldin';
  static const String notifAtTime = 'Vaqt kirganda';
  static const String notifBeforeMsg = 'namoziga 5 daqiqa qoldi. Namozga shoshiling!';
  static const String notifAtMsg = 'namozi vaqti kirdi.';

  // About
  static const String aboutTitle = 'Ilova haqida';
  static const String version = 'Versiya';
  static const String developer = 'Ishlab chiquvchi';
  static const String purpose = 'Maqsad';
  static const String purposeText =
      "Bu ilova O'zbekiston musulmonlariga namoz vaqtlarini to'g'ri va o'z vaqtida aniqlashda yordam berish uchun yaratilgan.";

  // Permissions
  static const String permTitle = 'Ruxsatlar';
  static const String permSubtitle =
      'Ilovadan to\'liq foydalanish uchun quyidagi ruxsatlarni bering';
  static const String permLocation = 'Joylashuv';
  static const String permLocationDesc =
      'Sizning joylashuvingizga qarab namoz vaqtlarini aniqlash uchun';
  static const String permNotification = 'Bildirishnomalar';
  static const String permNotificationDesc =
      'Namoz vaqtlari haqida eslatmalar olish uchun';
  static const String permAlarm = 'Aniq vaqt rejimi';
  static const String permAlarmDesc =
      'Namoz vaqtlarida aniq signal berish uchun';
  static const String permBattery = 'Fon rejimi';
  static const String permBatteryDesc =
      "Ilova yopiq bo'lganda ham bildirishnomalar ishlashi uchun";
  static const String permGrant = 'Ruxsat berish';
  static const String permSkip = "O'tkazib yuborish";
  static const String permContinue = 'Davom etish';
  static const String permGranted = 'Berildi';

  // Errors
  static const String errorNoInternet = 'Internet aloqasi yo\'q';
  static const String errorLoading = 'Yuklashda xatolik';
  static const String errorLocation = 'Joylashuv aniqlanmadi';
  static const String errorTryAgain = 'Qayta urinib ko\'ring';
  static const String cachedData = "Saqlangan ma'lumotlar ko'rsatilmoqda";

  // Days of week
  static const List<String> weekdays = [
    'Dushanba',
    'Seshanba',
    'Chorshanba',
    'Payshanba',
    'Juma',
    'Shanba',
    'Yakshanba',
  ];

  // Months
  static const List<String> months = [
    'Yanvar',
    'Fevral',
    'Mart',
    'Aprel',
    'May',
    'Iyun',
    'Iyul',
    'Avgust',
    'Sentabr',
    'Oktabr',
    'Noyabr',
    'Dekabr',
  ];

  // Hijri months
  static const List<String> hijriMonths = [
    'Muharram',
    'Safar',
    'Rabiul Avval',
    'Rabiul Oxir',
    'Jumadil Avval',
    'Jumadil Oxir',
    'Rajab',
    "Sha'bon",
    'Ramazon',
    'Shavvol',
    "Zul-Qa'da",
    'Zul-Hijja',
  ];
}
