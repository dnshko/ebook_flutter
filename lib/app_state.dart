import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  Locale locale = Locale('en');
  var selectedLanguageCode = 'en';

  AppState(lang) {
    selectedLanguageCode = lang;
    if (lang == "en" ||
        lang == "fr" ||
        lang == "af" ||
        lang == "de" ||
        lang == "es" ||
        lang == "in" ||
        lang == "vi" ||
        lang == "tr" ||
        lang == "hi" ||
        lang == "ar") {
      selectedLanguageCode = lang;
    } else {
      selectedLanguageCode = 'en';
    }
  }

  Locale get getLocale => locale;

  get getSelectedLanguageCode => selectedLanguageCode;

  setLocale(locale) => this.locale = locale;

  setSelectedLanguageCode(code) => this.selectedLanguageCode = code;

  changeLocale(Locale l) {
    var lang = l.languageCode;
    if (lang == "en" ||
        lang == "fr" ||
        lang == "af" ||
        lang == "de" ||
        lang == "es" ||
        lang == "in" ||
        lang == "vi" ||
        lang == "tr" ||
        lang == "hi" ||
        lang == "ar") {
      locale = l;
      notifyListeners();
    } else {
      locale = 'en' as Locale;
      notifyListeners();
    }
  }

  changeLanguageCode(code) {
    if (code == "en" ||
        code == "fr" ||
        code == "af" ||
        code == "de" ||
        code == "es" ||
        code == "in" ||
        code == "vi" ||
        code == "tr" ||
        code == "hi" ||
        code == "ar") {
      selectedLanguageCode = code;
      notifyListeners();
    } else {
      selectedLanguageCode = 'en';
      notifyListeners();
    }
  }
}
