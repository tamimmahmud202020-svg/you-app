class Subjects {
  Subjects._();

  static const List<String> all = [
    'Bangla',
    'English',
    'Mathematics',
    'Bangladesh Affairs',
    'International Affairs',
    'General Science',
    'ICT',
    'Geography',
    'Ethics, Values & Good Governance',
    'Mental Ability',
    'General Knowledge',
    'Other',
  ];

  static const Map<String, String> banglaNames = {
    'Bangla': 'বাংলা',
    'English': 'ইংরেজি',
    'Mathematics': 'গণিত',
    'Bangladesh Affairs': 'বাংলাদেশ বিষয়াবলি',
    'International Affairs': 'আন্তর্জাতিক বিষয়াবলি',
    'General Science': 'সাধারণ বিজ্ঞান',
    'ICT': 'তথ্য ও যোগাযোগ প্রযুক্তি',
    'Geography': 'ভূগোল',
    'Ethics, Values & Good Governance': 'নৈতিকতা, মূল্যবোধ ও সুশাসন',
    'Mental Ability': 'মানসিক দক্ষতা',
    'General Knowledge': 'সাধারণ জ্ঞান',
    'Other': 'অন্যান্য',
  };

  static const Map<String, String> icons = {
    'Bangla': '📖',
    'English': '🔤',
    'Mathematics': '📐',
    'Bangladesh Affairs': '🇧🇩',
    'International Affairs': '🌍',
    'General Science': '🔬',
    'ICT': '💻',
    'Geography': '🗺️',
    'Ethics, Values & Good Governance': '⚖️',
    'Mental Ability': '🧠',
    'General Knowledge': '💡',
    'Other': '📚',
  };

  static String localized(String subject, String languageCode) {
    if (languageCode == 'bn') {
      return banglaNames[subject] ?? subject;
    }
    return subject;
  }
}