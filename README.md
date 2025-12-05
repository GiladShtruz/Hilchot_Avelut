<div align="center">

# 📖 הלכות אבלות

**אפליקציית Flutter להצגת ספר הלכות אבלות**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://flutter.dev)

<img src="screenshots/home.png" width="250" alt="Home Screen">

</div>

---

## ✨ תכונות

- 📚 **תוכן עניינים** - ניווט קל בין פרקי הספר
- 🔍 **חיפוש מהיר** - חיפוש טקסט בכל תוכן הספר עם הדגשת תוצאות
- ⭐ **מועדפים** - שמירת סימניות עם מיקום מדויק (scroll position)
- 💾 **שמירת מצב** - האפליקציה זוכרת את המיקום האחרון בכל פרק
- 🎨 **עיצוב RTL** - תמיכה מלאה בעברית וכיוון מימין לשמאל
- 📱 **תצוגה נוחה** - הצגת HTML עם עיצוב מותאם לקריאה

---

## 🖼️ צילומי מסך

<div align="center">
<table>
  <tr>
    <td align="center"><img src="screenshots/home.png" width="200"><br><b>עמוד ראשי</b></td>
    <td align="center"><img src="screenshots/reader.png" width="200"><br><b>קריאה</b></td>
    <td align="center"><img src="screenshots/search.png" width="200"><br><b>חיפוש</b></td>
    <td align="center"><img src="screenshots/favorites.png" width="200"><br><b>מועדפים</b></td>
  </tr>
</table>
</div>

---

## 🏗️ ארכיטקטורה

הפרויקט בנוי לפי עקרונות Clean Architecture:

```
lib/
├── main.dart                     # Entry point
├── app.dart                      # App configuration
├── config/
│   ├── constants.dart            # App constants
│   └── theme.dart                # Theme & styling
├── data/
│   └── chapters_data.dart        # Static chapters data
├── models/
│   ├── chapter.dart              # Chapter model
│   ├── favorite.dart             # Favorite bookmark model
│   └── reading_position.dart     # Reading position model
├── services/
│   ├── storage_service.dart      # Hive local storage
│   └── search_service.dart       # Search functionality
├── providers/
│   ├── favorites_provider.dart   # Favorites state management
│   └── reading_provider.dart     # Reading state management
├── screens/
│   ├── main_screen.dart          # Main screen with navigation
│   ├── home/                     # Home screen
│   ├── search/                   # Search screen
│   ├── favorites/                # Favorites screen
│   └── reader/                   # HTML reader screen
└── widgets/
    ├── common/                   # Shared widgets
    ├── chapter_list_item.dart
    ├── favorite_list_item.dart
    └── search_result_item.dart
```

---

## 🛠️ טכנולוגיות

| טכנולוגיה | שימוש |
|-----------|-------|
| **Flutter** | Framework |
| **Provider** | State Management |
| **Hive** | Local Storage |
| **WebView** | HTML Rendering |

---

## 🚀 התקנה

### דרישות מקדימות

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Android SDK (לאנדרואיד)
- Xcode (ל-iOS)

### שלבי התקנה

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/evelut_halacha.git
cd evelut_halacha
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Build for production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 📄 הוספת תוכן חדש

### הוספת פרק חדש

1. **הוסף קובץ HTML** לתיקייה `assets/html/`:
```
assets/html/chapter_2.html
```

2. **עדכן את `pubspec.yaml`** (אם צריך):
```yaml
flutter:
  assets:
    - assets/html/
```

3. **עדכן את `lib/data/chapters_data.dart`**:
```dart
static const List<Chapter> chapters = [
  Chapter(
    id: 'chapter_1',
    title: 'פרק א - הלכות גסיסה ופטירה',
    htmlFileName: 'chapter_1.html',
    description: 'דיני הגוסס, רגע המיתה, והטיפול הראשוני בנפטר',
    order: 1,
  ),
  // הוסף פרק חדש:
  Chapter(
    id: 'chapter_2',
    title: 'פרק ב - ...',
    htmlFileName: 'chapter_2.html',
    description: '...',
    order: 2,
  ),
];
```

### מבנה HTML מומלץ

```html
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>כותרת הפרק</title>
    <style>
        /* הסגנונות שלך */
    </style>
</head>
<body>
    <h1 class="chapter-title">כותרת הפרק</h1>
    <!-- תוכן הפרק -->
</body>
</html>
```

---

## ⚙️ קונפיגורציה

### שינוי שם האפליקציה

עדכן ב-`lib/config/constants.dart`:
```dart
static const String appName = 'שם האפליקציה';
```

### שינוי צבעים

עדכן ב-`lib/config/theme.dart`:
```dart
static const Color primaryColor = Color(0xFF1A365D);
static const Color accentColor = Color(0xFFC9A227);
```

---

## 📱 תמיכה בפלטפורמות

| פלטפורמה | סטטוס |
|----------|--------|
| Android | ✅ נתמך |
| iOS | ✅ נתמך |

---

## 🤝 תרומה לפרויקט

תרומות מתקבלות בברכה! 

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 רישיון

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---



<div align="center">

**⭐ אם הפרויקט עזר לך, אשמח לכוכב! ⭐**

</div>
