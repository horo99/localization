import 'package:localization_ui/src/home/domain/entities/language_file.dart';

extension LanguageFileExtension on LanguageFile {
  LanguageFile copy() {
    return LanguageFile(file, getMap());
  }
}
