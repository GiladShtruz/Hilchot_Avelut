import '../models/models.dart';

/// Static data for all chapters in the book
class ChaptersData {
  ChaptersData._();

  /// List of all chapters with their sub-chapters
  static const List<Chapter> chapters = [
    // ========================================
    // חלק ראשון - התארגנות
    // ========================================
    Chapter(
      id: 'chapter_1',
      title: 'חלק ראשון - התארגנות',
      description: 'בן משפחה נפטר – מה עושים?',
      order: 1,
      subChapters: [
        SubChapter(
          id: 'chapter_1_intro',
          title: 'מבוא',
          htmlFileName: 'chapter_1/intro.html',
          order: 1,
        ),
        SubChapter(
          id: 'chapter_1_licensing',
          title: 'רישוי מנהלי',
          htmlFileName: 'chapter_1/Part_One_Organisation_And_Licensing.html',
          order: 2,
        ),
        SubChapter(
          id: 'chapter_1_coordination',
          title: 'התיאום עם חברה קדישא',
          htmlFileName: 'chapter_1/Coordination_With_The_Burial_Society.html',
          order: 3,
        ),
        SubChapter(
          id: 'chapter_1_family_prep',
          title: 'ההתארגנות המשפחתית ללוויה',
          htmlFileName: 'chapter_1/Family_Preparation_For_The_Funeral.html',
          order: 4,
        ),
      ],
    ),

    // ========================================
    // חלק שני – הלכות ומנהגים
    // ========================================
    Chapter(
      id: 'chapter_2',
      title: 'חלק שני - הלכות ומנהגים',
      description: 'עד הקבורה, לוויה וקבורה, בבית האבל, אבלות',
      order: 2,
      subChapters: [
        // מבוא
        SubChapter(
          id: 'chapter_2_intro',
          title: 'מבוא',
          htmlFileName: 'chapter_2/intro.html',
          order: 1,
        ),
        // ביקור חולים
        SubChapter(
          id: 'chapter_2_sick_visits',
          title: 'ביקור חולים',
          htmlFileName: 'chapter_2/Sick_Visits_Laws.html',
          order: 2,
        ),
        // הטיפול בגוסס ובנפטר
        SubChapter(
          id: 'chapter_2_death_rites',
          title: 'הטיפול בגוסס ובנפטר',
          htmlFileName: 'chapter_2/Jewish_Death_Rites.html',
          order: 3,
        ),
        // אנינות
        SubChapter(
          id: 'chapter_2_aninut',
          title: 'אנינות',
          htmlFileName: 'chapter_2/Aninut.html',
          order: 4,
        ),
        // סדרי הלוויה והקבורה
        SubChapter(
          id: 'chapter_2_funeral',
          title: 'סדרי הלוויה והקבורה',
          htmlFileName: 'chapter_2/Funeral_and_Burial_Procedures.html',
          order: 5,
        ),
        // קריעה
        SubChapter(
          id: 'chapter_2_keriah',
          title: 'קריעה',
          htmlFileName: 'chapter_2/Keriah.html',
          order: 6,
        ),
        // סעודת הבראה
        SubChapter(
          id: 'chapter_2_seudat_havraah',
          title: 'סעודת הבראה',
          htmlFileName: 'chapter_2/Seudat_Havraah.html',
          order: 7,
        ),
        // מנהגים בבית האבל
        SubChapter(
          id: 'chapter_2_customs',
          title: 'מנהגים בבית האבל',
          htmlFileName: 'chapter_2/customs_at_the_house_of_mourning.html',
          order: 8,
        ),
        // ניחום אבלים
        SubChapter(
          id: 'chapter_2_comforting',
          title: 'ניחום אבלים',
          htmlFileName: 'chapter_2/comforting_mourners.html',
          order: 9,
        ),
        // תפילה בבית האבל
        SubChapter(
          id: 'chapter_2_prayer',
          title: 'תפילה בבית האבל',
          htmlFileName: 'chapter_2/prayer_in_the_house_of_the_mourner.html',
          order: 10,
        ),
        // דיני אמירת הקדיש
        SubChapter(
          id: 'chapter_2_kaddish_laws',
          title: 'דיני אמירת הקדיש',
          htmlFileName: 'chapter_2/laws_of_reciting_the_kaddish.html',
          order: 11,
        ),
        // תהליך האבלות מבחינה רעיונית
        SubChapter(
          id: 'chapter_2_mourning_process',
          title: 'תהליך האבלות מבחינה רעיונית',
          htmlFileName: 'chapter_2/the_mourning_process_conceptually.html',
          order: 12,
        ),
        // אבלות – המקור והטעם
        SubChapter(
          id: 'chapter_2_mourning_source',
          title: 'אבלות – המקור והטעם',
          htmlFileName: 'chapter_2/mourning_the_source_and_reason.html',
          order: 13,
        ),
        // על מי חלה האבלות
        SubChapter(
          id: 'chapter_2_who_mourns',
          title: 'על מי חלה האבלות',
          htmlFileName: 'chapter_2/who_is_mourning_for.html',
          order: 14,
        ),
        // כיצד מחשבים את ימי האבלות
        SubChapter(
          id: 'chapter_2_calculate_days',
          title: 'כיצד מחשבים את ימי האבלות',
          htmlFileName: 'chapter_2/how_are_the_days_of_mourning_calculated.html',
          order: 15,
        ),
        // אבלות בתוך השבעה
        SubChapter(
          id: 'chapter_2_within_shiva',
          title: 'אבלות בתוך השבעה',
          htmlFileName: 'chapter_2/Mourning_Within_The_Shiva.html',
          order: 16,
        ),
        // אבלות לאחר השבעה
        SubChapter(
          id: 'chapter_2_after_shiva',
          title: 'אבלות לאחר השבעה',
          htmlFileName: 'chapter_2/Mourning_After_The_Shiva.html',
          order: 17,
        ),
        // אבלות בחגים ומועדי השנה
        SubChapter(
          id: 'chapter_2_holidays',
          title: 'אבלות בחגים ובמועדי השנה',
          htmlFileName: 'chapter_2/Mourning_On_Holidays_And_After_Year.html',
          order: 18,
        ),
        // עלייה לקבר ואזכרה
        SubChapter(
          id: 'chapter_2_grave_memorial',
          title: 'עלייה לקבר ואזכרה',
          htmlFileName: 'chapter_2/Ascending_To_The_Grave_And_Memorial.html',
          order: 19,
        ),
        // בית הקברות
        SubChapter(
          id: 'chapter_2_cemetery',
          title: 'בית הקברות',
          htmlFileName: 'chapter_2/The_Cemetery.html',
          order: 20,
        ),
        // מצבים מיוחדים באבלות
        SubChapter(
          id: 'chapter_2_special_situations',
          title: 'מצבים מיוחדים באבלות',
          htmlFileName: 'chapter_2/Special_Situations_In_Mourning.html',
          order: 21,
        ),
      ],
    ),

    // ========================================
    // חלק שלישי – עיון והגות
    // ========================================
    Chapter(
      id: 'chapter_3',
      title: 'חלק שלישי - עיון והגות',
      description: 'הקדיש, תרומת אברים, העולם הבא, מיתה ותחיית המתים, טומאה וטהרה',
      order: 3,
      subChapters: [
        SubChapter(
          id: 'chapter_3_kaddish',
          title: 'הקדיש',
          htmlFileName: 'chapter_3/The_Kaddish.html',
          order: 1,
        ),
        SubChapter(
          id: 'chapter_3_organ_donation',
          title: 'תרומת אברים והשתלות',
          htmlFileName: 'chapter_3/Organ_Donation_and_Transplantation.html',
          order: 2,
        ),
        SubChapter(
          id: 'chapter_3_afterlife',
          title: 'העולם הבא',
          htmlFileName: 'chapter_3/The_Afterlife.html',
          order: 3,
        ),
        SubChapter(
          id: 'chapter_3_resurrection',
          title: 'מיתה ותחיית המתים',
          htmlFileName: 'chapter_3/Death_and_Resurrection.html',
          order: 4,
        ),
        SubChapter(
          id: 'chapter_3_purity',
          title: 'טומאה וטהרה',
          htmlFileName: 'chapter_3/Ritual_Impurity_and_Purity.html',
          order: 5,
        ),
      ],
    ),

    // ========================================
    // חלק רביעי - הדרכה למלווים ולתומכים
    // ========================================
    Chapter(
      id: 'chapter_4',
      title: 'חלק רביעי - הדרכה למלווים ולתומכים',
      description: 'הודעה על אסון, מידע למתנדבים, תהליך האבל, הנצחה',
      order: 4,
      subChapters: [
        SubChapter(
          id: 'chapter_4_notify_family',
          title: 'איך מודיעים למשפחה על אסון',
          htmlFileName: 'chapter_4/how_to_tell_family_about_tragedy.html',
          order: 1,
        ),
        SubChapter(
          id: 'chapter_4_volunteers',
          title: 'מידע למתנדבי חברה קדישא',
          htmlFileName: 'chapter_4/information_for_chevra_kadisha_volunteers.html',
          order: 2,
        ),
        SubChapter(
          id: 'chapter_4_grief_psychological',
          title: 'תהליך האבל – היבטים פסיכולוגיים',
          htmlFileName: 'chapter_4/the_grief_process_psychological_aspects.html',
          order: 3,
        ),
        SubChapter(
          id: 'chapter_4_grief_children',
          title: 'תהליך האבל – היבטים ייחודיים לילדים',
          htmlFileName: 'chapter_4/the_grief_process_unique_aspects_for_children.html',
          order: 4,
        ),
        SubChapter(
          id: 'chapter_4_consolation',
          title: 'החוכמה הנשכחת של הנחמה',
          htmlFileName: 'chapter_4/the_forgotten_wisdom_of_consolation.html',
          order: 5,
        ),
        SubChapter(
          id: 'chapter_4_commemoration',
          title: 'הנצחה',
          htmlFileName: 'chapter_4/commemoration.html',
          order: 6,
        ),
      ],
    ),

    // ========================================
    // חלק חמישי – צוואות וירושות
    // ========================================
    Chapter(
      id: 'chapter_5',
      title: 'חלק חמישי - צוואות וירושות',
      description: 'דיני ירושה על פי ההלכה, ניהול עיזבון',
      order: 5,
      subChapters: [
        SubChapter(
          id: 'chapter_5_inheritance',
          title: 'דיני ירושה על פי ההלכה היהודית',
          htmlFileName: 'chapter_5/Jewish_inheritance_law.html',
          order: 1,
        ),
        SubChapter(
          id: 'chapter_5_estate',
          title: 'ניהול עיזבון על ידי צוואה או צו ירושה',
          htmlFileName: 'chapter_5/Legal_estate_management.html',
          order: 2,
        ),
      ],
    ),

    // ========================================
    // חלק שביעי - פרקי תפילה, אזכרה ולימוד
    // ========================================
    Chapter(
      id: 'chapter_7',
      title: 'חלק שביעי - פרקי תפילה, אזכרה ולימוד',
      description: 'תפילות, קדיש, משניות, נוסחי אזכרה',
      order: 6,
      subChapters: [
        SubChapter(
          id: 'chapter_7_prayer_sick',
          title: 'מי שברך לחולה',
          htmlFileName: 'chapter_7/Prayer_for_the_sick.html',
          order: 1,
        ),
        SubChapter(
          id: 'chapter_7_prayers_death',
          title: 'תפילות בהתקרב הקץ',
          htmlFileName: 'chapter_7/Prayers_before_death.html',
          order: 2,
        ),
        SubChapter(
          id: 'chapter_7_visiting_graves',
          title: 'ביקורי קברים',
          htmlFileName: 'chapter_7/Visiting_graves.html',
          order: 3,
        ),
        SubChapter(
          id: 'chapter_7_kaddish',
          title: 'קדיש יתום',
          htmlFileName: 'chapter_7/Kaddish_Yatom.html',
          order: 4,
        ),
        SubChapter(
          id: 'chapter_7_el_male',
          title: 'אל מלא רחמים והשכבות',
          htmlFileName: 'chapter_7/HaShkavot.html',
          order: 5,
        ),
        SubChapter(
          id: 'chapter_7_prayers_learning',
          title: 'תפילות לפני ואחרי הלימוד',
          htmlFileName: 'chapter_7/Tefilot_Lifnei_VeAcharei_HaLimud.html',
          order: 6,
        ),
        SubChapter(
          id: 'chapter_7_mishnayot',
          title: 'לימוד משניות לעילוי נשמה',
          htmlFileName: 'chapter_7/Limud_Mishnayot_LeIluy_Neshama.html',
          order: 7,
        ),
        SubChapter(
          id: 'chapter_7_mishna_list',
          title: 'רשימת פרקי משנה',
          htmlFileName: 'chapter_7/Reshimat_Pirkei_Mishna.html',
          order: 8,
        ),
        SubChapter(
          id: 'chapter_7_memorial_texts',
          title: 'נוסחים לאזכרה',
          htmlFileName: 'chapter_7/Nusachim_LeAzkarah.html',
          order: 9,
        ),
      ],
    ),

    // ========================================
    // חלק שמיני - פרקי מידע
    // ========================================
    Chapter(
      id: 'chapter_8',
      title: 'חלק שמיני - פרקי מידע',
      description: 'רשימות חברות קדישא, לשכות בריאות, תמיכה נפשית',
      order: 7,
      subChapters: [
        SubChapter(
          id: 'chapter_8_burial_societies',
          title: 'רשימת חברות קדישא ארצית',
          htmlFileName: 'chapter_8/national_list_of_burial_societies.html',
          order: 1,
        ),
        SubChapter(
          id: 'chapter_8_health_offices',
          title: 'רשימת לשכות הבריאות',
          htmlFileName: 'chapter_8/list_of_burial_sections.html',
          order: 2,
        ),
        SubChapter(
          id: 'chapter_8_support',
          title: 'תמיכה נפשית',
          htmlFileName: 'chapter_8/psychological_support.html',
          order: 3,
        ),
      ],
    ),

    // ========================================
    // חלק תשיעי - מפתח
    // ========================================
    Chapter(
      id: 'chapter_9',
      title: 'חלק תשיעי - מקורות ומפתח',
      description: 'מקורות לספר וספרות עזר',
      order: 8,
      subChapters: [
        SubChapter(
          id: 'chapter_9_sources',
          title: 'מקורות',
          htmlFileName: 'chapter_9/Sources.html',
          order: 1,
        ),
      ],
    ),
  ];

