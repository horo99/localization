import 'package:localization_ui/src/home/domain/entities/language_file.dart';

abstract class FileState {
  final String? directory;
  final List<LanguageFile> languages;
  final Set<String> keys;

  FileState({this.directory, this.languages = const [], this.keys = const {}});

  FileState loadedLanguages([List<LanguageFile>? languages]) => LoadedFileState.languages(
        directory: directory,
        languages: languages ?? this.languages,
      );
  FileState changeDirectory([String? directory]) => LoadedFileState.languages(
        directory: directory ?? this.directory,
        languages: languages,
      );
}

class InitFileState extends FileState {}

class LoadedFileState extends FileState {
  LoadedFileState._({
    required String? directory,
    required List<LanguageFile> languages,
    required Set<String> keys,
  }) : super(directory: directory, languages: languages, keys: keys);

  factory LoadedFileState.languages({
    required String? directory,
    required List<LanguageFile> languages,
  }) {
    final _keys = <String>{};
    for (var langs in languages) {
      _keys.addAll(langs.keys);
    }

    return LoadedFileState._(directory: directory, languages: languages, keys: _keys);
  }
}
