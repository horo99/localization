import 'package:flutter/material.dart';
import 'package:localization/src/localization_service.dart';

class LocalJsonLocalization extends LocalizationsDelegate {
  List<String> directories = ['lib/i18n'];
  bool showDebugPrintMode = true;
  LocalJsonLocalization._();

  static final delegate = LocalJsonLocalization._();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<dynamic> load(Locale locale) async {
    LocalizationService.instance.showDebugPrintMode = showDebugPrintMode;
    await LocalizationService.instance.changeLanguage(locale, directories);
  }

  @override
  bool shouldReload(LocalJsonLocalization old) => false;
}