  /// Get all sub-chapters as flat list
  static List<SubChapter> get allSubChapters {
    return chapters.expand((c) => c.subChapters).toList();
  }

  /// Get chapter by ID
  static Chapter? getChapterById(String id) {
    try {
      return chapters.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get sub-chapter by ID (searches all chapters)
  static SubChapter? getSubChapterById(String subId) {
    for (final chapter in chapters) {
      final sub = chapter.getSubChapterById(subId);
      if (sub != null) return sub;
    }
    return null;
  }

  /// Get parent chapter of a sub-chapter
  static Chapter? getParentChapter(String subChapterId) {
    for (final chapter in chapters) {
      if (chapter.subChapters.any((s) => s.id == subChapterId)) {
        return chapter;
      }
    }
    return null;
  }

  /// Get next sub-chapter
  static SubChapter? getNextSubChapter(String currentSubId) {
    final allSubs = allSubChapters;
    final currentIndex = allSubs.indexWhere((s) => s.id == currentSubId);
    if (currentIndex == -1 || currentIndex >= allSubs.length - 1) {
      return null;
    }
    return allSubs[currentIndex + 1];
  }

  /// Get previous sub-chapter
  static SubChapter? getPreviousSubChapter(String currentSubId) {
    final allSubs = allSubChapters;
    final currentIndex = allSubs.indexWhere((s) => s.id == currentSubId);
    if (currentIndex <= 0) {
      return null;
    }
    return allSubs[currentIndex - 1];
  }
}
