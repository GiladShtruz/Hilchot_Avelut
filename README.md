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

## 📖 אודות הפרויקט

אפליקציית Flutter המציגה את תוכן הספר "הלכות אבלות". האפליקציה מספקת ממשק קריאה נוח, עם תכונות שמטרתן לשפר את חווית המשתמש.

### ✨ תכונות עיקריות

- **ניווט קל**: תוכן עניינים מובנה למעבר מהיר בין פרקים.
- **חיפוש מתקדם**: חיפוש טקסט מלא בכל הספר עם הדגשת תוצאות.
- **מועדפים**: אפשרות לשמור סימניות במיקום גלילה מדויק בתוך פרק.
- **שמירת התקדמות**: האפליקציה זוכרת אוטומטית את המיקום האחרון בכל פרק.
- **תמיכה מלאה בעברית**: עיצוב RTL מותאם לשפה העברית.
- **קריאה נוחה**: הצגת התוכן בפורמט HTML עם עיצוב נקי וקריא.

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

## 🛠️ טכנולוגיות

| טכנולוגיה | שימוש |
|-----------|-------|
| **Flutter** | Framework |
| **Provider** | State Management |
| **Hive** | Local Storage |
| **WebView** | HTML Rendering |

---

## 🚀 הורדה והפעלה

1. **שכפול המאגר**
```bash
git clone https://github.com/yourusername/evelut_halacha.git
cd evelut_halacha
```

2. **התקנת תלויות**
```bash
flutter pub get
```

3. **הרצת האפליקציה**
```bash
flutter run
```

---

## 🤝 תרומה לפרויקט

תרומות יתקבלו בברכה. ניתן לתרום על ידי פתיחת Pull Request עם שיפורים או תיקונים.

### הוספת תוכן

1.  **הוסף קובץ HTML** חדש לתיקייה `assets/html/`.
2.  **עדכן את רשימת הפרקים** בקובץ `lib/data/chapters_data.dart`:

```dart
static const List<Chapter> chapters = [
  // ... פרקים קיימים
  Chapter(
    id: 'new_chapter_id',
    title: 'כותרת הפרק החדש',
    htmlFileName: 'new_chapter.html',
    description: 'תיאור קצר של הפרק',
    order: 3, // מספר סידורי
  ),
];
```

### ארכיטקטורת הפרויקט

הפרויקט מאורגן לפי עקרונות Clean Architecture על מנת להפריד בין שכבות הלוגיקה, המידע והתצוגה.

```
lib/
├── main.dart
├── app.dart
├── config/
├── data/
├── models/
├── services/
├── providers/
├── screens/
└── widgets/
```

---

## 📝 רישיון

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
