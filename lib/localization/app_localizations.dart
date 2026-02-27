import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return value ?? AppLocalizations(const Locale('en'));
  }

  Map<String, String> _localized = {};
  Map<String, String> _fallbackEn = {};

  Future<void> load() async {
    final enRaw = await rootBundle.loadString('assets/i18n/en.json');
    _fallbackEn = Map<String, String>.from(jsonDecode(enRaw) as Map);

    final code = locale.languageCode;
    if (code == 'en') {
      _localized = _fallbackEn;
      return;
    }

    try {
      final raw = await rootBundle.loadString('assets/i18n/$code.json');
      _localized = Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      _localized = _fallbackEn;
    }
  }

  String translate(String key) {
    return _localized[key] ?? _fallbackEn[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension LocalizationX on BuildContext {
  String tr(String key) => AppLocalizations.of(this).translate(key);
}
